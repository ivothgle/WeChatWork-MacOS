//
//  WeChatWorkPlugin.h
//  WeChatWorkPlugin
//
//  Created by ivothgle on 2018/12/20.
//  Copyright © 2018 ivothgle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for WeChatWorkPlugin.
FOUNDATION_EXPORT double WeChatWorkPluginVersionNumber;

//! Project version string for WeChatWorkPlugin.
FOUNDATION_EXPORT const unsigned char WeChatWorkPluginVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WeChatWorkPlugin/PublicHeader.h>

@interface WEWMessage : NSObject
- (BOOL)isRevoke;
@end

@interface WEWConversation : NSObject
- (BOOL)isConversationSupportWaterMark;
@end
