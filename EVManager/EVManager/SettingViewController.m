//
//  SettingViewController.m
//  EVManager
//
//  Created by dengyanzhou on 15/9/16.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import "SettingViewController.h"
#import "WXApi.h"
#import "MenuInfoModel.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

/**用来请求分享的图片只是为了利用 api来请求图片 没有其他的用请求完以后就立马释放掉*/
@property(nonatomic,strong)UIImageView *shareImageView;
@property(nonatomic,strong)NSData * shareImageData;
@property(nonatomic,assign)NSInteger scene;//标示用户分享到哪儿的
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"设置";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(wxParaInfo:) name:@"WXParaNoti" object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.dataArray addObject:@"分享"];
    [self.dataArray addObject:@"推出登录"];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (UITableView *)tableView
{
    if (!_tableView) {
        self.tableView = ({
            UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
            tableView.rowHeight = 70;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.tableFooterView = [UIView new];
            tableView;
        });
    }
    return _tableView;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        self.dataArray =[[NSMutableArray alloc]init];
    }
    return _dataArray;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.imageView.image = [UIImage imageNamed:@"收藏tutu"];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{
    
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"分享到好友" otherButtonTitles:@"分享到朋友圈",@"收藏到我的微信", nil];
            [actionSheet showInView:self.view];
        }
            break;
        case 1:{
            //TODO: 推出登录
            
        }
            break;
        default:
            break;
    }
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
//微信分享后的回调
- (void)wxParaInfo:(NSNotification*)noti
{
    SendMessageToWXResp *sendMessageToWXResp = noti.object;
    if ([sendMessageToWXResp isMemberOfClass:[SendMessageToWXResp class]]) {
        NSString *proString = nil;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
@end
