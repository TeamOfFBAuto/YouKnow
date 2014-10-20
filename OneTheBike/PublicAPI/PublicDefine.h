//
//  PublicDefine.h
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#ifndef OneTheBike_PublicDefine_h
#define OneTheBike_PublicDefine_h

#import "PublicDefine.h"
#import "LTools.h"
#import "UIColor+ConvertColor.h"
#import "UIView+Frame.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]


#define USER_NAME @"user_name"
#define USER_AUTHKEY_OHTER @"otherKey"//第三方key
#define USRR_AUTHKEY @"authkey"
#define USER_HEAD_IMAGEURL @"head_image_url"//


#define APP_ID @"605673005"

#define BACK_IMAGE [UIImage imageNamed:@"backButton"]
#define NAVIGATION_IMAGE [UIImage imageNamed:@"navigationBack"]

#endif
