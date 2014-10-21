//
//  MapCacheClass.m
//  OneTheBike
//
//  Created by lichaowei on 14/10/20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "MapCacheClass.h"

@implementation MapCacheClass

- (instancetype)initWithMapPointX:(double)x pointY:(double)y pointCount:(NSInteger)count
{
    self = [super init];
    if (self) {
        self.pointCount = count;
        self.pointX = x;
        self.pointY = y;
    }
    return self;
}

@end
