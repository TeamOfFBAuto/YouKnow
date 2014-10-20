//
//  FindViewController.m
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "FindViewController.h"
#import "CycleScrollView.h"
#import "FindActivityViewController.h"
#import "FindRankingViewController.h"

@interface FindViewController ()
{
    
}

@property(nonatomic,strong)CycleScrollView * mainScorllView;


@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"发现";
    
    self.view.backgroundColor=RGBCOLOR(227,227,227);
    
    
    NSMutableArray *viewsArray = [@[] mutableCopy];
    NSArray *colorArray = @[@"1111.jpg",@"2222.jpg",@"1111.jpg",@"2222.jpg",@"1111.jpg"];
    for (int i = 0; i < 5; ++i) {
        UIImageView *tempLabel = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,320,175)];
        tempLabel.image = [UIImage imageNamed:[colorArray objectAtIndex:i]];
        [viewsArray addObject:tempLabel];
    }
    
    NSMutableArray * titleArray = [NSMutableArray arrayWithObjects:@"低碳出行爱相随",@"一片蓝天在轮下", @"低碳出行爱相随",@"一片蓝天在轮下",@"低碳出行爱相随",nil];
    
    self.mainScorllView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0,0,320,160) animationDuration:5.0f WithTitleArray:titleArray];
    self.mainScorllView.title_array = titleArray;
    self.mainScorllView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
    
    self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            
        return viewsArray[pageIndex];
    };
    self.mainScorllView.totalPagesCount = ^NSInteger(void){
        return 5;
    };
    self.mainScorllView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%d个",pageIndex);
    };
    [self.view addSubview:self.mainScorllView];
    
    
    NSArray * image_array = [NSArray arrayWithObjects:@"find_huodong_image.png",@"find_paihang_image@2x",nil];
    NSArray * tArray = [NSArray arrayWithObjects:@"活动",@"排行",nil];
 
    
    for (int i = 0;i < 2;i++)
    {
        CGRect frame = CGRectMake(0,200+80*i,320,60);
        [self setupViewWithFrame:frame With:[image_array objectAtIndex:i] Title:[tArray objectAtIndex:i] WithTag:100+i];
    }
}

#pragma mark - 活动、排行视图布局

-(void)setupViewWithFrame:(CGRect)frame With:(NSString *)icon Title:(NSString *)aTitle WithTag:(int)tag
{
    UIView * aView = [[UIView alloc] initWithFrame:frame];
    aView.backgroundColor = [UIColor whiteColor];
    aView.tag = tag;
    [self.view addSubview:aView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
    [aView addGestureRecognizer:tap];
    
    
    UIImageView * icon_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20,10,40,40)];
    icon_imageView.image = [UIImage imageNamed:icon];
    [aView addSubview:icon_imageView];
    
    UILabel * title_label = [[UILabel alloc] initWithFrame:CGRectMake(80,0,200,frame.size.height)];
    title_label.textAlignment = NSTextAlignmentLeft;
    title_label.text = aTitle;
    title_label.textColor = [UIColor blackColor];
    title_label.font = [UIFont systemFontOfSize:18];
    [aView addSubview:title_label];
    
    UIButton * access_button = [UIButton buttonWithType:UIButtonTypeCustom];
    access_button.frame = CGRectMake(280,10,40,frame.size.height-20);
    [access_button setImage:[UIImage imageNamed:@"right_jiantou_image"] forState:UIControlStateNormal];
    access_button.userInteractionEnabled = NO;
    [aView addSubview:access_button];
}



-(void)doTap:(UITapGestureRecognizer *)sender
{
    if (sender.view.tag == 100)
    {
        
        FindActivityViewController * activity = [[FindActivityViewController alloc] init];
        activity.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:activity animated:YES];
        
    }else
    {
        FindRankingViewController * activity = [[FindRankingViewController alloc] init];
        activity.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:activity animated:YES];
    }
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
