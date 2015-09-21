//
//  LeftWebViewController.h
//  EVManager
//
//  Created by dengyanzhou on 15/9/16.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftWebViewController : UIViewController
@property (nonatomic, copy  ) NSString  *targerUrl;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy  ) NSString  *leftTitle;
@end
