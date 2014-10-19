//
//  RoadProduceController.m
//  OneTheBike
//
//  Created by lichaowei on 14-10-18.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "RoadProduceController.h"
#import "CommonUtility.h"
#import "LineDashPolyline.h"
#import "ReGeocodeAnnotation.h"

const NSString *NavigationViewControllerStartTitle       = @"起点";
const NSString *NavigationViewControllerDestinationTitle = @"终点";

enum{
    OverlayViewControllerOverlayTypeCircle = 0,
    OverlayViewControllerOverlayTypeCommonPolyline,
    OverlayViewControllerOverlayTypePolygon,
    OverlayViewControllerOverlayTypeTexturePolyline,
    OverlayViewControllerOverlayTypeArrowPolyline
    
};


enum{
    Point_Start = 1,//起点
    Point_Middle,//途
    Point_End //终点
};

@interface RoadProduceController ()
{
    int point_state;
}

@property (nonatomic, strong) AMapRoute *route;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;


@property (nonatomic, strong) NSMutableArray *overlays;


@end

@implementation RoadProduceController

@synthesize mapView = _mapView;
@synthesize search  = _search;

@synthesize overlays = _overlays;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *spaceButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton1.width = IOS7_OR_LATER ? - 7 : 7;
    
    UIButton *settings=[[UIButton alloc]initWithFrame:CGRectMake(20,8,40,20)];
    [settings addTarget:self action:@selector(clickToSave:) forControlEvents:UIControlEventTouchUpInside];
    [settings setTitle:@"保存" forState:UIControlStateNormal];
    [settings.titleLabel setFont:[UIFont systemFontOfSize:12]];
    settings.layer.cornerRadius = 3.f;
    [settings setBackgroundColor:[UIColor colorWithHexString:@"bebebe"]];
    UIBarButtonItem *right =[[UIBarButtonItem alloc]initWithCustomView:settings];
    self.navigationItem.rightBarButtonItems = @[spaceButton1,right];
    
    self.titleLabel.text = @"路书制作";
    
    [self initMap];
    
    [self createTools];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Initialization

//地图

- (void)initMap
{
//    self.startCoordinate        = CLLocationCoordinate2DMake(39.910267, 116.370888);
//    self.destinationCoordinate  = CLLocationCoordinate2DMake(39.989872, 116.481956);
    
    [self initMapView];
    
    [self initSearch];
    
    [self initGestureRecognizer];
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    self.mapView.showsUserLocation = YES;//开启定位
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;//自定义定位样式
    self.mapView.userTrackingMode = MAUserTrackingModeNone;//定位模式
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}

- (void)initSearch
{
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:@"0b92a81f23cc5905c30dcb4c39da609d" Delegate:nil];
    self.search.delegate = self;
}

//==============长按手势start=============
- (void)initGestureRecognizer//初始化长按手势
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    
    [self.view addGestureRecognizer:longPress];
}


#pragma mark - 数据解析

#pragma mark - 网络请求

#pragma mark - 视图创建

- (void)createTools
{
   CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *tools = [[UIView alloc]initWithFrame:CGRectMake(0, screenSize.height - 50 - 50 - 64, screenSize.width, 50)];
    tools.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tools];
    NSArray *titls_arr = @[@"取消",@"起",@"途",@"终",@"生成"];
    
    for (int i = 0; i < 5; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake((screenSize.width - 50 * 5)/2.f + 50 * i, 0, 50, 50);
        [btn setTitle:[titls_arr objectAtIndex:i] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        
        [btn setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btn setTitleShadowColor:[UIColor redColor] forState:UIControlStateSelected];
        
        btn.tag = 100 + i;
        [tools addSubview:btn];
        [btn addTarget:self action:@selector(clickToActionMap:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - 事件处理

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

- (void)clickToSave:(UIButton *)sender
{
    
}

- (void)clickToActionMap:(UIButton *)sender
{
    switch (sender.tag - 100) {
        case 0:
        {
            NSLog(@"取消");
        }
            break;
        case 1:
        {
            NSLog(@"起");
            point_state = Point_Start;
            
            [LTools showMBProgressWithText:@"长按选择起点" addToView:self.view];
        }
            break;
        case 2:
        {
            NSLog(@"途");
            point_state = Point_Middle;
            [LTools showMBProgressWithText:@"长按选择途经点" addToView:self.view];
        }
            break;
        case 3:
        {
            NSLog(@"终");
            point_state = Point_End;
            [LTools showMBProgressWithText:@"长按选择终点" addToView:self.view];
        }
            break;
        case 4:
        {
            NSLog(@"生成");
            
            [self searchNaviWalk];
        }
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i < 5; i ++) {
        
        UIButton *btn = (UIButton *)[self.view viewWithTag:100 + i];
        
        if (btn == sender) {
            sender.selected = YES;
        }else
        {
            sender.selected = NO;
        }
    }
}

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearMapView];
    
    [self clearSearch];
}


//手势处理

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress//长按弹出大头针=========
{
    
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[longPress locationInView:self.view]
                                                  toCoordinateFromView:self.mapView];
        
        [self searchReGeocodeWithCoordinate:coordinate];
        
        if (point_state == Point_Start) {
            
            self.startCoordinate = coordinate;
            
            [self addStartAnnotation];
            
        }else if (point_state == Point_End){
            
            self.destinationCoordinate = coordinate;
            
            [self addDestinationAnnotation];
            
        }else if (point_state == Point_Middle){
            
            NSLog(@"途经点");
        }
    }
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}

//导航搜索

- (void)searchNaviWalk {
    
    if (self.startCoordinate.latitude == 0) {
        
        [LTools showMBProgressWithText:@"请选择起点" addToView:self.view];
        return;
    }
    
    if (self.destinationCoordinate.latitude == 0) {
        
        [LTools showMBProgressWithText:@"请选择终点" addToView:self.view];
        return;
    }
    
    AMapNavigationSearchRequest *navi = [[AMapNavigationSearchRequest alloc] init];
    navi.searchType       = AMapSearchType_NaviWalking;
    navi.requireExtension = YES;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    [self.search AMapNavigationSearch:navi];
}

- (void)addStartAnnotation
{
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title      = (NSString*)NavigationViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    [self.mapView addAnnotation:startAnnotation];
}

//添加
- (void)addDestinationAnnotation
{
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title      = (NSString*)NavigationViewControllerDestinationTitle;
    destinationAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    
    [self.mapView addAnnotation:destinationAnnotation];
}

#pragma mark - delegate


#pragma mark - AMapSearchDelegate<NSObject>

/*!
 当请求发生错误时，会调用代理的此方法.
 @param request 发生错误的请求.
 @param error   返回的错误.
 */

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
}

- (void)search:(id)searchRequest error:(NSString *)errInfo __attribute__ ((deprecated("use -search:didFailWithError instead.")))
{
    
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

/*!
 @brief 路径规划查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapNavigationSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapNavigationSearchResponse类中的定义)
 */
- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response
{
    
    NSLog(@"response %@",response);
    self.route = response.route;
    
    self.currentCourse = 0;
    
    NSArray *polylines = [CommonUtility polylinesForPath:self.route.paths[self.currentCourse]];
    
    [self.mapView addOverlays:polylines];
    
    /* 缩放地图使其适应polylines的展示. */
    self.mapView.visibleMapRect = [CommonUtility mapRectForOverlays:polylines];
}

#pragma mark - MAMapViewDelegate

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        
        overlayView.lineWidth    = 1;
        overlayView.strokeColor  = [UIColor magentaColor];
        overlayView.lineDash     = YES;
        
        return overlayView;
    }
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        overlayView.lineWidth    = 5.f;
        overlayView.strokeColor  = [UIColor blueColor];
        
        return overlayView;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
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
        if ([[annotation title] isEqualToString:(NSString*)NavigationViewControllerStartTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"redPin"];
        }
        /* 终点. */
        else if([[annotation title] isEqualToString:(NSString*)NavigationViewControllerDestinationTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"greenPin"];
        }
        
        return poiAnnotationView;
    }else if ([annotation isKindOfClass:[MAUserLocation class]])/* 自定义userLocation对应的annotationView. */
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

//定位=============================
#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    
}


-(void)mapView:(MAMapView*)mapView didFailToLocateUserWithError:(NSError*)error{
    NSLog(@"定位失败");
}

//定位的回调方法
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
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
    
}


@end
