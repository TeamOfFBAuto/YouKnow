//
//  LMapTools.h
//  OneTheBike
//
//  Created by lichaowei on 14/10/21.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>


#define L_START_POINT_COORDINATE @"start_point_coor"//起点坐标
#define L_END_POINT_COORDINATE @"end_point_coor"//终点坐标
#define L_POLINES @"lines"//线路数据

@interface LMapTools : NSObject

+ (NSArray *)saveMaplines:(NSArray *)polines_arr;//保存line对象

+ (NSDictionary *)parseMapHistoryMap:(NSArray *)historyMaplines;//解析成line对象

@end
