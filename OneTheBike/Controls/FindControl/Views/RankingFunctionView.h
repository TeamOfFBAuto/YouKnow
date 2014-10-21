//
//  RankingFunctionView.h
//  OneTheBike
//
//  Created by soulnear on 14-10-20.
//  Copyright (c) 2014年 szk. All rights reserved.
//
/**
 排行榜功能按钮界面
 **/

#import <UIKit/UIKit.h>

@interface RankingFunctionView : UIView
{
    int currentPage;
}

@property (strong, nonatomic) IBOutlet UILabel *line_view;

@property (strong, nonatomic) IBOutlet UILabel *type_label;

@property (strong, nonatomic) IBOutlet UIButton *today;

@property (strong, nonatomic) IBOutlet UIButton *weekend;

@property (strong, nonatomic) IBOutlet UIButton *month;

- (IBAction)todayTap:(id)sender;
- (IBAction)weekendTap:(id)sender;
- (IBAction)monthTap:(id)sender;












@end
