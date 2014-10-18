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

const NSString *NavigationViewControllerStartTitle       = @"起点";
const NSString *NavigationViewControllerDestinationTitle = @"终点";

enum{
    OverlayViewControllerOverlayTypeCircle = 0,
    OverlayViewControllerOverlayTypeCommonPolyline,
    OverlayViewControllerOverlayTypePolygon,
    OverlayViewControllerOverlayTypeTexturePolyline,
    OverlayViewControllerOverlayTypeArrowPolyline
    
};

@interface RoadProduceController ()
@property (nonatomic, strong) AMapRoute *route;

/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;


@property (nonatomic, strong) NSMutableArray *overlays;


@end

@implementation RoadProduceController

@synthesize mapView = _mapView;
@synthesize search  = _search;

@synthesize overlays = _overlays;

#pragma mark - Utility

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

#pragma mark - Handle Action

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearMapView];
    
    [self clearSearch];
}

#pragma mark - Initialization

- (void)initMapView
{
    self.mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
    
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
}

- (void)initSearch
{
    
    
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:@"0b92a81f23cc5905c30dcb4c39da609d" Delegate:nil];
    self.search.delegate = self;
}

#pragma mark - Life Cycle


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

#pragma mark - 地图

- (void)initMap
{
    self.startCoordinate        = CLLocationCoordinate2DMake(39.910267, 116.370888);
    self.destinationCoordinate  = CLLocationCoordinate2DMake(39.989872, 116.481956);

    
    [self initMapView];
    
    [self initSearch];
    
    [self initOverlays];
}

#pragma mark - Initialization

- (void)initOverlays
{
    self.overlays = [NSMutableArray array];
    
    /* Circle. */
    MACircle *circle = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(39.952136, 116.50095) radius:5000];
    [self.overlays insertObject:circle atIndex:OverlayViewControllerOverlayTypeCircle];
    
    /* Polyline. */
    CLLocationCoordinate2D commonPolylineCoords[5];
    commonPolylineCoords[0].latitude = 39.832136;
    commonPolylineCoords[0].longitude = 116.34095;
    
    commonPolylineCoords[1].latitude = 39.832136;
    commonPolylineCoords[1].longitude = 116.42095;
    
    commonPolylineCoords[2].latitude = 39.902136;
    commonPolylineCoords[2].longitude = 116.42095;
    
    commonPolylineCoords[3].latitude = 39.902136;
    commonPolylineCoords[3].longitude = 116.44095;
    
    commonPolylineCoords[4].latitude = 39.932136;
    commonPolylineCoords[4].longitude = 116.44095;
    
    MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:5];
    [self.overlays insertObject:commonPolyline atIndex:OverlayViewControllerOverlayTypeCommonPolyline];
    
    /* Polygon. */
    CLLocationCoordinate2D coordinates[4];
    coordinates[0].latitude = 39.810892;
    coordinates[0].longitude = 116.233413;
    
    coordinates[1].latitude = 39.816600;
    coordinates[1].longitude = 116.331842;
    
    coordinates[2].latitude = 39.762187;
    coordinates[2].longitude = 116.357932;
    
    coordinates[3].latitude = 39.733653;
    coordinates[3].longitude = 116.278255;
    
    MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:4];
    [self.overlays insertObject:polygon atIndex:OverlayViewControllerOverlayTypePolygon];
    
    /* Textured Polyline. */
    CLLocationCoordinate2D texPolylineCoords[3];
    texPolylineCoords[0].latitude = 39.932136;
    texPolylineCoords[0].longitude = 116.44095;
    
    texPolylineCoords[1].latitude = 39.932136;
    texPolylineCoords[1].longitude = 116.50095;
    
    texPolylineCoords[2].latitude = 39.952136;
    texPolylineCoords[2].longitude = 116.50095;
    
    MAPolyline *texPolyline = [MAPolyline polylineWithCoordinates:texPolylineCoords count:3];
    [self.overlays insertObject:texPolyline atIndex:OverlayViewControllerOverlayTypeTexturePolyline];
    
    /* Arrow Polyline. */
    CLLocationCoordinate2D ArrowPolylineCoords[3];
    ArrowPolylineCoords[0].latitude = 39.793765;
    ArrowPolylineCoords[0].longitude = 116.294653;
    
    ArrowPolylineCoords[1].latitude = 39.831741;
    ArrowPolylineCoords[1].longitude = 116.294653;
    
    ArrowPolylineCoords[2].latitude = 39.832136;
    ArrowPolylineCoords[2].longitude = 116.34095;
    
    MAPolyline *arrowPolyline = [MAPolyline polylineWithCoordinates:ArrowPolylineCoords count:3];
    [self.overlays insertObject:arrowPolyline atIndex:OverlayViewControllerOverlayTypeArrowPolyline];
    
    
}


#pragma mark - 数据解析

#pragma mark - 网络请求

#pragma mark - 视图创建

- (void)createTools
{
   CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *tools = [[UIView alloc]initWithFrame:CGRectMake(0, screenSize.height - 50 - 50 - 64, screenSize.width, 50)];
    tools.backgroundColor = [UIColor redColor];
    [self.view addSubview:tools];
    NSArray *titls_arr = @[@"取消",@"起",@"途",@"终",@"生成"];
    
    for (int i = 0; i < 5; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((screenSize.width - 50 * 5)/2.f + 50 * i, 0, 50, 50);
        [btn setTitle:[titls_arr objectAtIndex:i] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        btn.tag = 100 + i;
        [tools addSubview:btn];
        [btn addTarget:self action:@selector(clickToActionMap:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - 事件处理

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
        }
            break;
        case 2:
        {
            NSLog(@"途");
        }
            break;
        case 3:
        {
            NSLog(@"终");
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
            poiAnnotationView.image = [UIImage imageNamed:@"startPoint"];
        }
        /* 终点. */
        else if([[annotation title] isEqualToString:(NSString*)NavigationViewControllerDestinationTitle])
        {
            poiAnnotationView.image = [UIImage imageNamed:@"endPoint"];
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}


#pragma mark - 地图处理

- (void)searchNaviWalk {
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


@end
