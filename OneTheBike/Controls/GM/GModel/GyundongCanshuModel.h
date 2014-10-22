//
//  GyundongCanshuModel.h
//  OneTheBike
//
//  Created by gaomeng on 14/10/22.
//  Copyright (c) 2014年 szk. All rights reserved.
//

//运动参数model

#import <Foundation/Foundation.h>

@interface GyundongCanshuModel : NSObject


//@property(nonatomic,assign)double time;//时间
@property(nonatomic,assign)NSString* podu;//坡度
@property(nonatomic,assign)NSString* peisu;//配速//跑完一公里需要的时间
@property(nonatomic,assign)NSString* pashenglv;//爬升率
@property(nonatomic,assign)NSString* haibashang;//海拔上升
@property(nonatomic,assign)NSString* haibaxia;//海拔下降
@property(nonatomic,assign)NSString* pingjunsudu;//平均速度
@property(nonatomic,assign)NSString* zuigaosudu;//最高速度

@property(nonatomic,assign)NSString * haiba;//海拔
@property(nonatomic,assign)NSString * juli;//距离 单位公里
@property(nonatomic,assign)NSString * dangqiansudu;//当前速度 定位返回对象的属性


//计时器
@property(nonatomic,strong)UILabel *timeRunLabel;


//清空所有数据
-(void)cleanAllData;


-(id)init;

@end
