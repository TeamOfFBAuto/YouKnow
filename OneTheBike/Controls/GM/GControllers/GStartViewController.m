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

#define FRAME_IPHONE5_MAP_UP CGRectMake(0, 60, 320, 568-60-20)
#define FRAME_IPHONE5_MAP_DOWN CGRectMake(0, 260+20, 320, 568-260-20)
#define FRAME_IPHONE5_UPVIEW_UP CGRectMake(0, -200, 320, 260)
#define FRAME_IPHONE5_UPVIEW_DOWN CGRectMake(0, 20, 320, 260)

@interface GStartViewController ()
{
    UIView *_upview;//上面的运动信息view
    BOOL _isUpViewShow;//当前是否显示运动信息view
    UIButton *_upOrDownBtn;//上下收放btn
    UIView *_downView;//运动开始时下方的view
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
    
    //接受通知隐藏tabbar
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(iWantToStart) name:@"GToGstar" object:nil];
    
    
    //地图上面的view
    _isUpViewShow = YES;
    _upview = [[UIView alloc]initWithFrame:FRAME_IPHONE5_UPVIEW_DOWN];
    _upview.backgroundColor = [UIColor whiteColor];
    
    //上下按钮
    _upOrDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _upOrDownBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_upOrDownBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_upOrDownBtn setTitle:@"up" forState:UIControlStateNormal];
    [_upOrDownBtn setFrame:CGRectMake(140, 230, 40, 42)];
    [_upOrDownBtn setBackgroundColor:[UIColor orangeColor]];
    [_upOrDownBtn addTarget:self action:@selector(gShou) forControlEvents:UIControlEventTouchUpInside];
    
    for (int i = 0; i<6; i++) {
        UIView *view = [[UIView alloc]init];
        if (i == 0) {//上面灰条
            view.frame = CGRectMake(0, 0, 320, 35);
            view.backgroundColor = RGBCOLOR(105, 105, 105);
        }else if (i == 1){//公里/时
            view.frame = CGRectMake(0, 35, 320, 75);
            view.backgroundColor = [UIColor orangeColor];
            
        }else if (i == 2){//计时
            view.frame = CGRectMake(0, 110, 160, 75);
            view.backgroundColor = [UIColor blueColor];
        }else if (i == 3){//公里
            view.frame = CGRectMake(160, 110, 160, 75);
            view.backgroundColor = [UIColor redColor];
        }else if (i == 4){//海拔
            view.frame = CGRectMake(0, 185, 160, 75);
            view.backgroundColor = [UIColor greenColor];
        }else if (i == 5){//bpm
            view.frame = CGRectMake(160, 185, 160, 75);
            view.backgroundColor = [UIColor yellowColor];
        }
        
        
        [_upview addSubview:view];
    }
    
    [_upview addSubview:_upOrDownBtn];
    [self.view addSubview:_upview];
    
    
    
    
    //地图相关初始化
    [self initMapViewWithFrame:CGRectMake(0, CGRectGetMaxY(_upview.frame), 320, 568 - _upview.frame.size.height)];
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
    
    [self initGestureRecognizer];//长按手势
    
    [self.mapView addOverlays:self.overlays];//把线条添加到地图上
    
    [self configureRoutes];//划线
    
    
    
    
    //开始运动时下方view
    _downView = [[UIView alloc]initWithFrame:CGRectMake(0, 568-50, 320, 50)];
    _downView.backgroundColor = [UIColor purpleColor];
    _downView.hidden = YES;
    
    //完成按钮
    UIButton *redFinishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 130, 50)];
    redFinishBtn.backgroundColor = RGBCOLOR(220, 134, 127);
    [redFinishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [redFinishBtn addTarget:self action:@selector(gFinish) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:redFinishBtn];
    
    //暂停按钮
    UIButton *greenTimeOutBtn = [[UIButton alloc]initWithFrame:CGRectMake(130, 0, 140, 50)];
    greenTimeOutBtn.backgroundColor = RGBCOLOR(174, 221, 177);
    [greenTimeOutBtn setTitle:@"暂停" forState:UIControlStateNormal];
    [greenTimeOutBtn addTarget:self action:@selector(goToOffLineMapTable) forControlEvents:UIControlEventTouchUpInside];
    [_downView addSubview:greenTimeOutBtn];
    
    //拍照按钮
    UIView *takePhotoView = [[UIView alloc]initWithFrame:CGRectMake(260, 0, 60, 50)];
    takePhotoView.backgroundColor = [UIColor grayColor];
    [_downView addSubview:takePhotoView];
    
    [self.view addSubview:_downView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 跳转到离线地图下载
-(void)goToOffLineMapTable{
    GOffLineMapViewController *detailViewController = [[GOffLineMapViewController alloc] init];
    detailViewController.mapView = self.mapView;
    
    detailViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    
    [self presentModalViewController:navi animated:YES];
}

#pragma mark - 行走完成

-(void)gFinish{
    self.mapView.showsUserLocation = NO;
    _downView.hidden = YES;
    [self hideTabBar:NO];
}


#pragma mark - 地图变大 upview上移动
-(void)gShou{
    
    if (_isUpViewShow) {
        _isUpViewShow = NO;
        [_upOrDownBtn setTitle:@"down" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^{
            _upview.frame = FRAME_IPHONE5_UPVIEW_UP;
            [self.mapView setFrame:FRAME_IPHONE5_MAP_UP];
        } completion:^(BOOL finished) {
            
        }];
    }else{
        _isUpViewShow = YES;
        [_upOrDownBtn setTitle:@"up" forState:UIControlStateNormal];
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
    self.mapView = [[MAMapView alloc]initWithFrame:theFrame];
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
    }
    
    //海拔
    CLLocation *currentLocation = userLocation.location;
    if (currentLocation) {
        NSLog(@"海拔---%f",currentLocation.altitude);
    }
    
    //自定义定位箭头方向
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
            
        }];
    }
    
    
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
        if (distance < 5)
            return;
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
                [view setFrame:CGRectMake(view.frame.origin.x, 568, view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, 568-49, view.frame.size.width, view.frame.size.height)];
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



@end
