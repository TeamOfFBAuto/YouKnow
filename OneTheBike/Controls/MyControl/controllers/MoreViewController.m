//
//  MoreViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14-10-18.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "MoreViewController.h"
#import "MineCellTwo.h"

@interface MoreViewController ()
{
    NSArray *titles_arr;
    NSArray *imagesArray;
}

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //适配ios7navigationbar高度
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.navigationController.navigationBar setBackgroundImage:NAVIGATION_IMAGE forBarMetrics: UIBarMetricsDefault];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"e3e3e3"];
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton.width = -5;
    
    UIButton *_button_back=[[UIButton alloc]initWithFrame:CGRectMake(0,0,40,44)];
    [_button_back addTarget:self action:@selector(clickToBack:) forControlEvents:UIControlEventTouchUpInside];
    [_button_back setImage:BACK_IMAGE forState:UIControlStateNormal];
    _button_back.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *back_item=[[UIBarButtonItem alloc]initWithCustomView:_button_back];
    self.navigationItem.leftBarButtonItems=@[spaceButton,back_item];
    
    UILabel *_titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 21)];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = @"更多";
    
    self.navigationItem.titleView = _titleLabel;
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 16)];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    titles_arr = @[@"给个好评",@"联系轨记",@"反馈意见",@"版本更新",@"帮助说明"];
    imagesArray = @[@"more_good",@"more_contact",@"more_recommend",@"more_update",@"more_help"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickToBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 数据解析

#pragma mark - 网络请求

#pragma mark - 视图创建



#pragma mark - delegate


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles_arr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier1= @"MineCellTwo";
    
    MineCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MineCellTwo" owner:self options:nil]objectAtIndex:0];
    }
    
    cell.separatorInset = UIEdgeInsetsMake(7, 10, 10, 10);
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.aTitleLabel.text = [titles_arr objectAtIndex:indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:[imagesArray objectAtIndex:indexPath.row]];
    
    return cell;
    
}

@end
