//
//  LMapTools.h
//  OneTheBike
//
//  Created by lichaowei on 14/10/21.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NavigationViewControllerStartTitle     @"起点"
#define NavigationViewControllerDestinationTitle @"终点"
#define NavigationViewControllerMiddleTitle      @"途经点"


#define L_START_POINT_COORDINATE @"start_point_coor"//起点坐标
#define L_END_POINT_COORDINATE @"end_point_coor"//终点坐标
#define L_POLINES @"lines"//线路数据

#define ROAD_INDEX @"road_index"//路书id
#define NOTIFICATION_ROAD_LINES @"road_lines"//选择路书通知

@interface LMapTools : NSObject

+ (NSArray *)saveMaplines:(NSArray *)polines_arr;//保存line对象

+ (NSDictionary *)parseMapHistoryMap:(NSArray *)historyMaplines;//解析成line对象

@end
