//
//  HistoryViewController.h
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//


//轨迹历史vc
#import <UIKit/UIKit.h>
#import "GMAPI.h"

@interface HistoryViewController : UIViewController

@property(nonatomic,strong)NSArray *dataArray;//里面装字典 key为天数  数据源

@end
