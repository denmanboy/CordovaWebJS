//
//  AppDelegate.m
//  EVManager
//
//  Created by dengyanzhou on 15/9/14.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"
#import "MGJRequestManager.h"
#import "MJExtension.h"
#import "MMDrawerController.h"
#import "ViewController.h"
#import "LeftViewController.h"
#import "MMExampleDrawerVisualStateManager.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "KeychainUUID.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

@interface AppDelegate ()<WXApiDelegate,CLLocationManagerDelegate>
{
    double longitude;
    double latitude;
    NSString *g_address;
    BOOL isUserGesture;//标识用户是否用手势 隐藏了图片
}
@property (nonatomic,strong) MMDrawerController *drawerController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *path = NSHomeDirectory();
    NSLog(@"path = %@",path);
    //默认数据
    longitude = 0.0;
    latitude = 0.0;
    g_address= @"北京市海淀区中关村丹棱街甲1号互联网金融中心";
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    //开启定位
    [self startLocation];
    return YES;
}

//开启定位功能
- (void)startLocation
{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    //设置定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        //调用了这句,就会弹出允许框了,请求前台授权
        [self.locationManager requestWhenInUseAuthorization];
    }
    //开始定位
    [self.locationManager startUpdatingLocation];
}
#pragma mark - 从服务器获取数据
//抓取服务器数据
- (void)loadServerData
{
    //得到缓存的路径
    NSString *cachePath = [CACHES_PATH stringByAppendingPathComponent:@"menuModel.plist"];
    NSMutableDictionary  *dic = [NSMutableDictionary dictionaryWithDictionary:[self getDeviceInfo]];
    [dic setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    [dic setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [dic setObject: g_address forKey:@"addresss"];
    [SVProgressHUD  setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD showWithStatus:@"加载中"];
    WS(weakSelf);
    
    [[MGJRequestManager sharedInstance] GET:@"http://shufaba.net/common/" parameters:dic startImmediately:YES configurationHandler:nil completionHandler:^(NSError *error, id result, BOOL isFromCache, AFHTTPRequestOperation *operation) {
        if (error) {
            
            //错误的话 直接从缓存中去取
            NSDictionary *modelDic = [NSDictionary dictionaryWithContentsOfFile:cachePath];
            [weakSelf.infoModel setValuesForKeysWithDictionary:modelDic];
            [WXApi registerApp:weakSelf.infoModel.wx.appid];
            
            [weakSelf.launchImageView sd_setImageWithURL: [NSURL URLWithString:self.infoModel.splashUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [SVProgressHUD dismiss];
                if (image) {
                    weakSelf.launchImageView.image = image;
                    [self performSelector:@selector(launchImageDisappear) withObject:nil afterDelay:3];
                }else{
                    //请求失败 立即加载网页
                    [self loadRootView];
                }
            }];
        }else{
        
            NSString *state =  (NSString*)[(NSDictionary*)result objectForKey:@"state"];
            if ( [state intValue] == 200 ) {
                //更新缓存
                [(NSDictionary*)result writeToFile:cachePath atomically:YES];
                [weakSelf.infoModel setValuesForKeysWithDictionary:(NSDictionary*)result];
                [WXApi registerApp:weakSelf.infoModel.wx.appid];
            
                [weakSelf.launchImageView sd_setImageWithURL: [NSURL URLWithString:self.infoModel.splashUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [SVProgressHUD dismiss];
                if (image) {
                    weakSelf.launchImageView.image = image;
                    [self performSelector:@selector(launchImageDisappear) withObject:nil afterDelay:3];
                }else{
                    //请求失败 立即加载网页
                    [self loadRootView];
                }
            }];
            }else{//服务器返回数据错误
                [weakSelf.window makeToast: [(NSDictionary*)result objectForKey:@"message"] duration:2 position:CSToastPositionCenter];
                return;
            }
        }
    }];
}
- (void)goHidenLaunchImage:(UITapGestureRecognizer*)tapGes
{   isUserGesture = YES;
    self.launchImageView.hidden = YES;
    [self.launchImageView removeGestureRecognizer:tapGes];
    [self.launchImageView removeFromSuperview];
    
    //释放内存
    self.launchImageView = nil;
    [self loadRootView];
}
//隐藏图片动画
- (void)launchImageDisappear
{
    if (!isUserGesture) { //用户没用点击图片隐藏
        self.launchImageView.hidden = YES;
        [self.launchImageView removeFromSuperview];
        //释放内存
        self.launchImageView = nil;
        [self loadRootView];
    }
}
- (void)loadRootView
{
    //*****************************中间菜单******************************//
    ViewController  *rootViewCtrl = [[ViewController alloc]init];
    UINavigationController *centerController = [[UINavigationController alloc]initWithRootViewController:rootViewCtrl];
    
    //*****************************左边菜单******************************//
    UIViewController *leftController = nil;
    if (self.infoModel.leftMenu.menus.count) {
        LeftMenu*leftMenu = self.infoModel.leftMenu;
        LeftViewController *leftCtrl = [[LeftViewController alloc]init];
        leftCtrl.delegate = rootViewCtrl;
        leftCtrl.leftMenus = leftMenu;
        UINavigationController *leftNavCtrl = [[UINavigationController alloc]initWithRootViewController:leftCtrl];
        [leftCtrl setRestorationIdentifier:@"MMExampleLeftNavigationControllerRestorationKey"];
        leftController = leftNavCtrl;
    }
    self.drawerController  =[[MMDrawerController alloc]initWithCenterViewController:centerController leftDrawerViewController:leftController rightDrawerViewController:nil];
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    
    //设置 打开 和 关闭 动画
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    //设置左边
    [self.drawerController setMaximumLeftDrawerWidth:240];
    
    //设置打开动画
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeSwingingDoor];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    self.window.rootViewController = self.drawerController;
}

#pragma mark - 定位的回调
/**定位失败*/
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    [self.window makeToast:@"定位失败" duration:2 position:CSToastPositionCenter];
    if (self.isLocation == NO) {
        self.isLocation = YES;
        [manager stopUpdatingLocation];
        //加载数据
        [self loadServerData];
    }
}
/**定位成功*/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //防止多次的定位回调
    if (self.isLocation == NO) {
        self.isLocation = YES;
    }else{
        return;
    }
    CLLocation *newLocation = [locations lastObject];
    CLLocationCoordinate2D newCoordinate = newLocation.coordinate;
    longitude = newCoordinate.longitude;
    latitude  = newCoordinate.latitude;
    
    //*****************************逆地理编码******************************//
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation
                   completionHandler:^(NSArray *placemarks, NSError *error){
                       CLPlacemark *place = [placemarks firstObject];
                       NSString *address = place.name;
                       //定位成功 qie 获取了地理编码
                       if (address.length) {
                           //停止定位
                           [manager stopUpdatingLocation];
                           g_address = address;
                           self.isLocation = YES;
                           //加载数据
                           [self loadServerData];
                       }
                   }];
}


#pragma mark - 启动图片
- (UIImageView *)launchImageView
{
    if (!_launchImageView) {
        self.launchImageView = [[UIImageView alloc]initWithFrame:self.window.bounds];
        self.launchImageView.userInteractionEnabled = YES;
        //用户手势
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goHidenLaunchImage:)];
        [self.launchImageView addGestureRecognizer:tapGes];
        tapGes = nil;
        //添加启动图片
        [self.window addSubview:self.launchImageView];
    }
    return _launchImageView;
}
//懒加载
- (MenuInfoModel *)infoModel
{
    if (!_infoModel) {
        self.infoModel = [[MenuInfoModel alloc]init];
    }
    return _infoModel;
}
//微信的请求
- (void) onReq:(BaseReq*)req
{
    
}

//微信授权后回调 WXApiDelegate
- (void)onResp:(BaseResp *)resp
{
    /* ErrCode ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code    用户换取access_token的code，仅在ErrCode为0时有效
     state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang    微信客户端当前语言
     country 微信用户当前国家信息
     */
    [[NSNotificationCenter defaultCenter]postNotificationName:@"wxParaNoti" object:resp];
    
}


- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    NSString * key = [identifierComponents lastObject];
    if([key isEqualToString:@"MMDrawer"]){
        return self.window.rootViewController;
    }
    else if ([key isEqualToString:@"MMExampleCenterNavigationControllerRestorationKey"]) {
        return ((MMDrawerController *)self.window.rootViewController).centerViewController;
    }
    else if ([key isEqualToString:@"MMExampleRightNavigationControllerRestorationKey"]) {
        return ((MMDrawerController *)self.window.rootViewController).rightDrawerViewController;
    }
    else if ([key isEqualToString:@"MMExampleLeftNavigationControllerRestorationKey"]) {
        return ((MMDrawerController *)self.window.rootViewController).leftDrawerViewController;
    }
    else if ([key isEqualToString:@"MMExampleLeftSideDrawerController"]){
        UIViewController * leftVC = ((MMDrawerController *)self.window.rootViewController).leftDrawerViewController;
        if([leftVC isKindOfClass:[UINavigationController class]]){
            return [(UINavigationController*)leftVC topViewController];
        }
        else {
            return leftVC;
        }
        
    }
    else if ([key isEqualToString:@"MMExampleRightSideDrawerController"]){
        UIViewController * rightVC = ((MMDrawerController *)self.window.rootViewController).rightDrawerViewController;
        if([rightVC isKindOfClass:[UINavigationController class]]){
            return [(UINavigationController*)rightVC topViewController];
        }
        else {
            return rightVC;
        }
    }
    return nil;
}



- (NSDictionary*)getDeviceInfo
{
    NSString *UUID          = [KeychainUUID value];//设备唯一ID
    NSString *deviceModel   = [UIDevice currentDevice].model;//品牌
    NSString *systemName    = [UIDevice currentDevice].systemName;//系统名称
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;//系统版本
    NSString *platform      = [self currentDevicePlatform];//平台号
    NSString *deviceName    = [self currentDeviceModelName];//品牌具体型号
    NSDictionary *dic  = @{@"model":deviceModel,
                           @"UUID":UUID,
                           @"systemName":systemName,
                           @"systemVersion":systemVersion,
                           @"platform":platform,
                           @"deviceName":deviceName,
                           };
    return dic;
}

- (NSString*)currentDeviceModelName
{
    NSString *platform = [self currentDevicePlatform];
    //*****************************iPhone******************************//
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    
    //*****************************iPod******************************//
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    //*****************************iPad******************************//
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    //*****************************模拟器******************************//
    if ([platform hasSuffix:@"i386"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? @"iPhone Simulator" : @"iPad Simulator";
    }
    return platform;
}
//获得设备平台号
- (NSString *)currentDevicePlatform
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
    
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:self];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
