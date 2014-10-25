//
//  GyundongCanshuModel.m
//  OneTheBike
//
//  Created by gaomeng on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GyundongCanshuModel.h"

@implementation GyundongCanshuModel

-(id)init{
    self = [super init];
    if (self) {
        self.timeRunLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.timeRunLabel.text = @"00:00:00";
    }
    
    return self;
}

-(void)cleanAllData{
//    self.time = 0;
    self.podu = 0;
    self.peisu = 0;
    self.pashenglv = 0;
//    self.haibashang = 0;
//    self.haibaxia = 0;
    self.pingjunsudu = 0;
    self.maxSudu = 0;
    self.timeRunLabel.text = @"00:00:00";
    self.haiba = @"";
    
    
}

@end
