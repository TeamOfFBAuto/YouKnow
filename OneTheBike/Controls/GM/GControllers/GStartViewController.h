//
//  GStartViewController.h
//  OneTheBike
//
//  Created by gaomeng on 14-10-13.
//  Copyright (c) 2014年 szk. All rights reserved.
//



//记录用户行走轨迹的vc
#import <UIKit/UIKit.h>

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>


@interface GStartViewController : UIViewController<MAMapViewDelegate, AMapSearchDelegate>
{
    // 点的数组
    NSMutableArray* _points;
    
    // 用户当前位置
    CLLocation* _currentLocation;
    
    // 折线
    MAPolyline* _routeLine;
    
    //折线view
    MAPolylineView* _routeLineView;
    
}
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

//划线
@property (nonatomic, retain) MAPolyline* routeLine;
@property (nonatomic, retain) MAPolylineView* routeLineView;


//清理 地图 搜索服务的相关代理
- (void)returnAction;

@end