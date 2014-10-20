//
//  FindRankingViewController.m
//  OneTheBike
//
//  Created by soulnear on 14-10-20.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "FindRankingViewController.h"
#import "RankingFunctionView.h"
#import "RankingTableViewCell.h"

@interface FindRankingViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView * myTableView;
}

@end

@implementation FindRankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"排行";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    RankingFunctionView * fView = [[[NSBundle mainBundle] loadNibNamed:@"RankingFunctionView" owner:self options:nil] objectAtIndex:0];
    fView.frame = CGRectMake(0,64,320,30);
    [self.view addSubview:fView];
    
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,64+30,320,(iPhone5?568:480)-30) style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:myTableView];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"identifier";
    RankingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RankingTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    cell.ranking_num.text = [NSString stringWithFormat:@"%d",indexPath.row];
    
    return cell;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
