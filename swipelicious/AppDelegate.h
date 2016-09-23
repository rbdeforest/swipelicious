//
//  AppDelegate.h
//  swipelicious
//
//  Created by iosdev on 7/26/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KiipSDK/KiipSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, KiipDelegate>

@property (strong, nonatomic) UIWindow *window;
extern UILocalNotification *notification;

- (BOOL)shouldUpdateRecipes;
- (void)updatedRecipes;

@end

