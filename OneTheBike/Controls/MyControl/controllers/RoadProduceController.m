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

#import "NSObject+MJKeyValue.h"

#import "MAPolyline+UN.h"

#import "MapCacheDashClass.h"

#import "AppDelegate.h"

const NSString *NavigationViewControllerStartTitle       = @"起点";
const NSString *NavigationViewControllerDestinationTitle = @"终点";
const NSString *NavigationViewControllerMiddleTitle      = @"途经点";

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
    
    NSMutableArray *middle_points_arr;
    
    NSMutableArray *polines_arr;//存储线
    
    UILongPressGestureRecognizer *longPress;
    
    int point_index;
    
    MAPointAnnotation *startAnnotation;//起点
    MAPointAnnotation *detinationAnnotation;//终点
    NSMutableArray *middleAnntations;//途经点
    
    BOOL save_finish;//是否保存成功
    BOOL nav_walk_finish;//生成是否成功
    
    NSString *startName;//起点名字
    NSString *endName;//终点名字
    
    UIImageView *centerImage;//中间点
}

@property (nonatomic, strong) AMapRoute *route;

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;


@end

@implementation RoadProduceController

@synthesize mapView = _mapView;
@synthesize search  = _search;

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
    
    middle_points_arr = [NSMutableArray array];//途经点 AMapGeoPoint
    polines_arr = [NSMutableArray array];//所有的规划线
    middleAnntations = [NSMutableArray array];//途经点 Annotation
    point_index = 0;
    save_finish = NO;
    nav_walk_finish = NO;
    
    [self initHistoryMap];
    
    CGSize aSize = [UIScreen mainScreen].bounds.size;
    centerImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"road_select"]];
    centerImage.center = CGPointMake(aSize.width / 2.f, aSize.height / 2.f - 64);
    [self.view addSubview:centerImage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickToBack:(id)sender
{
    if (save_finish || polines_arr.count == 0) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"路书未保存" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if(buttonIndex == 1){
        
        [self clickToSave:nil];
    }
}

#pragma mark - 历史轨迹

- (void)initHistoryMap
{
    NSString *key = [NSString stringWithFormat:@"road_%d",self.road_index];
    
    NSArray *arr = [LTools cacheForKey:key];
    
    if (arr.count == 0) {
        return;
    }
    
    NSDictionary *history_dic = [LMapTools parseMapHistoryMap:arr];
    
    NSArray *lines = [history_dic objectForKey:L_POLINES];
    NSArray *start_arr = [history_dic objectForKey:L_START_POINT_COORDINATE];
    NSArray *end_arr = [history_dic objectForKey:L_END_POINT_COORDINATE];
    
    self.startCoordinate = CLLocationCoordinate2DMake([[start_arr objectAtIndex:0] floatValue], [[start_arr objectAtIndex:1] floatValue]);
    [self addStartAnnotation];
    
    self.destinationCoordinate = CLLocationCoordinate2DMake([[end_arr objectAtIndex:0] floatValue], [[end_arr objectAtIndex:1] floatValue]);
    [self addDestinationAnnotation];
    
    [self.mapView addOverlays:lines];
    
    [self.mapView setCenterCoordinate:self.startCoordinate animated:YES];

    
//    NSMutableArray *pp = [NSMutableArray array];//所有的规划线
//    
//    double start_x = 0.0;
//    double start_y = 0.0;
//    double end_x = 0.0;
//    double end_y = 0.0;
//    
//    if (arr.count > 0) {
//        NSArray *object_arr = [MapCacheDashClass objectArrayWithKeyValuesArray:arr];
//        
//        for (int i = 0; i < object_arr.count; i ++) {
//            MapCacheDashClass *cache = [object_arr objectAtIndex:i];
//            
//            if (i == 0) {
//                
//                start_x = [[cache.polyline objectForKey:@"rect_x"]doubleValue];
//                start_y = [[cache.polyline objectForKey:@"rect_y"]doubleValue];
//                
//                self.startCoordinate = CLLocationCoordinate2DMake(cache.latitude, cache.longitude);
//                [self addStartAnnotation];
//            }
//            
//            if (i == object_arr.count - 1) {
//                end_x = [[cache.polyline objectForKey:@"rect_x"]doubleValue];
//                end_y = [[cache.polyline objectForKey:@"rect_y"]doubleValue];
//                
//                self.destinationCoordinate = CLLocationCoordinate2DMake(cache.latitude, cache.longitude);
//                [self addDestinationAnnotation];
//            }
//            
//            NSString *type = cache.classType;
//            
//            if ([type isEqualToString:TYPE_MAPolyline]) {
//                
//                NSUInteger count = cache.pointCount;
//                CLLocationCoordinate2D *temp = [CommonUtility coordinatesForString:cache.coordinatesString coordinateCount:&count parseToken:@","];
//                MAPolyline *line2 = [MAPolyline polylineWithCoordinates:temp count:cache.pointCount];
//                [pp addObject:line2];
//                
//            }else if ([type isEqualToString:TYPE_LineDashPolyline]){
//                
//                NSDictionary *polyline = cache.polyline;
//                MAMapPoint point = MAMapPointMake([[polyline valueForKey:@"pointX"] doubleValue], [[polyline valueForKey:@"pointY"] doubleValue]);
//                
//                MAPolyline *line = [MAPolyline polylineWithPoints:&point count:cache.pointCount];
//                LineDashPolyline *line_Dash = [[LineDashPolyline alloc]initWithPolyline:line];
//                
//                line_Dash.coordinate = CLLocationCoordinate2DMake(cache.latitude, cache.longitude);
//                double x = [[cache.polyline objectForKey:@"rect_x"]doubleValue];
//                double y = [[cache.polyline objectForKey:@"rect_y"]doubleValue];
//                double w = [[cache.polyline objectForKey:@"rect_width"]doubleValue];
//                double h = [[cache.polyline objectForKey:@"rect_height"]doubleValue];
//                
//                line_Dash.boundingMapRect = MAMapRectMake(x, y, w, h);
//                
//                [pp addObject:line_Dash];
//            }
//        }
    
//        [self.mapView addOverlays:pp];
//        /* 缩放地图使其适应polylines的展示. */
//        //        self.mapView.visibleMapRect = [CommonUtility mapRectForOverlays:pp];
//        
//        [self.mapView setCenterCoordinate:self.startCoordinate animated:YES];
    
//    }

}

#pragma mark - Initialization

//地图

- (void)initMap
{
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
    longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5;
    
    longPress.enabled = NO;//默认关闭
    
    [self.view addGestureRecognizer:longPress];
}


#pragma mark - 数据解析

#pragma mark - 网络请求

#pragma mark - 视图创建

- (void)createTools
{
   CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *tools = [[UIView alloc]initWithFrame:CGRectMake(0, screenSize.height - 50 - 50 - 64, screenSize.width, 50)];
    tools.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tools];
//    NSArray *titls_arr = @[@"取消",@"起",@"途",@"终",@"生成"];
    
    NSArray *images_arr = @[@"road_cancel",@"road_start",@"road_middle",@"road_end",@"road_produce"];
    
    for (int i = 0; i < 5; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((screenSize.width - 50 * 5)/2.f + 50 * i, 0, 50, 50);
        [btn setImage:[UIImage imageNamed:[images_arr objectAtIndex:i]] forState:UIControlStateNormal];
        
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
    NSLog(@"polines_arr %@",polines_arr);
    
//    LineDashPolyline
//    MAPolyline
    
    if (nav_walk_finish == NO) {
        
        [LTools showMBProgressWithText:@"请先制作路书" addToView:self.view];
        return;
    }
    
    if (save_finish == YES) {
        
        [LTools showMBProgressWithText:@"路书保存成功" addToView:self.view];
        return;
    }
    
//    NSMutableArray *polyline_arr = [NSMutableArray array];
//    
//    for (int i = 0; i < polines_arr.count; i ++) {
//        
//        id pp = [polines_arr objectAtIndex:i];
//        if ([pp isKindOfClass:[MAPolyline class]]) {
//            
//            MAPolyline *temp = (MAPolyline *)pp;
//            MapCacheDashClass *cache = [[MapCacheDashClass alloc]initWithMapPointX:temp.points->x pointY:temp.points->y pointCount:temp.pointCount type:TYPE_MAPolyline];
//            
//            cache.rect_x = temp.boundingMapRect.origin.x;
//            cache.rect_y = temp.boundingMapRect.origin.y;
//            cache.rect_width = temp.boundingMapRect.size.width;
//            cache.rect_height = temp.boundingMapRect.size.height;
//            
//            cache.latitude = temp.coordinate.latitude;
//            cache.longitude = temp.coordinate.longitude;
//            
//            NSLog(@"ffffffff ---> %f  %f",temp.boundingMapRect.origin.x,temp.boundingMapRect.origin.y);
//            
//            CLLocationCoordinate2D tempCoor[temp.pointCount];
//            
//            NSMutableArray *point_cor_arr = [NSMutableArray arrayWithCapacity:temp.pointCount * 2];
//            
//            [temp getCoordinates:tempCoor range:NSMakeRange(0, temp.pointCount)];
//            
//            for (int i = 0; i < temp.pointCount; i ++) {
//                CLLocationCoordinate2D temp = tempCoor[i];
//                
//                [point_cor_arr addObject:[NSString stringWithFormat:@"%f",temp.longitude]];
//                [point_cor_arr addObject:[NSString stringWithFormat:@"%f",temp.latitude]];
//                
//                NSLog(@"lat: %f long :%f",temp.latitude,temp.longitude);
//            }
//            
//            cache.coordinatesString = [point_cor_arr componentsJoinedByString:@","];
//            
//            [polyline_arr addObject:cache];
//        }
//        if ([pp isKindOfClass:[LineDashPolyline class]]) {
//            
//            LineDashPolyline *temp = (LineDashPolyline *)pp;
//            MapCacheDashClass *dashCache = [[MapCacheDashClass alloc]initWithCoordinate:temp.coordinate rect:temp.boundingMapRect polyline:temp.polyline type:TYPE_LineDashPolyline];
//            
//            [polyline_arr addObject:dashCache];
//        }
//    }
//    
//    NSArray *dic_arr = [MapCacheDashClass keyValuesArrayWithObjectArray:polyline_arr];

    
    NSArray *dic_arr = [LMapTools saveMaplines:polines_arr];
    
    save_finish = YES;
    
    NSString *road_ids = [LTools cacheForKey:ROAD_IDS];
    int index = [road_ids intValue];
    
    NSString *key = [NSString stringWithFormat:@"road_%d",index + 1];
    [LTools cache:dic_arr ForKey:key];
    
    [LTools cache:[NSString stringWithFormat:@"%d",index + 1] ForKey:ROAD_IDS];
    
    [LTools showMBProgressWithText:@"路书保存成功" addToView:self.view];
    
}

//添加点
- (void)addCoordinate
{
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:centerImage.center
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
        
        [middle_points_arr addObject:[AMapGeoPoint locationWithLatitude:coordinate.latitude
                                                              longitude:coordinate.longitude]];
        
        [self addMiddleAnnotation:coordinate];
        
    }

}

- (void)clickToActionMap:(UIButton *)sender
{
    switch (sender.tag - 100) {
        case 0:
        {
            NSLog(@"取消");
            
            nav_walk_finish = NO;
            
            longPress.enabled = NO;
            
            
            if (self.destinationCoordinate.latitude != 0) {
                [self removeDestinationAnnotation];
            }else if (middleAnntations.count > 0)
            {
                [self removeLastMiddleAnnotation];
            }else if(self.startCoordinate.latitude != 0){
                [self removeStartAnnotation];
                point_state = Point_Start;
            }
        }
            break;
        case 1:
        {
            NSLog(@"起");
            point_state = Point_Start;
            
            [self addCoordinate];
        }
            break;
        case 2:
        {
            NSLog(@"途");
            point_state = Point_Middle;
            
            [self addCoordinate];
        }
            break;
        case 3:
        {
            NSLog(@"终");
            point_state = Point_End;

            [self addCoordinate];
        }
            break;
        case 4:
        {
            NSLog(@"生成");
            
            [self searchNaviWalk];
            
            longPress.enabled = NO;
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

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPresss//长按弹出大头针=========
{
    
    if (longPresss.state == UIGestureRecognizerStateBegan)
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
            
            [middle_points_arr addObject:[AMapGeoPoint locationWithLatitude:coordinate.latitude
                                     longitude:coordinate.longitude]];
            
            [self addMiddleAnnotation:coordinate];
            
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

- (void)searchNaviWalk {

    if (self.startCoordinate.latitude == 0) {

        [LTools showMBProgressWithText:@"请选择起点" addToView:self.view];
        return;
    }

    if (self.destinationCoordinate.latitude == 0) {

        [LTools showMBProgressWithText:@"请选择终点" addToView:self.view];
        return;
    }
    
    NSLog(@"--->searchNaviWalk");
    
    int middleCount = middle_points_arr.count;
    
    //没有途经点,直接导航
    if (middleCount == 0) {
        
//        AMapNavigationSearchRequest *navi = [[AMapNavigationSearchRequest alloc] init];
//        navi.searchType       = AMapSearchType_NaviDrive;
//        navi.requireExtension = YES;
//        /* 出发点. */
//        navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
//                                               longitude:self.startCoordinate.longitude];
//        /* 目的地. */
//        navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
//                                                    longitude:self.destinationCoordinate.longitude];
//        
//        [self.search AMapNavigationSearch:navi];
        
        AMapGeoPoint *origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                                        longitude:self.startCoordinate.longitude];
        
        AMapGeoPoint *destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                             longitude:self.destinationCoordinate.longitude];
        
        
        [self searchWithOrigin:origin destination:destination];
        
    }else
    {
        
        AMapGeoPoint *origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                                        longitude:self.startCoordinate.longitude];
        [middle_points_arr insertObject:origin atIndex:0];
        
        AMapGeoPoint *destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                        longitude:self.destinationCoordinate.longitude];
        
        [middle_points_arr addObject:destination];
        
        
        point_index = 0;
        
        AMapGeoPoint *des = [middle_points_arr objectAtIndex:1];
        
        
        [self searchWithOrigin:origin destination:des];
    }
}

- (void)searchWithOrigin:(AMapGeoPoint *)origin destination:(AMapGeoPoint *)destination
{
    AMapNavigationSearchRequest *navi = [[AMapNavigationSearchRequest alloc] init];
    navi.searchType       = AMapSearchType_NaviDrive;
    navi.requireExtension = YES;
    /* 出发点. */
    navi.origin = origin;
    /* 目的地. */
    navi.destination = destination;
    
    [self.search AMapNavigationSearch:navi];
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
    startAnnotation.title      = (NSString*)NavigationViewControllerStartTitle;
    startAnnotation.subtitle   = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    [self.mapView addAnnotation:startAnnotation];
}
- (void)removeStartAnnotation
{
    [self.mapView removeAnnotation:startAnnotation];
    
    self.startCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    [self removeAllPolines];
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

- (void)removeLastMiddleAnnotation
{
    if (middleAnntations.count == 0) {
        [LTools showMBProgressWithText:@"没有添加途经点" addToView:self.view];
        return;
    }
    MAPointAnnotation *last = [middleAnntations lastObject];
    [self.mapView removeAnnotation:last];
    [middleAnntations removeLastObject];

    [middle_points_arr removeLastObject];
    
    [self removeAllPolines];
}

- (void)removeAllPolines
{
    if (middleAnntations.count == 0 && self.startCoordinate.latitude == 0 && self.destinationCoordinate.latitude == 0){
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        [self.mapView removeOverlays:self.mapView.overlays];
    }
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
//        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
//        ReGeocodeAnnotation *reGeocodeAnnotation = [[ReGeocodeAnnotation alloc] initWithCoordinate:coordinate
//                                                                                         reGeocode:response.regeocode];
//        
//        [self.mapView addAnnotation:reGeocodeAnnotation];
//        [self.mapView selectAnnotation:reGeocodeAnnotation animated:YES];
        
        
        
    }
}

/*!
 @brief 路径规划查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapNavigationSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapNavigationSearchResponse类中的定义)
 */
- (void)onNavigationSearchDone:(AMapNavigationSearchRequest *)request response:(AMapNavigationSearchResponse *)response
{
    NSLog(@"--->onNavigationSearchDone");
    
//    NSLog(@"------》response %@",response);
    self.route = response.route;
    
    NSArray *polylines = [CommonUtility polylinesForPath:self.route.paths[0]];

    if (middle_points_arr.count == 0) {
        
        [self.mapView addOverlays:polylines];
        /* 缩放地图使其适应polylines的展示. */
        self.mapView.visibleMapRect = [CommonUtility mapRectForOverlays:polylines];
    }else
    {
        
        [self.mapView addOverlays:polylines];
        
        [polines_arr addObjectsFromArray:polylines];
        
        self.mapView.visibleMapRect = [CommonUtility mapRectForOverlays:polines_arr];
        
        point_index ++;
        
        if (point_index < middle_points_arr.count - 1) {
            
            AMapGeoPoint *origin = [middle_points_arr objectAtIndex:point_index];
            AMapGeoPoint *detin = [middle_points_arr objectAtIndex:point_index + 1];
            
            [self searchWithOrigin:origin destination:detin];
        }else if(point_index == middle_points_arr.count - 1)
        {
            nav_walk_finish = YES;
        }
        
    }
}

#pragma mark - MAMapViewDelegate

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[LineDashPolyline class]])
    {
        MAPolylineView *overlayView = [[MAPolylineView alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        
        overlayView.lineWidth    = 5.f;
        overlayView.strokeColor  = [UIColor redColor];
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
            poiAnnotationView.image = [UIImage imageNamed:@"road_start"];
        }
        /* 终点. */
        else if([[annotation title] isEqualToString:(NSString*)NavigationViewControllerDestinationTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_end"];
        }
        /* 途经点. */
        else if([[annotation title] isEqualToString:(NSString*)NavigationViewControllerMiddleTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"road_middle"];
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
//        NSLog(@"userLocation ---- %@",userLocation);
//        NSLog(@"userLocation.heading----%@",userLocation.heading);
        //地磁场方向
        double heading = userLocation.heading.magneticHeading;
        if (heading > 0) {
            headingStr = [GMAPI switchMagneticHeadingWithDoubel:heading];
        }
//        NSLog(@"%@",headingStr);
    }
    
    //海拔
    CLLocation *currentLocation = userLocation.location;
    if (currentLocation) {
//        NSLog(@"海拔---%f",currentLocation.altitude);
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


//测试导航途经点
- (void)test
{
    AMapNavigationSearchRequest *navi = [[AMapNavigationSearchRequest alloc] init];
    navi.searchType       = AMapSearchType_NaviDrive;
    navi.requireExtension = YES;
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                longitude:self.destinationCoordinate.longitude];
    
    //天安门东 116.401005,39.908024
    //王府井 116.412163,39.908156
    //崇文门 116.417484,39.901309
    //前门  116.398773,39.900255
    //宣武门 116.373882,39.899202
    //陶然亭 116.374741,39.878259
    //天坛东门 116.420918,39.882606
    
    NSArray *data = @[@"116.401005,39.908024",@"116.412163,39.908156",@"116.417484,39.901309",@"116.398773,39.900255",@"116.373882,39.899202",@"116.374741,39.878259",@"116.420918,39.882606"];
    
    NSMutableArray *ways = [NSMutableArray array];
    for (int i = 0; i <ways.count; i ++) {
        
        NSString *des = [data objectAtIndex:i];
        NSArray *ll = [des componentsSeparatedByString:@","];
        
        CGFloat la = [[ll objectAtIndex:1] floatValue];
        CGFloat lon = [[ll objectAtIndex:0] floatValue];
        
        AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:la
                                                       longitude:lon];
        
        [ways addObject:point];
    }
    
    navi.waypoints = [NSArray arrayWithArray:ways];
    
    [self.search AMapNavigationSearch:navi];
}


@end
