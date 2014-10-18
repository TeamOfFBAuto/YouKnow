//
//  GMAPI.m
//  OneTheBike
//
//  Created by gaomeng on 14-10-10.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GMAPI.h"

@implementation GMAPI


+(NSString *)switchMagneticHeadingWithDoubel:(double)theHeading{
    NSString *str = @"";
    if (theHeading<22.5 || theHeading>=337.5) {
        str = @"北";
    }else if (theHeading>=22.5 && theHeading<67.5){
        str = @"东北";
    }else if (theHeading>=67.5 && theHeading<112.5){
        str = @"东";
    }else if (theHeading>=112.5 && theHeading<157.5){
        str = @"东南";
    }else if (theHeading>=157.5 && theHeading<202.5){
        str = @"南";
    }else if (theHeading>=202.5 && theHeading<247.5){
        str = @"西南";
    }else if (theHeading>=247.5 && theHeading<292.5){
        str = @"西";
    }else if (theHeading>=292.5 && theHeading<337.5){
        str = @"西北";
    }
    
    return str;
    
}
@end
