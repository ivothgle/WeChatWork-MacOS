//
//  main.m
//  WeChatWorkPlugin
//
//  Created by ivothgle on 2018/12/20.
//  Copyright © 2018 ivothgle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+WeChatWorkHook.h"

@implementation NSObject (WEWMain)

static void __attribute__((constructor)) initialize(void) {
    NSLog(@"++++++++ WeChatWorkPlugin loaded ++++++++");
    [NSObject hookWeChatWork];
}

@end
