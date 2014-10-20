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




@end
