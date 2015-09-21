//
//  AppDelegate.h
//  EVManager
//
//  Created by dengyanzhou on 15/9/14.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuInfoModel.h"
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MenuInfoModel *infoModel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIImageView *launchImageView;
//表示已否已经定位
@property (nonatomic, assign) BOOL isLocation;
@end

