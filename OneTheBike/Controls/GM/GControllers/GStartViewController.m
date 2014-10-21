//
//  GStartViewController.m
//  OneTheBike
//
//  Created by gaomeng on 14-10-13.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GStartViewController.h"
#import "ReGeocodeAnnotation.h"
#import "GOffLineMapViewController.h"
#import "Gmap.h"

#define FRAME_IPHONE5_MAP_UP CGRectMake(0, 60, 320, 568-60-20)
#define FRAME_IPHONE5_MAP_DOWN CGRectMake(0, 260+20, 320, 568-260-20)
#define FRAME_IPHONE5_UPVIEW_UP CGRectMake(0, -200, 320, 260)
#define FRAME_IPHONE5_UPVIEW_DOWN CGRectMake(0, 20, 320, 260)

@interface GStartViewController ()<UIActionSheetDelegate>
{
    UIView *_upview;//上面的运动信息view
    BOOL _isUpViewShow;//当前是否显示运动信息view
    UIButton *_upOrDownBtn;//上下收放btn
    UIView *_downView;//运动开始时下方的view
    
    UILabel *_fangxiangLabel;//方向
    UILabel *_gspeedLabel;//速度
    UILabel *_gstartimeLabel;//时间
    UILabel *_gongliLabel;//公里
    UILabel *_ghaibaLabel;//海拔
    UILabel *_gbpmLabel;//bpm
    
    
    BOOL _isTimeOutClicked;//暂停按钮点击
    UIButton *_greenTimeOutBtn;//暂停按钮
    
    double _distance;//距离
    
    
    
    
    //路书
    MAPointAnnotation *startAnnotation;//起点
    MAPointAnnotation *detinationAnnotation;//终点
    NSMutableArray *middleAnntations;//途经点
    NSArray *_lines;//路书数组
}
@property (nonatomic,strong)NSMutableArray *cllocation2dsArray;
@property (nonatomic, strong) NSMutableArray *overlays;

@end

@implementation GStartViewController

- (void)dealloc
{
    [self returnAction];
    
}


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
#pragma mark - 接受通知隐藏tabbar
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(iWantToStart) name:@"GToGstar" object:nil];
    
#pragma mark - 从路书跳转过来的通知
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newBilityXiaoPang:) name:NOTIFICATION_ROAD_LINES object:nil];
    
    _isTimeOutClicked = NO;
    _distance = 0.0f;
    
    //地图相关初始化
    [self initMapViewWithFrame:FRAME_IPHONE5_MAP_DOWN];
//    [self initObservers];
    [self initSearch];
//    [self modeAction];
    self.mapView.showsUserLocation = NO;//关闭定位
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;//自定义定位样式
    self.mapView.userTrackingMode = MAUserTrackingModeNone;//定位模式
    
    self.mapView.showsCompass= YES;//开启指南针
    self.mapView.compassOrigin= CGPointMake(280, 10); //设置指南针位置
    
    self.mapView.showsScale= NO; //关闭比例尺
    self.mapView.scaleOrigin = CGPointMake(10, 70);
    
//    [self initGestureRecognizer];//长按手势
    
    [self.mapView addOverlays:self.overlays];//把线条添加到地图上
    
    [self configureRoutes];//划线
    
    

    
    //地图上面的view
    _isUpViewShow = YES;
    _upview = [[UIView alloc]initWithFrame:FRAME_IPHONE5_UPVIEW_DOWN];
    _upview.backgroundColor = [UIColor whiteColor];
    
    //上下按钮
    _upOrDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _upOrDownBtn.layer.cornerRadius = 15;
    _upOrDownBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_upOrDownBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_upOrDownBtn setTitle:@"up" forState:UIControlStateNormal];
    [_upOrDownBtn setFrame:CGRectMake(145, 240, 30, 30)];
    //    [_upOrDownBtn setBackgroundColor:[UIColor lightGrayColor]];
    [_upOrDownBtn setImage:[UIImage imageNamed:@"gbtnup.png"] forState:UIControlStateNormal];
    [_upOrDownBtn addTarget:self action:@selector(gShou) forControlEvents:UIControlEventTouchUpInside];
    
    
    //图标数组
    NSArray *titleImageArr = @[[UIImage imageNamed:@"gspeed.png"],[UIImage imageNamed:@"gstartime.png"],[UIImage imageNamed:@"gongli.png"],[UIImage imageNamed:@"ghaiba.png"],[UIImage imageNamed:@"gbpm.png"]];
    
    for (int i = 0; i<6; i++) {
        //自定义view
        UIView *customView = [[UIView alloc]initWithFrame:CGRectZero];
        customView.backgroundColor = [UIColor whiteColor];
        //分割线
        UIView *line = [[UIView alloc]initWithFrame:CGRectZero];
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectZero];
        line.backgroundColor = RGBCOLOR(222, 222, 222);
        line1.backgroundColor = RGBCOLOR(222, 222, 222);
        //图标
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectZero];
        if (i>0) {
            [imv setImage:titleImageArr[i-1]];
        }
        
        //内容label
        
        
        //添加视图
        [customView addSubview:line];
        [customView addSubview:line1];
        [customView addSubview:imv];
        
        if (i == 0) {//上面灰条
            customView.frame = CGRectMake(0, 0, 320, 35);
            customView.backgroundColor = RGBCOLOR(105, 105, 105);
            _fangxiangLabel = [[UILabel alloc]initWithFrame:CGRectMake(250, 5, 50, 30)];
            _fangxiangLabel.font = [UIFont systemFontOfSize:20];
            _fangxiangLabel.textColor = [UIColor whiteColor];
            _fangxiangLabel.textAlignment = NSTextAlignmentCenter;
            [customView addSubview:_fangxiangLabel];
        }else if (i == 1){//公里/时
            customView.frame = CGRectMake(0, 35, 320, 75);
            line.frame = CGRectMake(0, 74, 320, 1);
            imv.frame = CGRectMake(80, 25, 30, 30);
            
            //内容label
            _gspeedLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+5, imv.frame.origin.y-5, 90, 35)];
            _gspeedLabel.font = [UIFont systemFontOfSize:25];
//            _gspeedLabel.backgroundColor = [UIColor orangeColor];
            _gspeedLabel.text = @"0.00";
            _gspeedLabel.textAlignment = NSTextAlignmentCenter;
            [customView addSubview:_gspeedLabel];
            
            //计量单位
            UILabel *danweiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_gspeedLabel.frame)+5, _gspeedLabel.frame.origin.y+5, 70, 30)];
            danweiLabel.text = @"公里/时";
            [customView addSubview:danweiLabel];
            
        }else if (i == 2){//计时
            customView.frame = CGRectMake(0, 110, 160, 75);
            line.frame = CGRectMake(0, 74, 160, 1);
            line1.frame = CGRectMake(159, 0, 1, 75);
            imv.frame = CGRectMake(10, 25, 30, 30);
            
            //内容label
            _gstartimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+5, imv.frame.origin.y-5, 100, 35)];
            _gstartimeLabel.text = @"00:00:00";
            _gstartimeLabel.font = [UIFont systemFontOfSize:25];
            _gstartimeLabel.textAlignment = NSTextAlignmentCenter;
            [customView addSubview:_gstartimeLabel];
            
            
            
        }else if (i == 3){//公里
            customView.frame = CGRectMake(160, 110, 160, 75);
            line.frame = CGRectMake(0, 74, 160, 1);
            imv.frame = CGRectMake(10, 25, 30, 30);
            
            //内容label
            _gongliLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+5, imv.frame.origin.y-5, 70, 35)];
            _gongliLabel.font = [UIFont systemFontOfSize:25];
            _gongliLabel.textAlignment = NSTextAlignmentCenter;
            _gongliLabel.text = @"0.00";
            [customView addSubview:_gongliLabel];
            
            //计量单位
            UILabel *danweiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_gongliLabel.frame)+5, imv.frame.origin.y, 40, 30)];
            danweiLabel.text = @"公里";
            [customView addSubview:danweiLabel];
            
        }else if (i == 4){//海拔
            customView.frame = CGRectMake(0, 185, 160, 75);
            line.frame = CGRectMake(0, 74, 160, 1);
            line1.frame = CGRectMake(159, 0, 1, 75);
            imv.frame = CGRectMake(10, 25, 30, 30);
            
            _ghaibaLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+5, imv.frame.origin.y-5, 50, 35)];
            _ghaibaLabel.text = @"00";
            _ghaibaLabel.font = [UIFont systemFontOfSize:25];
            _ghaibaLabel.textAlignment = NSTextAlignmentCenter;
            [customView addSubview:_ghaibaLabel];
            
            UILabel *danweiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_ghaibaLabel.frame)+5, imv.frame.origin.y, 40, 30)];
            danweiLabel.text = @"米";
            [customView addSubview:danweiLabel];
            
            
        }else if (i == 5){//bpm
            customView.frame = CGRectMake(160, 185, 160, 75);
            line.frame = CGRectMake(0, 74, 160, 1);
            imv.frame = CGRectMake(10, 25, 30, 30);
            
            _gbpmLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame)+5, imv.frame.origin.y-5, 50, 35)];
            _gbpmLabel.text = @"00";
            _gbpmLabel.font = [UIFont systemFontOfSize:25];
            _gbpmLabel.textAlignment = NSTextAlignmentCenter;
            [customView addSubview:_gbpmLabel];
            
            UILabel *danweiLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_gbpmLabel.frame)+5, imv.frame.origin.y, 40, 30)];
            danweiLabel.text = @"bpm";
            [customView addSubview:danweiLabel];
        }
        
        
        [_upview addSubview:customView];
    }
    
    [_upview addSubview:_upOrDownBtn];
    [self.view addSubview:_upview];
    
    
    
    
    
    //开始运动时下方view
    _downView = [[UIView alloc]initWithFrame:CGRectMake(0, iPhone5?(568-50):(480-50), 320, 50)];
    _downView.backgroundColor = [UIColor whiteColor];
    _downView.hidden = YES;
    
    
    //返回按钮
    UIButton *returnBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [returnBackBtn setFrame:CGRectMake(0, 0, 80, 50)];
    [returnBackBtn setImage:[UIImage imageNamed:@"gback160x98.png"] forState:UIControlStateNormal];
    [returnBackBtn addTarget:self action:@selector(gGoBack) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:returnBackBtn];
    
    //完成按钮
    UIButton *redFinishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [redFinishBtn setFrame:CGRectMake(80, 0, 80, 50)];

    [redFinishBtn setImage:[UIImage imageNamed:@"gfinish.png"] forState:UIControlStateNormal];
    
    [redFinishBtn addTarget:self action:@selector(gFinish) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:redFinishBtn];
    
    //暂停按钮
    _greenTimeOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_greenTimeOutBtn setFrame:CGRectMake(160, 0, 80, 50)];
    
    [_greenTimeOutBtn setImage:[UIImage imageNamed:@"gtimeout.png"] forState:UIControlStateNormal];
    [_greenTimeOutBtn addTarget:self action:@selector(gTimeOut) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:_greenTimeOutBtn];
    
    //拍照按钮
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePhotoBtn setFrame:CGRectMake(240, 0, 80, 50)];
    [takePhotoBtn setImage:[UIImage imageNamed:@"gtakephoto.png"] forState:UIControlStateNormal];
    [takePhotoBtn addTarget:self action:@selector(goToOffLineMapTable) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_downView addSubview:takePhotoBtn];
    
    [self.view addSubview:_downView];
    
    
    
    //计时器
    timer = [NSTimer scheduledTimerWithTimeInterval:(0.01)
                                             target:self
                                           selector:@selector(taktCounter)
                                           userInfo:nil
                                            repeats:TRUE];
    NSRunLoop *main = [NSRunLoop currentRunLoop];
    [main addTimer:timer forMode:NSRunLoopCommonModes];
    
    
    
    
//    [self initHistoryMap];
    
}

//路书跳转过来的通知方法
-(void)newBilityXiaoPang:(NSNotification*)thenotification{
    NSDictionary *notiInfo = thenotification.userInfo;
    
    NSLog(@"%@",notiInfo);
    
     [self.mapView removeOverlays:_lines];
    [self.mapView removeAnnotation:startAnnotation];
    [self.mapView removeAnnotation:detinationAnnotation];
    
    [self initHistoryMapWithDic:notiInfo];
    
}

//计时器
- (void) taktCounter
{
    //    NSLog(@"taktCounter is called");
    NSInteger timerMin = 0;
    NSInteger timerSecond = 0;
    NSInteger timerMSecond = 0;
    NSInteger timerMMSecond = 0;
    
    NSInteger splitTimerMin = 0;
    NSInteger splitTimerSecond = 0;
    NSInteger splitTimerMSecond = 0;
    NSInteger splitTimerMMSecond = 0;
    
    if (started)
    {
        totalTakt++;
        lapTakt++;
        
        if (totalTakt == 594000) {
            totalTakt = 0;
        }
        if (lapTakt == 594000) {
            lapTakt = 0;
        }
        
        if(splitted)
        {
            lapTakt = 0;
            [_gstartimeLabel setText:@"00:00.00"];
            splitted = NO;
        }
        
        timerMMSecond = totalTakt % 10;
        timerMSecond = totalTakt / 10 % 10;
        timerSecond = totalTakt / 100;
        timerMin = totalTakt / 6000;
        
        splitTimerMMSecond = lapTakt % 10;
        splitTimerMSecond = lapTakt / 10 % 10;
        splitTimerSecond = lapTakt / 100;
        splitTimerMin = lapTakt / 6000;
        
        if (timerSecond < 10) {
            if (timerMin < 10) {
                _gstartimeLabel.text = [[NSString alloc]initWithFormat:@"0%d:0%d.%d%d", timerMin, timerSecond, timerMSecond, timerMMSecond];
            }
            else {
                _gstartimeLabel.text = [[NSString alloc]initWithFormat:@"%d:0%d.%d%d", timerMin, timerSecond, timerMSecond, timerMMSecond];
            }
        }
        else {
            if (timerMin < 10) {
                _gstartimeLabel.text = [[NSString alloc]initWithFormat:@"0%d:%d.%d%d", timerMin, timerSecond, timerMSecond, timerMMSecond];
            }
            else {
                _gstartimeLabel.text = [[NSString alloc]initWithFormat:@"%d:%d.%d%d", timerMin, timerSecond, timerMSecond, timerMMSecond];
            }
        }
        
        if (splitTimerSecond < 10) {
            if (splitTimerMin < 10) {
                _gstartimeLabel.text = [[NSString alloc]initWithFormat:@"0%d:0%d.%d%d", splitTimerMin, splitTimerSecond, splitTimerMSecond, splitTimerMMSecond];
            }
            else {
                _gstartimeLabel.text = [[NSString alloc]initWithFormat:@"%d:0%d.%d%d", splitTimerMin, splitTimerSecond, splitTimerMSecond, splitTimerMMSecond];
            }
        }
        else {
            if (splitTimerMin < 10) {
                _gstartimeLabel.text = [[NSString alloc]initWithFormat:@"0%d:%d.%d%d", splitTimerMin, splitTimerSecond, splitTimerMSecond, splitTimerMMSecond];
            }
            else {
                _gstartimeLabel.text = [[NSString alloc]initWithFormat:@"%d:%d.%d%d", splitTimerMin, splitTimerSecond, splitTimerMSecond, splitTimerMMSecond];
            }
        }
        
    }
    else{
        if (reset == YES) {
            [_gstartimeLabel setText:@"00:00.00"];
            started = NO;
            splitted = NO;
            totalTakt = 0;
            lapTakt = 0;
            splitTimes = 0;
            reset = NO;
        }
    }
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 暂停按钮
-(void)gTimeOut{
    _isTimeOutClicked = !_isTimeOutClicked;
    if (_isTimeOutClicked) {
        self.mapView.showsUserLocation = NO;
        started = NO;
        [_greenTimeOutBtn setImage:[UIImage imageNamed:@"ghuifu.png"] forState:UIControlStateNormal];
    }else{
        self.mapView.showsUserLocation = YES;
        started = YES;
        [_greenTimeOutBtn setImage:[UIImage imageNamed:@"gtimeout.png"] forState:UIControlStateNormal];
        
    }
    
}


#pragma mark - 返回按钮
-(void)gGoBack{
    _downView.hidden = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"gkeepstarting" object:nil];
    [self hideTabBar:NO];
}


#pragma mark - 跳转到离线地图下载
-(void)goToOffLineMapTable{
    
}

#pragma mark - 行走完成

-(void)gFinish{
    started = NO;
    UIActionSheet *actionsheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"放弃记录" otherButtonTitles:@"保存分享", nil];
    actionsheet.tag = 101;
    [actionsheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 101) {
        if (buttonIndex == 1) {//保存记录
            self.mapView.showsUserLocation = NO;
            _distance = 0.0f;
            reset = YES;//停止计时器
            _downView.hidden = YES;
            [self hideTabBar:NO];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"gstopandsave" object:nil];
        }else if (buttonIndex == 0){//放弃保存
            _distance = 0.0f;
            self.mapView.showsUserLocation = NO;
            reset = YES;//停止计时器
            _downView.hidden = YES;
            [self hideTabBar:NO];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"gstopandnosave" object:nil];
        }else if (buttonIndex == 2){//取消按钮
            if (_isTimeOutClicked) {
                started = NO;
            }else{
                started = YES;
            }
            
        }
    }
    
}



#pragma mark - 地图变大 upview上移动
-(void)gShou{
    
    if (_isUpViewShow) {
        _isUpViewShow = NO;
        [_upOrDownBtn setImage:[UIImage imageNamed:@"gbtndown.png"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^{
            _upview.frame = FRAME_IPHONE5_UPVIEW_UP;
            [self.mapView setFrame:FRAME_IPHONE5_MAP_UP];
        } completion:^(BOOL finished) {
            
        }];
    }else{
        _isUpViewShow = YES;
        [_upOrDownBtn setImage:[UIImage imageNamed:@"gbtnup.png"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^{
            _upview.frame = FRAME_IPHONE5_UPVIEW_DOWN;
            [self.mapView setFrame:FRAME_IPHONE5_MAP_DOWN];
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
    
}



#pragma mark - 地图相关内存管理 点击返回按钮vc释放的时候走
- (void)returnAction
{
    [self clearMapView];
    
    [self clearSearch];
    
}
- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
}



#pragma mark - AMapSearchDelegate

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
}



#pragma mark - Initialization 初始化Methode start=========

//初始化地图
- (void)initMapViewWithFrame:(CGRect)theFrame
{
    
    self.mapView = [Gmap sharedMap];
    [self.mapView setFrame:theFrame];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}

//初始化搜索服务
- (void)initSearch
{
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
    self.search.delegate = self;
}



#pragma mark - Initialization 初始化Method  end=========



#pragma mark - ==============长按手势start=============
- (void)initGestureRecognizer//初始化长按手势
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    
    [self.view addGestureRecognizer:longPress];
}

#pragma mark - Handle Gesture

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress//长按弹出大头针=========
{
    
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[longPress locationInView:self.view]
                                                  toCoordinateFromView:self.mapView];
        
        [self searchReGeocodeWithCoordinate:coordinate];
    }
    
    
    
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}


#pragma mark - AMapSearchDelegate

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        ReGeocodeAnnotation *reGeocodeAnnotation = [[ReGeocodeAnnotation alloc] initWithCoordinate:coordinate
                                                                                         reGeocode:response.regeocode];
        
        [self.mapView addAnnotation:reGeocodeAnnotation];
        [self.mapView selectAnnotation:reGeocodeAnnotation animated:YES];

    }
}



#pragma mark - //==============长按手势end=============






#pragma mark - 定位=============================
#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    
}


-(void)mapView:(MAMapView*)mapView didFailToLocateUserWithError:(NSError*)error{
    NSLog(@"定位失败");
}





- (void)modeAction {
    [self.mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES]; //设置 为地图跟着位置移动
}





#pragma mark - 自定义定位样式
#pragma mark - MAMapViewDelegate

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    
    
    
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    MAOverlayPathView* overlayView = nil;
    
    
//    if (overlay == mapView.userLocationAccuracyCircle)// 自定义定位精度对应的MACircleView
//    {
//        MACircleView *accuracyCircleView = [[MACircleView alloc] initWithCircle:overlay];
//        
//        accuracyCircleView.lineWidth    = 2.f;
//        accuracyCircleView.strokeColor  = [UIColor lightGrayColor];
//        accuracyCircleView.fillColor    = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
//        
//        return accuracyCircleView;
//        
//    }
    if (overlay == self.routeLine){
        
        //if we have not yet created an overlay view for this overlay, create it now.
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }
        
        self.routeLineView = [[MAPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 10;
        
        overlayView = self.routeLineView;
    }
    
    
#pragma 路书================
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        
        overlayView.lineWidth    = 5.f;
        overlayView.strokeColor  = [UIColor greenColor];
        overlayView.lineDash     = YES;
        
        return overlayView;
    }
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:(MAPolyline *)overlay];
        
        overlayView.lineWidth    = 5.f;
        overlayView.strokeColor  = [UIColor blueColor];
        
        return overlayView;
    }
    
    
    
    return overlayView;
    
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MAUserLocation class]])/* 自定义userLocation对应的annotationView. */
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        
        annotationView.image = [UIImage imageNamed:@"userPosition"];
        
        self.userLocationAnnotationView = annotationView;
        
        return annotationView;
        
        
    }else if ([annotation isKindOfClass:[ReGeocodeAnnotation class]]){//长按弹出大头针上面的详细信息页面
        
        
        static NSString *invertGeoIdentifier = @"invertGeoIdentifier";
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:invertGeoIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:invertGeoIdentifier];
        }
        
        poiAnnotationView.animatesDrop              = YES;
        poiAnnotationView.canShowCallout            = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
        
    }
    
    
#pragma - mark - 路书===============
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"navigationCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:navigationCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        
        /* 起点. */
        if ([[annotation title] isEqualToString:NavigationViewControllerStartTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_start"];
        }
        /* 终点. */
        else if([[annotation title] isEqualToString:NavigationViewControllerDestinationTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_end"];
        }
        /* 途经点. */
        else if([[annotation title] isEqualToString:NavigationViewControllerMiddleTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_middle"];
        }
        
        return poiAnnotationView;
    }
    
    
    
   
    return nil;
}





#pragma mark - 定位的回调方法
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
    
    NSLog(@"lat ====== %f",userLocation.location.coordinate.latitude);
    NSLog(@"lon ====== %f",userLocation.location.coordinate.longitude);
    
    //方向
    NSString *headingStr = @"";
    if (userLocation) {
        NSLog(@"userLocation ---- %@",userLocation);
        NSLog(@"userLocation.heading----%@",userLocation.heading);
        //地磁场方向
        double heading = userLocation.heading.magneticHeading;
        if (heading > 0) {
            headingStr = [GMAPI switchMagneticHeadingWithDoubel:heading];
        }
        NSLog(@"%@",headingStr);
        _fangxiangLabel.text = headingStr;
    }
    
    //海拔
    CLLocation *currentLocation = userLocation.location;
    if (currentLocation) {
        NSLog(@"海拔---%f",currentLocation.altitude);
        int alti = (int)currentLocation.altitude;
        _ghaibaLabel.text = [NSString stringWithFormat:@"%d",alti];
    }
    
    //自定义定位箭头方向
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
            
        }];
    }
    
    
    //给速度lable赋值
    
    NSString *hourStr = [_gstartimeLabel.text substringWithRange:NSMakeRange(0, 1)];//00.00.00
    NSString *minStr = [_gstartimeLabel.text substringWithRange:NSMakeRange(3, 2)];
    NSString *seStr = [_gstartimeLabel.text substringWithRange:NSMakeRange(6, 2)];
    
    double hour = [hourStr intValue]+([minStr floatValue]/60)+([seStr floatValue]/3600);
    NSString *speedStr = [NSString stringWithFormat:@"%.2f",_distance/hour];
    _gspeedLabel.text =  speedStr;
    
    
    
    
    
#pragma mark -  划线=======================
    
    NSLog(@"lat ====== %f",userLocation.location.coordinate.latitude);
    NSLog(@"lon ====== %f",userLocation.location.coordinate.longitude);
    
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                      longitude:userLocation.coordinate.longitude];
    // check the zero point
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    
    // check the move distance
    if (_points.count > 0) {
        CLLocationDistance distance = [location distanceFromLocation:_currentLocation];
        if (distance < 5 || distance > 10){
            return;
        }
        _distance += distance;
        NSString *str = [NSString stringWithFormat:@"公里----%f",_distance/1000];
        _gongliLabel.text = str;//给距离label赋值 单位是公里
    }
    
    if (_points == nil) {
        _points = [[NSMutableArray alloc] init];
    }
    
    [_points addObject:location];
    _currentLocation = location;
    
    NSLog(@"points: %@", _points);
    
    [self configureRoutes];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
    
    
    
    
    
}

#pragma mark - 画线
- (void)configureRoutes
{
    
    
    MAMapPoint northEastPoint = MAMapPointMake(0.0f, 0.0f);
    MAMapPoint southWestPoint = MAMapPointMake(0.0f, 0.0f);
    
    MAMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
    for(int idx = 0; idx < _points.count; idx++)
    {
        CLLocation *location = [_points objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;

        // create our coordinate and add it to the correct spot in the array
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
//        MAMapPoint point = MAMapPointMake(coordinate.latitude, coordinate.longitude);
        MAMapPoint point = MAMapPointForCoordinate(coordinate);

        // if it is the first point, just use them, since we have nothing to compare to yet.
        if (idx == 0) {
            northEastPoint = point;
            southWestPoint = point;
        } else {
            if (point.x > northEastPoint.x)
                northEastPoint.x = point.x;
            if(point.y > northEastPoint.y)
                northEastPoint.y = point.y;
            if (point.x < southWestPoint.x)
                southWestPoint.x = point.x;
            if (point.y < southWestPoint.y)
                southWestPoint.y = point.y;
        }
        
        pointArray[idx] = point;
    }
    

    
    if (self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
    }
    
    self.routeLine = [MAPolyline polylineWithPoints:pointArray count:_points.count];
    
    // add the overlay to the map
    if (nil != self.routeLine) {
        [self.mapView addOverlay:self.routeLine];
    }
    
    // clear the memory allocated earlier for the points
    free(pointArray);
    
    
}

#pragma 点击tabbar上开始按钮开始的操作
-(void)iWantToStart{
    [self hideTabBar:YES];
    _downView.hidden = NO;
    self.mapView.showsUserLocation = YES;//开启定位
    
    
    //接收到appdelegate通知 开始骑行 下面这个是判断 是否为暂停后点击返回然后再点击开始骑行进入的
    if (_isTimeOutClicked) {
        
    }else{
        started = YES;
    }
    
}



#pragma mark - 隐藏或显示tabbar
- (void)hideTabBar:(BOOL) hidden{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, iPhone5 ? 568 : 480 , view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, iPhone5 ? (568-49):(480-49), view.frame.size.width, view.frame.size.height)];
            }
        }
        else
        {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 320)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 320-49)];
            }
        }
    }
    
    [UIView commitAnimations];
}








//牛逼的小胖===============
- (void)initHistoryMapWithDic:(NSDictionary*)dic
{
    
    NSString *index = [dic objectForKey:@"road_index"];
    int indexx = [index intValue];
    NSString *key = [NSString stringWithFormat:@"road_%d",indexx];
    
    NSArray *arr = [LTools cacheForKey:key];
    
    if (arr.count == 0) {
        return;
    }
    
    NSDictionary *history_dic = [LMapTools parseMapHistoryMap:arr];
    
    _lines = [history_dic objectForKey:L_POLINES];
    NSArray *start_arr = [history_dic objectForKey:L_START_POINT_COORDINATE];
    NSArray *end_arr = [history_dic objectForKey:L_END_POINT_COORDINATE];
    
    self.startCoordinate = CLLocationCoordinate2DMake([[start_arr objectAtIndex:0] floatValue], [[start_arr objectAtIndex:1] floatValue]);
    [self addStartAnnotation];
    
    self.destinationCoordinate = CLLocationCoordinate2DMake([[end_arr objectAtIndex:0] floatValue], [[end_arr objectAtIndex:1] floatValue]);
    [self addDestinationAnnotation];
    
    [self.mapView addOverlays:_lines];
    
    [self.mapView setCenterCoordinate:self.startCoordinate animated:YES];
    
    
}



#pragma mark 添加\取消 标志

//起点
- (void)addStartAnnotation
{
    if (startAnnotation) {
        
        [self.mapView removeAnnotation:startAnnotation];
    }
    
    startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = NavigationViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    [self.mapView addAnnotation:startAnnotation];
}
- (void)removeStartAnnotation
{
    [self.mapView removeAnnotation:startAnnotation];
    
    self.startCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    [self removeAllPolines];
}

- (void)removeAllPolines
{
    if (middleAnntations.count == 0 && self.startCoordinate.latitude == 0 && self.destinationCoordinate.latitude == 0){
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        [self.mapView removeOverlays:self.mapView.overlays];
    }
}

//终点
- (void)addDestinationAnnotation
{
    if (detinationAnnotation) {
        [self.mapView removeAnnotation:detinationAnnotation];
    }
    
    detinationAnnotation = [[MAPointAnnotation alloc] init];
    detinationAnnotation.coordinate = self.destinationCoordinate;
    detinationAnnotation.title      = (NSString*)NavigationViewControllerDestinationTitle;
    detinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    
    [self.mapView addAnnotation:detinationAnnotation];
}

- (void)removeDestinationAnnotation
{
    [self.mapView removeAnnotation:detinationAnnotation];
    
    self.destinationCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    [self removeAllPolines];
}

//中间点
- (void)addMiddleAnnotation:(CLLocationCoordinate2D)midCoordinate
{
    MAPointAnnotation *midAnnotation = [[MAPointAnnotation alloc] init];
    midAnnotation.coordinate = midCoordinate;
    midAnnotation.title      = (NSString*)NavigationViewControllerMiddleTitle;
    midAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", midCoordinate.latitude, midCoordinate.longitude];
    [self.mapView addAnnotation:midAnnotation];
    
    [middleAnntations addObject:midAnnotation];
}




@end
