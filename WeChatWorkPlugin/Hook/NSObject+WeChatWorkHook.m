//
//  NSObject+WeChatWorkHook.m
//  WeChatWorkPlugin
//
//  Created by ivothgle on 2018/12/20.
//  Copyright © 2018 ivothgle. All rights reserved.
//


#import <AppKit/AppKit.h>
#import "TKHelper.h"
#import "fishhook.h"
#import "WeChatWorkPlugin.h"

#pragma mark - 替换 NSSearchPathForDirectoriesInDomains & NSHomeDirectory

static NSArray<NSString *> *(*original_NSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);

static NSString *(*original_NSHomeDirectory)(void);

NSArray<NSString *> *swizzled_NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde) {
    NSMutableArray<NSString *> *paths = [original_NSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde) mutableCopy];
    NSString *sandBoxPath = [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.WeWorkMac/Data", original_NSHomeDirectory()];
    
    [paths enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL *_Nonnull stop) {
        NSRange range = [filePath rangeOfString:original_NSHomeDirectory()];
        if (range.length > 0) {
            NSMutableString *newFilePath = [filePath mutableCopy];
            [newFilePath replaceCharactersInRange:range withString:sandBoxPath];
            paths[idx] = newFilePath;
        }
    }];
    
    return paths;
}

NSString *swizzled_NSHomeDirectory(void) {
    return [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.WeWorkMac/Data", original_NSHomeDirectory()];
}

@implementation NSObject (WeChatWorkHook)

+ (void)hookWeChatWork {
    tk_hookMethod(objc_getClass("NSBundle"), @selector(executablePath), [self class], @selector(hook_executablePath));
    
    // 会话水印
    tk_hookMethod(objc_getClass("WEWConversation"), @selector(isConversationSupportWaterMark), [self class], @selector(hook_isConversationSupportWaterMark));
    
    // 撤回
    tk_hookMethod(objc_getClass("WEWMessage"), @selector(isRevoke), [self class], @selector(hook_isRevoke));
    
    
    [self setup];
    
    //替换沙盒路径
    rebind_symbols((struct rebinding[2]) {
        {"NSSearchPathForDirectoriesInDomains", swizzled_NSSearchPathForDirectoriesInDomains, (void *) &original_NSSearchPathForDirectoriesInDomains},
        {"NSHomeDirectory", swizzled_NSHomeDirectory, (void *) &original_NSHomeDirectory}
    }, 2);
}

- (NSString *)hook_executablePath {
    NSString *executablePath = [self hook_executablePath];
    
    // 返回原始执行文件以用于验证
    if ([executablePath hasSuffix:@"企业微信"]) {
        executablePath = [executablePath stringByAppendingString:@"_backup"];
    }
    
    return executablePath;
}

- (BOOL)hook_isRevoke; {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kPreventRevokeEnableKey"]) {
        return [self hook_isRevoke];
    }
    
    return NO;
}

// 去水印
- (BOOL)hook_isConversationSupportWaterMark; {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kConversationWaterMarkDisableKey"]) {
        return [self hook_isConversationSupportWaterMark];
    }
    
    return NO;
}

+ (void)setup {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addAssistantMenuItem];
    });
}

#pragma mark - 菜单栏初始化

/**
 菜单栏添加 menuItem
 */
+ (void)addAssistantMenuItem {
    //todo 整理配置
    NSMenuItem *preventRevokeItem = [[NSMenuItem alloc] initWithTitle:@"开启消息防撤回" action:@selector(onPreventRevoke:) keyEquivalent:@""];
    preventRevokeItem.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"kPreventRevokeEnableKey"];
    
    NSMenuItem *conversationWaterMark = [[NSMenuItem alloc] initWithTitle:@"禁用会话水印" action:@selector(onConversationWaterMark:) keyEquivalent:@""];
    conversationWaterMark.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"kConversationWaterMarkDisableKey"];
    
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"企业微信小助手"];
    [subMenu addItem:preventRevokeItem];
    [subMenu addItem:conversationWaterMark];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setTitle:@"企业微信小助手"];
    [menuItem setSubmenu:subMenu];
    [menuItem setSubmenu:subMenu];
    
    [[[NSApplication sharedApplication] mainMenu] addItem:menuItem];
}

- (void)onPreventRevoke:(NSMenuItem *)item {
    item.state = !item.state;
    [[NSUserDefaults standardUserDefaults] setBool:(BOOL) item.state forKey:@"kPreventRevokeEnableKey"];
}

- (void)onConversationWaterMark:(NSMenuItem *)item {
    item.state = !item.state;
    [[NSUserDefaults standardUserDefaults] setBool:(BOOL) item.state forKey:@"kConversationWaterMarkDisableKey"];
}
@end

