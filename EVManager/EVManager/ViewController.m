//
//  ViewController.m
//  EVManager
//
//  Created by dengyanzhou on 15/9/14.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge/WebViewJavascriptBridge.h"
#import "WebViewJavascriptBridge/WkWebViewJavascriptBridge.h"
#import "WXApi.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "TBAnimationButton.h"
#import "MenuInfoModel.h"
#import "BottomNaviBar.h"
#import "SettingViewController.h"
@interface ViewController ()<WXApiDelegate,BottomNaviBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
/**webView*/
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)UIProgressView *progressView;
@property(nonatomic,strong)WebViewJavascriptBridge *bridge;
//菜单按钮
@property(nonatomic,strong)TBAnimationButton *menuButton;
//底部菜单
@property(nonatomic,strong)BottomNaviBar *bottomNaviBar;

/**用来请求分享的图片只是为了利用 api来请求图片 没有其他的用请求完以后就立马释放掉*/
@property(nonatomic,strong)UIImageView *shareImageView;
@property(nonatomic,strong)NSData * shareImageData;
@property(nonatomic,assign)NSInteger scene;//标示用户分享到哪儿的

@end

@implementation ViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setRestorationIdentifier:@"MMExampleCenterControllerRestorationKey"];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //防止滑动试图自动调整边缘
    self.automaticallyAdjustsScrollViewInsets = NO;
    AppDelegate  *appDelegate = [UIApplication sharedApplication].delegate;
    MenuInfoModel *infoModel = appDelegate.infoModel;
    self.title = infoModel.titleName;
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(wxParaInfo:) name:@"wxParaNoti" object:nil];

    //有左导航 就设置导航器
    if (infoModel.leftMenu.menus.count) {
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(gotoShare)];
    
    //初始化webView
    [self.view addSubview:self.webView];
    //初始化进度条
    // [self.view addSubview:self.progressView];
    
    //js和web关联
    if (!_bridge) {
        //oc 收到js的消息
        [WebViewJavascriptBridge enableLogging];
        self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView handler:^(id data, WVJBResponseCallback responseCallback) {
        }];
    }
    //加载资源
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:infoModel.normalHomeUrl]]     ;
    [self.webView loadRequest:request];
    
    //微信登陆
    [self.bridge registerHandler:@"callWX" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *info = (NSDictionary*)data;
        //判断是否是微信
        if ([info[@"type"] isEqualToString:@"wx"]) {
            //构造SendAuthReq结构体
            SendAuthReq* req =[[SendAuthReq alloc ] init];
            req.scope = @"snsapi_userinfo" ;
            req.state = @"123" ;
            //第三方向微信终端发送一个SendAuthReq消息结构
            [WXApi sendAuthReq:req viewController:self delegate:self];
        }
    }];
    
    //微信支付
    [self.bridge registerHandler:@"callWXPay" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSDictionary *info = (NSDictionary*)data;
        
        responseCallback(@"12");
        [self.bridge callHandler:@"callWXPay" data:@{@"info":@"支付成功"}];
        
    }];
    //上传图片
    WS(weakSelf);
    [self.bridge registerHandler:@"commitPhone" handler:^(id data, WVJBResponseCallback responseCallback) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [weakSelf presentViewController:picker animated:YES completion:nil];
    }];

    //微信分享
    [self.bridge registerHandler:@"callWXShare" handler:^(id data, WVJBResponseCallback responseCallback) {
       
    }];
    //底部导航
    [self.view addSubview:self.bottomNaviBar];
}

#pragma mark - 选择图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获取图片裁剪的图
    UIImage* edit = [info objectForKey:UIImagePickerControllerEditedImage];
    //获取图片的url
    NSURL* url = [info objectForKey:UIImagePickerControllerReferenceURL];
    NSString *urlString = url.relativeString;
    urlString = @"http://www.ev-easy.com/phone/2015-09-15/do3sfjo3o933.jpg";
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.bridge callHandler:@"commitPhone" data:@{@"info":urlString} responseCallback:^(id responseData) {
        }];
    }];
}
#pragma mark - 菜单按钮
- (TBAnimationButton *)menuButton
{
    if (!_menuButton) {
        self.menuButton = ({
            TBAnimationButton *button = [TBAnimationButton buttonWithType:UIButtonTypeCustom];
            button.frame =  CGRectMake(0, 0, 35, 35);
            button.currentState = TBAnimationButtonStateMenu;
            button.backgroundColor = [UIColor clearColor];
            button.lineWidth = 30;
            button.lineHeight = 2;
            button.lineColor = [UIColor colorWithRed:0.871 green:0.224 blue:0.110 alpha:1.000];
            button;
        });
    }
    return _menuButton;
}
#pragma mark - 底部导航
- (BottomNaviBar *)bottomNaviBar
{
    if (!_bottomNaviBar) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        MenuInfoModel *infomel = appDelegate.infoModel;
        if (infomel.bottomMenu.menus.count) {
            self.bottomNaviBar = ({
                BottomNaviBar *bottomBar = [[BottomNaviBar alloc]initWithBottomMenu:infomel.bottomMenu];
                bottomBar.delegate = self;
                bottomBar;
            });
        }
    }
    return _bottomNaviBar;
}


- (void)gotoShare
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"分享到好友" otherButtonTitles:@"分享到朋友圈",@"收藏到我的微信", nil];
    [actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 3) {//用户点击了取消按钮
        return;
    }
    
    if (![WXApi isWXAppInstalled]){
        [self.view makeToast:@"您未安装微信无法分享" duration:1 position:CSToastPositionCenter];
        return;
    }
    self.scene = buttonIndex;
    MenuInfoModel *infoMomel = EVAPPDelegate.infoModel;
    NSString *shareImageUrl = infoMomel.shareContent.imageUrl;
    WS(weakSelf);
    [self.shareImageView sd_setImageWithURL:[NSURL URLWithString:shareImageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            //得到全局队列 在全局队列里压缩图片
            dispatch_queue_t  queue  = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                UIImage *tempImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(120, 120)];
                weakSelf.shareImageData  = UIImageJPEGRepresentation(tempImage, 0.5);
                //在主线程去调用微信分享
                [self performSelectorOnMainThread:@selector(wxShare:) withObject:[NSNumber numberWithInteger:buttonIndex] waitUntilDone:YES];
            });
        }else{
            //没有图片
            weakSelf.shareImageData = nil;
            [weakSelf wxShare:([NSNumber numberWithInteger:buttonIndex])];
        }
    }];
    
}
//微信分享
- (void)wxShare:(NSNumber*)scene
{
    //微信分享
    MenuInfoModel *infoMomel = EVAPPDelegate.infoModel;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = infoMomel.shareContent.title;
    message.description = infoMomel.shareContent.summary;
    //分享的图片
    message.thumbData = self.shareImageData;
    //立即释放图片 清空内粗
    self.shareImageData = nil;
    //分享的url
    WXWebpageObject *webObject = [WXWebpageObject object];
    webObject.webpageUrl = infoMomel.shareContent.targetUrl;
    message.mediaObject = webObject;
    //发送请求
    SendMessageToWXReq *sendMessage  = [[SendMessageToWXReq alloc]init];
    sendMessage.bText = NO;
    sendMessage.message = message;
    //发送到朋友圈
    sendMessage.scene = [scene intValue];
    [WXApi sendReq:sendMessage];
}

//压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
    
}
- (UIImageView *)shareImageView
{
    if (!_shareImageView) {
        self.shareImageView = [[UIImageView alloc]init];
    }
    return _shareImageView;
}

- (void)gotoSetting
{
    SettingViewController *setCtrl = [[SettingViewController alloc]init];
    [self.navigationController pushViewController:setCtrl animated:YES];    
}
- (void)gotoLoadLocal:(UINavigationItem*)button
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"web" ofType:@"html"];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    [self.webView loadRequest:request];
}
- (void)leftDrawerButtonPress:(MMDrawerBarButtonItem*)button
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}
#pragma mark - 侧边栏按钮点击
- (void)leftMenuClick:(MenuButton *)button
{  WS(weakSelf);
    //关闭左边导航栏
    [self leftDrawerButtonPress:nil];
    if ([button.tagrgetUrl isEqualToString:@"清空缓存"]) {
        
        //计算成功清除的文件大小
        double __block fileSize = 0;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *fileList  = [fileManager contentsOfDirectoryAtPath:CACHES_PATH error:nil];
        
       //逐条清除
       [fileList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           NSString *filePath = [CACHES_PATH  stringByAppendingPathComponent:(NSString*)obj];
           NSLog(@"filePath= %@",filePath);
          //计算文件大小
           long long tempfileSize = [self folderSizeAtPath:filePath];
           if ([fileManager removeItemAtPath:filePath error:nil]) {
               fileSize += tempfileSize;
           };
       }];
        [self.view makeToast:[NSString stringWithFormat:@"成功清除%.2fM缓存",fileSize / 1024 / 1024] duration:2 position:CSToastPositionCenter];
        return;
    }
    if ([button.tagrgetUrl isEqualToString:@"退出登录"]) {
        
        
        return;
    }
    //判断没有底部导航和 主页的url为空
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    MenuInfoModel *infoModel = appDelegate.infoModel;
    if (weakSelf.bottomNaviBar || infoModel.normalHomeUrl.length ) {
        
        LeftWebViewController *leftWebCtrl = [[LeftWebViewController alloc]init];
        leftWebCtrl.targerUrl =  button.tagrgetUrl;
        leftWebCtrl.leftTitle = [button currentTitle];
        [weakSelf.navigationController pushViewController:leftWebCtrl animated:NO];
        
        
    }else{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:button.tagrgetUrl]];
        [weakSelf.webView loadRequest:request];
    }

}
//遍历文件夹获得文件夹大小，返回多少M
- (double) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    double folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

//单个文件的大小
- (double) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

#pragma mark - 底部按钮
- (void)bottomNaviBarClick:(NSNumber*)index
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    MenuInfoModel *infomel = appDelegate.infoModel;
    NSArray *menusArray = infomel.bottomMenu.menus;
    NSUInteger dex = [index unsignedIntegerValue];
    Menus *menus = menusArray[dex];
    NSURLRequest *reqeust = [NSURLRequest requestWithURL:[NSURL URLWithString:menus.targetUrl]];
    [self.webView loadRequest:reqeust];
}
#pragma mark - 微信登录回调
//微信登录授权code
- (void)wxParaInfo:(NSNotification*)noti
{
    BaseResp *baseResp = noti.object;
    if ([baseResp isMemberOfClass:[SendAuthResp class]]) {
        if (baseResp.errCode == 0) {
            SendAuthResp *sendAuthResp = (SendAuthResp*)baseResp;
            [self.bridge callHandler:@"callWXLogin" data:@{@"code":sendAuthResp.code} responseCallback:^(id responseData) {
                
            }];
        }
    }
    if ([baseResp isMemberOfClass:[SendMessageToWXResp class]]) {
        NSString *proString = nil;
        SendMessageToWXResp *sendMessageToWXResp = (SendMessageToWXResp*)baseResp;
        if (sendMessageToWXResp.errCode == 0) {
            proString = @"分享成功";
            if (self.scene == 2) {
                proString = @"收藏成功";
            }
        }else{
            proString = @"分享失败";
            if (self.scene == 2) {
                proString = @"收藏失败";
            }
        }
        [self.view makeToast:proString duration:1 position:CSToastPositionCenter];
    }
}
#pragma mark -创建webView
/**懒加载*/
- (UIWebView *)webView
{
    if (!_webView) {
        self.webView = ({
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            MenuInfoModel *infomel = appDelegate.infoModel;
            CGFloat bottom_space = 0;
            if (infomel.bottomMenu.menus.count) {
                bottom_space = 49;
            }
            UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width , self.view.frame.size.height - bottom_space - 64)];
            webView.backgroundColor =[UIColor clearColor];
            webView;
        });
    }
    return _webView;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        self.progressView = ({
            UIProgressView *progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
            progressView.frame = CGRectMake(0,64, self.view.frame.size.width, 20);
            progressView;
        });
    }
    return _progressView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
