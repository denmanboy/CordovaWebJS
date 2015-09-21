//
//  BottomNaviBar.h
//  EVManager
//
//  Created by dengyanzhou on 15/9/15.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuInfoModel.h"
@protocol BottomNaviBarDelegate <NSObject>
- (void) bottomNaviBarClick:(NSNumber*)index;
@end


@interface BottomNaviBar : UIImageView
- (instancetype)initWithBottomMenu:(BottomMenu*)bottomMenu;
@property (nonatomic,weak) id<BottomNaviBarDelegate >delegate ;
@end
