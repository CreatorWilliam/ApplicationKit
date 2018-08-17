//
//  JPushKit.h
//  JPushKit
//
//  Created by William Lee on 2018/8/16.
//  Copyright © 2018 William Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for JPushKit.
FOUNDATION_EXPORT double JPushKitVersionNumber;

//! Project version string for JPushKit.
FOUNDATION_EXPORT const unsigned char JPushKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JPushKit/PublicHeader.h>


#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
