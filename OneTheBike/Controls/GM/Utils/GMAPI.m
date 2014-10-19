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




+(void)addCllocationToDataBase:(CLLocationCoordinate2D)theLocation{
    
    NSString *gLat = [NSString stringWithFormat:@"%f",theLocation.latitude];
    NSString *gLon = [NSString stringWithFormat:@"%f",theLocation.longitude];
    
    sqlite3 *db = [DataBase openDB];
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare(db, "insert into area(name,id) values(?,?)", -1, &stmt, nil);//?相当于%@格式
    
    sqlite3_bind_text(stmt, 2, [gLat UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 3, [gLon UTF8String], -1, NULL);
    
    result = sqlite3_step(stmt);
    
    sqlite3_finalize(stmt);
}



+(void)findNowAllLocation{
    sqlite3 * db = [DataBase openDB];
    sqlite3_stmt * stmt = nil;
    int result = sqlite3_prepare_v2(db,"select * from Gzuji order by fb_deteline desc", -1,&stmt,nil);
    NSLog(@"result ------   %d",result);
    
    if (result == SQLITE_OK) {
        
    }
    
}



@end
