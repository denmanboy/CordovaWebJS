//
//  KeychainUUID.m
//  TestUUIDKeychain
//
//  Created by Hepburn on 15/3/20.
//  Copyright (c) 2015年 Hepburn. All rights reserved.
//

#import "KeychainUUID.h"
#import <CommonCrypto/CommonDigest.h>
#import "KeychainItemWrapper.h"
#import <UIKit/UIKit.h>

#if TARGET_IPHONE_SIMULATOR
#define IS_SIMULATOR
#endif

static NSString * kOpenUDIDSessionCache = nil;
static NSString * const kKeychainUUIDKey = @"KeychainUUID";

@implementation KeychainUUID

+ (NSString *)KeychainIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
}

+ (NSString *)value {
    if (kOpenUDIDSessionCache != nil) {
        return kOpenUDIDSessionCache;
    }
    NSLog(@"Read From NSUserDefaults");
    //从配置文件中取
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *keyUUID = [defaults objectForKey:kKeychainUUIDKey];
    if (keyUUID && keyUUID.length>0) {
        kOpenUDIDSessionCache = keyUUID;
        return kOpenUDIDSessionCache;
    }
    NSLog(@"Read From Keychain");
    //从钥匙串中取
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[KeychainUUID KeychainIdentifier] accessGroup:nil];
    keyUUID = [keychain objectForKey:(__bridge id)kSecValueData];
    if (keyUUID && keyUUID.length>0) {
        kOpenUDIDSessionCache = keyUUID;
        return kOpenUDIDSessionCache;
    }
    NSLog(@"Reset UUID");
    //都没有查到，则重置UUID
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    const char *cStr = CFStringGetCStringPtr(cfstring, CFStringGetFastestEncoding(cfstring));
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    CFRelease(uuid);
    
    keyUUID = [NSString stringWithFormat:
                 @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08x",
                 result[0], result[1], result[2], result[3],
                 result[4], result[5], result[6], result[7],
                 result[8], result[9], result[10], result[11],
                 result[12], result[13], result[14], result[15],
                 (unsigned int)(arc4random() % NSUIntegerMax)];
    
    NSLog(@"Write to NSUserDefaults");
    //修改配置文件
    [defaults setObject:keyUUID forKey:kKeychainUUIDKey];
    [defaults synchronize];
    
    NSLog(@"Write to Keychain");
#ifndef IS_SIMULATOR
    //修改钥匙串
    [keychain setObject:kKeychainUUIDKey forKey:(__bridge id)kSecAttrAccount];
    [keychain setObject:keyUUID forKey:(__bridge id)kSecValueData];
    
#endif
    
    kOpenUDIDSessionCache = keyUUID;
    return kOpenUDIDSessionCache;
}

+ (void)Reset {
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[KeychainUUID KeychainIdentifier] accessGroup:nil];
    [keychain resetKeychainItem];
}

@end
