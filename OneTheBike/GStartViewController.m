//
//  GStartViewController.m
//  OneTheBike
//
//  Created by gaomeng on 14-10-13.
//  Copyright (c) 2014年 szk. All rights reserved.
//

#import "GStartViewController.h"
#import "ReGeocodeAnnotation.h"

enum{
    OverlayViewControllerOverlayTypeCircle = 0,
    OverlayViewControllerOverlayTypeCommonPolyline,
    OverlayViewControllerOverlayTypePolygon,
    OverlayViewControllerOverlayTypeTexturePolyline,
    OverlayViewControllerOverlayTypeArrowPolyline
    
};

@interface GStartViewController ()
{
    NSInteger _time_s;
    
}
@property (nonatomic,strong)NSMutableArray *cllocation2dsArray;
@property (nonatomic, strong) NSMutableArray *overlays;

@end

@implementation GStartViewController

- (void)dealloc
{
    
    
    [self returnAction];
    
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _time_s = 0;//时间计数 每5s添加一次经纬度
    
    
    //初始化
    [self initMapView];
//    [self initObservers];
    [self initSearch];
//    [self modeAction];
    self.mapView.showsUserLocation = YES;//开启定位
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;//自定义定位样式
    self.mapView.userTrackingMode = MAUserTrackingModeNone;//定位模式
    
    self.mapView.showsCompass= YES;//开启指南针
    self.mapView.compassOrigin= CGPointMake(280, 70); //设置指南针位置
    
    self.mapView.showsScale= YES; //关闭比例尺
    self.mapView.scaleOrigin = CGPointMake(10, 70);
    
    [self initGestureRecognizer];//长按手势
    
    [self initOverlays];//初始化线条覆盖物
    [self.mapView addOverlays:self.overlays];//把线条添加到地图上
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





//返回按钮
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
- (void)initMapView
{
    self.mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
}

//初始化搜索服务
- (void)initSearch
{
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
    self.search.delegate = self;
}

//初始化地图覆盖物
- (void)initOverlays
{
    self.overlays = [NSMutableArray array];
    
    /* Circle. */  //圆
    MACircle *circle = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(39.952136, 116.50095) radius:5000];
    [self.overlays insertObject:circle atIndex:OverlayViewControllerOverlayTypeCircle];
    
    /* Polyline. */  //折线
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
    [self.overlays insertObject:commonPolyline atIndex:0];
    
    /* Polygon. */ //多边形
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
    
    /* Textured Polyline. */  //纹理线
    CLLocationCoordinate2D texPolylineCoords[3];
    texPolylineCoords[0].latitude = 39.932136;
    texPolylineCoords[0].longitude = 116.44095;
    
    texPolylineCoords[1].latitude = 39.932136;
    texPolylineCoords[1].longitude = 116.50095;
    
    texPolylineCoords[2].latitude = 39.952136;
    texPolylineCoords[2].longitude = 116.50095;
    
    MAPolyline *texPolyline = [MAPolyline polylineWithCoordinates:texPolylineCoords count:3];
    [self.overlays insertObject:texPolyline atIndex:OverlayViewControllerOverlayTypeTexturePolyline];
    
    /* Arrow Polyline. */   //箭线
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

#pragma mark - Initialization 初始化Method  end=========



//==============长按手势start=============
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







//==============长按手势end=============






//定位=============================
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
    
    if (overlay == mapView.userLocationAccuracyCircle)// 自定义定位精度对应的MACircleView
    {
        MACircleView *accuracyCircleView = [[MACircleView alloc] initWithCircle:overlay];
        
        accuracyCircleView.lineWidth    = 2.f;
        accuracyCircleView.strokeColor  = [UIColor lightGrayColor];
        accuracyCircleView.fillColor    = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
        
        return accuracyCircleView;
        
    }
//    else if ([overlay isKindOfClass:[MACircle class]]){//下面三个else if 是地图覆盖物(自定义线 图)
//        
//        //圆圈
//        MACircleView *circleView = [[MACircleView alloc] initWithCircle:overlay];
//        
//        circleView.lineWidth    = 5.f;
//        circleView.strokeColor  = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
//        circleView.fillColor    = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.8];
//        circleView.lineDash     = YES;
//        
//        return circleView;
//    }
//    else if ([overlay isKindOfClass:[MAPolygon class]])
//    {
//        //多边形
//        MAPolygonView *polygonView = [[MAPolygonView alloc] initWithPolygon:overlay];
//        polygonView.lineWidth    = 5.f;
//        polygonView.strokeColor  = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.8];
//        polygonView.fillColor    = [UIColor colorWithRed:0.77 green:0.88 blue:0.94 alpha:0.8];
//        polygonView.lineJoinType = kMALineJoinMiter;
//        
//        return polygonView;
//    }
//    else if ([overlay isKindOfClass:[MAPolyline class]])
//    {
//        //折线
//        
//        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
//        
//        if (overlay == self.overlays[OverlayViewControllerOverlayTypeTexturePolyline])
//        {
//            polylineView.lineWidth    = 8.f;
//            [polylineView loadStrokeTextureImage:[UIImage imageNamed:@"arrowTexture"]];
//            
//        }
//        else if(overlay == self.overlays[OverlayViewControllerOverlayTypeArrowPolyline])
//        {
//            polylineView.lineWidth    = 20.f;
//            polylineView.lineCapType  = kMALineCapArrow;
//        }
//        else
//        {
//            polylineView.lineWidth    = 8.f;
//            polylineView.strokeColor  = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.6];
//            polylineView.lineJoinType = kMALineJoinRound;
//            polylineView.lineCapType  = kMALineCapRound;
//        }
//        
//        return polylineView;
//    }
    
    
    
    
    
    
    
    //用户轨迹
    
    if ([overlay isKindOfClass:[MAPolyline class]]){
        
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        return polylineView;
    }
    
    
    
    
    
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
        
        
        _time_s++;//每5秒记录一下
        NSInteger cllCount = _time_s/5;
        
        if (_time_s %5 == 0) {
            
            NSString *glat = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
            NSString *glong = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
            NSDictionary *dic = @{@"glat":glat,@"glong":glong};
            [self.cllocation2dsArray addObject:dic];
            
        }
        
        CLLocationCoordinate2D dian[cllCount];
        
        for (int i = 0; i<cllCount; i++) {
            NSDictionary *dic = self.cllocation2dsArray[i];
            dian[i].latitude = [[dic objectForKey:@"glat"]doubleValue];
            dian[i].longitude = [[dic objectForKey:@"glong"]doubleValue];
            
        }
        
        
        MAPolyline *arrowPolyline = [MAPolyline polylineWithCoordinates:dian count:cllCount];
//        [self.overlays insertObject:arrowPolyline atIndex:OverlayViewControllerOverlayTypeArrowPolyline];
        [self.overlays addObject:arrowPolyline];
        
        
        
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
            
        }];
    }
    
    
}





@end
