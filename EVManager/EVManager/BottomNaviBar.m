//
//  BottomNaviBar.m
//  EVManager
//
//  Created by dengyanzhou on 15/9/15.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import "BottomNaviBar.h"
#import "UIColorHex.h"
#define Button_Space 10

@interface BottomNaviBar ()
@property(nonatomic,strong)UIButton *currentBtn;

@end
@implementation BottomNaviBar
- (instancetype)initWithBottomMenu:(BottomMenu*)bottomMen
{
    //没有按钮信息直接返回空
    if (!bottomMen.menus.count) {
        return nil;
    }
    if (self = [super initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 49, [UIScreen mainScreen].bounds.size.width, 49)]) {
        //导航条背景颜色
        self.backgroundColor = [UIColorHex colorWithHexString:bottomMen.navibgColor];
        self.userInteractionEnabled = YES;
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - (bottomMen.menus.count+1) * Button_Space) / bottomMen.menus.count;
        [bottomMen.menus enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            Menus *meuns = (Menus*)obj;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(Button_Space + (width + Button_Space) * idx, 2.5, width,44);
            [button setTitle:meuns.name forState:UIControlStateNormal];
            button.showsTouchWhenHighlighted = YES;
            NSString *norColor = meuns.fontColorDefault;
            NSString *foucsColor = meuns.fontColorFocus;
            [button setTitleColor:[UIColorHex colorWithHexString:norColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColorHex colorWithHexString:foucsColor] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = (NSInteger)idx;
            [self addSubview:button];
        }];
    }
    return self;
}

- (void)buttonClick:(UIButton*)button
{   self.currentBtn.selected = NO;
    self.currentBtn = button;
    button.selected = YES;
    if ([self.delegate respondsToSelector:@selector(bottomNaviBarClick:)]) {
        [self.delegate performSelector:@selector(bottomNaviBarClick:) withObject:[NSNumber numberWithInteger:button.tag]];
    }
    
}
@end
