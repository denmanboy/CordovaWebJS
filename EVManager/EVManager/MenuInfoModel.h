//
//  MenuInfoModel.h
//  EVManager
//
//  Created by dengyanzhou on 15/9/14.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LeftMenu,BottomMenu,Menus,WX,ShareContent;

//
@interface MenuInfoModel : NSObject

@property (nonatomic, copy  ) NSString     *message;
@property (nonatomic, assign) NSInteger    state;
@property (nonatomic, strong) LeftMenu     *leftMenu;
@property (nonatomic, strong) BottomMenu   *bottomMenu;
@property (nonatomic, strong) WX           *wx;
@property (nonatomic, strong) ShareContent *shareContent;

//标题
@property (nonatomic, copy  ) NSString   *titleName;
//启动图片地址
@property (nonatomic, copy  ) NSString   *splashUrl;
//正常的Url
@property (nonatomic, copy  ) NSString   *normalHomeUrl;

@end

//左边按钮
@interface LeftMenu : NSObject
@property (nonatomic, copy  ) NSString   *navibgColor;
@property (nonatomic, strong) NSArray    *menus;
@end

//底部按钮
@interface BottomMenu : NSObject
@property (nonatomic, copy  ) NSString   *navibgColor;
@property (nonatomic, strong) NSArray    *menus;
@end

//一个按钮
@interface Menus : NSObject
@property (nonatomic, copy  ) NSString   *targetUrl;
@property (nonatomic, copy  ) NSString   *name;
@property (nonatomic, copy  ) NSString   *fontColorFocus;
@property (nonatomic, copy  ) NSString   *fontColorDefault;
@end

@interface  WX : NSObject
@property (nonatomic, copy  ) NSString   *appid;
@property (nonatomic, copy  ) NSString   *secret;
@end

@interface ShareContent : NSObject
@property (nonatomic, copy  ) NSString   *title;
@property (nonatomic, copy  ) NSString   *summary;
@property (nonatomic, copy  ) NSString   *imageUrl;
@property (nonatomic, copy  ) NSString   *targetUrl;
@end

