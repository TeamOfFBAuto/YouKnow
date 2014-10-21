//
//  LMapTools.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/21.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "LMapTools.h"
#import "LMaplineClass.h"
#import "LineDashPolyline.h"
#import "CommonUtility.h"

@implementation LMapTools

//MAPolyline 或者 LineDashPolyline 组成的数组

//返回LMaplineClass 数组

+ (NSArray *)saveMaplines:(NSArray *)polines_arr
{
    NSMutableArray *polyline_arr = [NSMutableArray array];
    
    for (int i = 0; i < polines_arr.count; i ++) {
        
        id pp = [polines_arr objectAtIndex:i];
        if ([pp isKindOfClass:[MAPolyline class]]) {
            
            MAPolyline *temp = (MAPolyline *)pp;
            
            CLLocationCoordinate2D tempCoor[temp.pointCount];
            
            NSMutableArray *point_cor_arr = [NSMutableArray arrayWithCapacity:temp.pointCount * 2];
            
            [temp getCoordinates:tempCoor range:NSMakeRange(0, temp.pointCount)];
            
            for (int i = 0; i < temp.pointCount; i ++) {
                CLLocationCoordinate2D temp = tempCoor[i];
                
                [point_cor_arr addObject:[NSString stringWithFormat:@"%f",temp.longitude]];
                [point_cor_arr addObject:[NSString stringWithFormat:@"%f",temp.latitude]];
            }
            
            NSString *coordinatesString = [point_cor_arr componentsJoinedByString:@","];
            
            LMaplineClass *polyLine = [[LMaplineClass alloc]initMAPolylineWithMapPointX:temp.points->x pointY:temp.points->y pointCount:temp.pointCount type:TYPE_MAPolyline coordinatesString:coordinatesString];
            
            polyLine.rect_x = temp.boundingMapRect.origin.x;
            polyLine.rect_y = temp.boundingMapRect.origin.y;
            polyLine.rect_width = temp.boundingMapRect.size.width;
            polyLine.rect_height = temp.boundingMapRect.size.height;
            
            polyLine.latitude = temp.coordinate.latitude;
            polyLine.longitude = temp.coordinate.longitude;
            
            [polyline_arr addObject:polyLine];
        }
        if ([pp isKindOfClass:[LineDashPolyline class]]) {
            
            LineDashPolyline *temp = (LineDashPolyline *)pp;
            
            LMaplineClass *dashLine = [[LMaplineClass alloc]initLineDashPolylineWithCoordinate:temp.coordinate rect:temp.boundingMapRect polyline:temp.polyline type:TYPE_LineDashPolyline];
            
            [polyline_arr addObject:dashLine];
        }
    }
    
    NSArray *dic_arr = [LMaplineClass keyValuesArrayWithObjectArray:polyline_arr];
    
    return dic_arr;
}

// 数组

//historyMaplines 保存的数据(LMaplineClass)
+ (NSDictionary *)parseMapHistoryMap:(NSArray *)historyMaplines
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];//存储起点、终点 和 line数据
    NSMutableArray *lines = [NSMutableArray array];//所有的规划线

    if (historyMaplines.count > 0) {
        NSArray *object_arr = [LMaplineClass objectArrayWithKeyValuesArray:historyMaplines];
        
        for (int i = 0; i < object_arr.count; i ++) {
            LMaplineClass *cache = [object_arr objectAtIndex:i];
            
            if (i == 0) {
    
                NSString *la = [NSString stringWithFormat:@"%f",cache.latitude];
                NSString *lon = [NSString stringWithFormat:@"%f",cache.longitude];
                NSArray *ll = @[la,lon];
                [dic setObject:ll forKey:L_START_POINT_COORDINATE];
            }
            
            if (i == object_arr.count - 1) {
                
                NSString *la = [NSString stringWithFormat:@"%f",cache.latitude];
                NSString *lon = [NSString stringWithFormat:@"%f",cache.longitude];
                NSArray *ll = @[la,lon];
                [dic setObject:ll forKey:L_END_POINT_COORDINATE];
            }
            
            NSString *type = cache.classType;
            
            if ([type isEqualToString:TYPE_MAPolyline]) {
                
                NSUInteger count = cache.pointCount;
                CLLocationCoordinate2D *temp = [CommonUtility coordinatesForString:cache.coordinatesString coordinateCount:&count parseToken:@","];
                MAPolyline *line2 = [MAPolyline polylineWithCoordinates:temp count:cache.pointCount];
                [lines addObject:line2];
                
            }else if ([type isEqualToString:TYPE_LineDashPolyline]){
                
                NSDictionary *polyline = cache.polyline;
                MAMapPoint point = MAMapPointMake([[polyline valueForKey:@"pointX"] doubleValue], [[polyline valueForKey:@"pointY"] doubleValue]);
                
                MAPolyline *line = [MAPolyline polylineWithPoints:&point count:cache.pointCount];
                LineDashPolyline *line_Dash = [[LineDashPolyline alloc]initWithPolyline:line];
                
                line_Dash.coordinate = CLLocationCoordinate2DMake(cache.latitude, cache.longitude);
                double x = [[cache.polyline objectForKey:@"rect_x"]doubleValue];
                double y = [[cache.polyline objectForKey:@"rect_y"]doubleValue];
                double w = [[cache.polyline objectForKey:@"rect_width"]doubleValue];
                double h = [[cache.polyline objectForKey:@"rect_height"]doubleValue];
                
                line_Dash.boundingMapRect = MAMapRectMake(x, y, w, h);
                
                [lines addObject:line_Dash];
            }
        }
    }
    
    [dic setObject:lines forKey:L_POLINES];
    
    return dic;
}


@end
