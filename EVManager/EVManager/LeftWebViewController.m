//
//  LeftWebViewController.m
//  EVManager
//
//  Created by dengyanzhou on 15/9/16.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import "LeftWebViewController.h"

@interface LeftWebViewController ()




@end

@implementation LeftWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = self.leftTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.targerUrl]];
    [self.webView loadRequest:request];
    
    // Do any additional setup after loading the view.
}

- (UIWebView *)webView
{
    if (!_webView) {
        self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0,64 , [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    }
    return _webView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
