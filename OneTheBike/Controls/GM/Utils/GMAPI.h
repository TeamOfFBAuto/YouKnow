//
//  GMAPI.h
//  OneTheBike
//
//  Created by gaomeng on 14-10-10.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "DataBase.h"

#define START_COOR_STRING @"startCoorString" //起点坐标
#define END_COOR_STRING @"endCoorString"
#define LINE_JSONSTRING @"lineJsonString"//线的jsonString

typedef enum{
    Type_Road = 1,//路书
    Type_GUIJI //轨迹
}HistoryType;

/* 使用高德地图API，请注册Key，注册地址：http://lbs.amap.com/console/key
 */
const static NSString *APIKey_MAP = @"0b92a81f23cc5905c30dcb4c39da609d";


@interface GMAPI : NSObject



///根据定位返回的地磁场doule值 返回方位 东 西 南 北 东北 东南 西南 西北
+(NSString *)switchMagneticHeadingWithDoubel:(double)theHeading;



///把经纬度添加到本地数据库里
+(void)addCllocationToDataBase:(CLLocationCoordinate2D)theLocation;



///从数据库里查找数据
+(void)findNowAllLocation;


//存储路线数据 type 1为路书 2为轨迹
+ (void)addRoadLinesJsonString:(NSString *)jsonstr
                     startName:(NSString *)startName
                       endName:(NSString *)endName
                      distance:(NSString *)distance
                          type:(HistoryType)type
                  startCoorStr:(NSString *)startCoorString
                    endCoorStr:(NSString *)endCoorString;

+ (NSString *)getRoadLinesJSonStringForRoadId:(int)roadId;//根据id获取roadline的json数据

+ (NSDictionary *)getRoadLinesForRoadId:(int)roadId;//根据id获取json 以及起点终点


+ (NSArray *)getRoadLinesForType:(HistoryType)type;//根据类型获取LRoadClass对象列表

+ (void)updateRoadId:(int)roadId
           startName:(NSString *)startName
             endName:(NSString *)endName
                Open:(BOOL)isOpen;// yes 1 地图显示  NO 0 不显示

+ (void)updateRoadId:(int)roadId isUpload:(BOOL)finish;//是否上传成功

+ (NSArray *)getRoadLinesForType:(HistoryType)type
                          isOpen:(BOOL)open;//获取所有是否打开的路书或者轨迹

+ (BOOL)deleteRoadId:(int)roadId type:(HistoryType)type;//删除路书或者轨迹

@end
