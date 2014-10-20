//
//  MapCacheClass.h
//  OneTheBike
//
//  Created by lichaowei on 14/10/20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapCacheClass : NSObject

/*!
 @brief 坐标点数组
 */
//@property (nonatomic, readonly) MAMapPoint *points;

@property(nonatomic,assign)double pointX;
@property(nonatomic,assign)double pointY;
/*!
 @brief 坐标点的个数
 */
@property (nonatomic, assign) NSUInteger pointCount;

- (instancetype)initWithMapPointX:(double)x pointY:(double)y pointCount:(NSInteger)count;


//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
//
//@property (nonatomic, readonly) MAMapRect boundingMapRect;
//
//@property (nonatomic, retain)  MAPolyline *polyline;


@end
