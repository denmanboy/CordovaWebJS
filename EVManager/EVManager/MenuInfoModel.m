//
//  MenuInfoModel.m
//  EVManager
//
//  Created by dengyanzhou on 15/9/14.
//  Copyright (c) 2015年 YiXingLvDong. All rights reserved.
//

#import "MenuInfoModel.h"

@implementation MenuInfoModel



- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"key  = %@没有找到",key);
}
- (void)setValue:(id)value forKey:(NSString *)key
{
    //调用父类方法
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"leftMenu"]) {
        LeftMenu *leftMenu = [[LeftMenu alloc]init];
        [leftMenu setValuesForKeysWithDictionary:value];
        self.leftMenu = leftMenu;
    }
    if ([key isEqualToString:@"bottomMenu"]) {
        BottomMenu *bottomMenu = [[BottomMenu alloc]init];
        [bottomMenu setValuesForKeysWithDictionary:value];
        self.bottomMenu = bottomMenu;
    }
    if ([key isEqualToString:@"wx"]) {
        WX  *wx = [[WX alloc]init];
        [wx setValuesForKeysWithDictionary:value];
        self.wx = wx;
    }
    if ([key isEqualToString:@"shareContent"]) {
        ShareContent *sharContent = [[ShareContent alloc]init];
        [sharContent setValuesForKeysWithDictionary:value];
        self.shareContent = sharContent;
        
    }
}
-(id)valueForKey:(NSString *)key
{
    return nil;
}

@end

@implementation LeftMenu


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"key  = %@没有找到",key);
    
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"menus"]) {
        
        NSMutableArray *array = [NSMutableArray array];
        [(NSMutableArray*)value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Menus *menu = [[Menus alloc]init];
            [menu setValuesForKeysWithDictionary:(NSDictionary*)obj];
            [array addObject:menu];
        }];
        self.menus =  array;
    }
    
}
-(id)valueForKey:(NSString *)key
{
    return nil;
}

@end


@implementation Menus


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"key  = %@没有找到",key);
}
- (void)setValue:(id)value forKey:(NSString *)key
{
    
    [super setValue:value forKey:key];
}
-(id)valueForKey:(NSString *)key
{
    return nil;
    
}

@end

@implementation BottomMenu

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"key  = %@没有找到",key);
}
- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"menus"]) {
        
        NSMutableArray *array = [NSMutableArray array];
        [(NSMutableArray*)value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Menus *menu = [[Menus alloc]init];
            [menu setValuesForKeysWithDictionary:(NSDictionary*)obj];
            [array addObject:menu];
        }];
        self.menus =  array;
    }
    
}
-(id)valueForKey:(NSString *)key
{
    
    
    return nil;
    
}

@end




@implementation WX
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"key  = %@没有找到",key);
}
-(id)valueForKey:(NSString *)key
{
    return nil;
}
@end

@implementation ShareContent

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"key  = %@没有找到",key);
}
-(id)valueForKey:(NSString *)key
{
    
    return nil;
    
}

@end




