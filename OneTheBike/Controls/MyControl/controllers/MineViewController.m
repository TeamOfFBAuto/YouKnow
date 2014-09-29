//
//  MineViewController.m
//  OneTheBike
//
//  Created by lichaowei on 14-9-28.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "MineViewController.h"
#import "UMSocial.h"

#import "MineCellOne.h"
#import "MineCellTwo.h"

#import "UIColor+ConvertColor.h"

@interface MineViewController ()<UIActionSheetDelegate>
{
    NSArray *titleArray;
    NSArray *imagesArray;
}

@end

@implementation MineViewController

- (void)viewDidAppear:(BOOL)animated
{
//    if ([UMSocialAccountManager isOauthAndTokenNotExpired:<#(NSString *)#>]) {
//        <#statements#>
//    }
    
    [self login];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.table.backgroundColor = [UIColor colorWithHexString:@"e3e3e3"];
    
    imagesArray = @[@"mine_road",@"mine_map",@"mine_share",@"mine_more"];
    titleArray = @[@"路书管理",@"离线地图",@"分享好友",@"更多"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - mark 三方登录

- (void)login
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"登录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"QQ登录",@"新浪微博", nil];
    
    UITabBarController *tabbarVC = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    [sheet showFromTabBar:tabbarVC.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self loginToPlat:UMShareToQQ];
        
    }else if (buttonIndex == 1){
        
        [self loginToPlat:UMShareToSina];
    }

}

- (void)loginToPlat:(NSString *)snsPlatName
{
    //此处调用授权的方法,你可以把下面的platformName 替换成 UMShareToSina,UMShareToTencent等
    
    __weak typeof(self)weakSelf = self;
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsPlatName];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        NSLog(@"login response is %@",response);
        
        //获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsPlatName];
            NSLog(@"username is %@, uid is %@, token is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken);
            
            [weakSelf userInfoWithImage:snsAccount.iconURL name:snsAccount.userName];
        }
    });
}

#pragma mark - 事件处理

- (void)userInfoWithImage:(NSString *)imageUrl name:(NSString *)name
{
    MineCellOne *cell = (MineCellOne *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    cell.headImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    cell.nameLabel.text = name;
}

#pragma mark - 数据解析

#pragma mark - 网络请求

#pragma mark - 视图创建



#pragma mark - delegate


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 98;
    }
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
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        static NSString * identifier1= @"MineCellOne";
        
        MineCellOne *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"MineCellOne" owner:self options:nil]objectAtIndex:0];
        }
        cell.separatorInset = UIEdgeInsetsMake(7, 10, 10, 10);
        cell.backgroundColor = [UIColor clearColor];
        return cell;

    }
    
    static NSString * identifier1= @"MineCellTwo";
    
    MineCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MineCellTwo" owner:self options:nil]objectAtIndex:0];
    }
    
    cell.iconImageView.image = [UIImage imageNamed:[imagesArray objectAtIndex:indexPath.row - 1]];
    cell.aTitleLabel.text = [titleArray objectAtIndex:indexPath.row - 1];
    
    cell.separatorInset = UIEdgeInsetsMake(7, 10, 10, 10);
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}




@end
