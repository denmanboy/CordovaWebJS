//
//  LeftViewController.h
//  EVManager
//
//  Created by dengyanzhou on 15/9/14.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuInfoModel.h"


@class MenuButton;
@protocol LeftViewControllerDelegate <NSObject>
- (void)leftMenuClick:(MenuButton*)button;
@end
@interface MenuButton : UIButton

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, copy) NSString *tagrgetUrl;
@end

@interface LeftViewController : UIViewController
@property (nonatomic, strong) LeftMenu *leftMenus;
@property (nonatomic, weak) id <LeftViewControllerDelegate> delegate;

@end
