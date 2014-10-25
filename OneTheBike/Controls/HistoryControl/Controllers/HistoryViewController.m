//
//  HistoryViewController.m
//  OneTheBike
//
//  Created by szk on 14-9-24.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;//主tableview
    
    NSMutableArray *_fangkaiArray;//里面记录的是已经展开的section
}
@end


@implementation HistoryViewController


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
    
//    NSArray *dataBaseArray = [GMAPI getRoadLinesForType:Type_GUIJI];
//    
//    for (nsar in <#collection#>) {
//        <#statements#>
//    }
    
    
//    self.dataArray =
    
    
    NSArray *dataBaseArray = [GMAPI getRoadLinesForType:1];
    
    NSLog(@"%s %d",__FUNCTION__,dataBaseArray.count);
    
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if ([[[UIDevice currentDevice]systemVersion]doubleValue]>=7.0) {
        self.edgesForExtendedLayout = NO;
    }
    
    
    //总公里数 运动次数 时长
    UIView *upGrayView = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 320, 35)];
    upGrayView.backgroundColor = RGBCOLOR(105, 105, 105);
    [self.view addSubview:upGrayView];
    
    
    //展开的数组
    _fangkaiArray = [NSMutableArray arrayWithCapacity:1];
    
    
    
    self.view.backgroundColor=[UIColor whiteColor];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 568) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    
    
    
    
    // Do any additional setup after loading the view.
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger num = 0;
    
    if (section == 0) {
        num = 0;
    }else{
        num = 0;
    }
    
    
    for (NSString *str in _fangkaiArray) {
        
        
        if ([str integerValue] == section) {
            
            NSArray *arr = self.dataArray[section];
            num = arr.count;
        }
    }
    
    
    
    return num;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *upHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    upHeaderView.tag = section +10;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gShouFangZiRu:)];
    [upHeaderView addGestureRecognizer:tap];
    
    if (section == 0) {
        upHeaderView.frame = CGRectMake(0, 0, 320, 80);
        upHeaderView.backgroundColor = [UIColor whiteColor];
    }else{
        upHeaderView.frame = CGRectMake(0, 0, 320, 30);
        upHeaderView.backgroundColor = RGBCOLOR(190, 190, 190);
    }
    
    return upHeaderView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = 0;
    if (section == 0) {
        height = 80;
    }else{
        height = 50;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}



-(void)gShouFangZiRu:(UIGestureRecognizer*)ges{
    if (ges.view.tag !=10) {//不是最上面的view
        
        NSString *sectionStr = [NSString stringWithFormat:@"%d",(ges.view.tag-10)];
        
        int arrCount = _fangkaiArray.count;
        BOOL ishave = NO;
        
        for (int i = 0; i<arrCount; i++) {
            NSString *str = _fangkaiArray[i];
            if ([str isEqualToString:sectionStr]) {
                ishave = YES;
                [_fangkaiArray removeObject:str];
            }
        }
        
        if (!ishave || arrCount==0) {
            [_fangkaiArray addObject:sectionStr];
        }
        
        [_tableView reloadData];
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
