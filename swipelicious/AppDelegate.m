//
//  AppDelegate.m
//  swipelicious
//
//  Created by iosdev on 7/26/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MainViewController.h"
#import "MasterViewController.h"

UILocalNotification *notification;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    NSUserDefaults *startUser = [NSUserDefaults standardUserDefaults];
    NSString *tch = [startUser objectForKey:@"touchId"];
    if ([tch isEqualToString:@"yes"]) {
        
    } else{
        
        [startUser setObject:@"no" forKey:@"touchId"];
        [startUser synchronize];
        
    }
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    notification.applicationIconBadgeNumber= 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    [self scheduleNotification];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    Kiip *kiip = [[Kiip alloc] initWithAppKey:@"dbd4e08eab078285867d65bee1531ca2" andSecret:@"767c825c0c66d5d90d938c29c8da9e47"];
    kiip.delegate = self;
    [Kiip setSharedInstance:kiip];
    return YES;
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)scheduleNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDate *referenceDate = [NSDate date];
    
    NSDateComponents *componentsForFireDate = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate: referenceDate];
    
    [componentsForFireDate setDay:[componentsForFireDate day] + 1];
    [componentsForFireDate setHour:12];
    
    [componentsForFireDate setTimeZone:[NSTimeZone defaultTimeZone]];
    
    NSDate *fireDateOfNotification = [calendar dateFromComponents:componentsForFireDate];
    
    // Create the notification
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = fireDateOfNotification;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = [NSString stringWithFormat: @"5 new recipes arrived"];
    notification.alertAction = @"1";
    notification.userInfo= @{@"information": [NSString stringWithFormat:@"Some information"]};
    notification.repeatInterval= NSCalendarUnitDay;
    notification.soundName = UILocalNotificationDefaultSoundName;
    if(notification)
        notification.applicationIconBadgeNumber= [UIApplication sharedApplication].applicationIconBadgeNumber+1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

//local notification
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

//catching notification
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    notification.applicationIconBadgeNumber = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"gotnotification"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessageMasterView" object:nil userInfo:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:@"New recipes arrived" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        MasterViewController *master = [[MasterViewController alloc] init];
        [master viewWillAppear:YES];
        
    }]];
    
    [[self.window rootViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)shouldUpdateRecipes
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastRecipesDate = [defaults objectForKey:@"lastRecipesDate"];
    
    if (lastRecipesDate != nil){
        lastRecipesDate = [lastRecipesDate dateByAddingTimeInterval:60*60*24];
        
        NSDate *today = [[NSDate date] dateByAddingTimeInterval:60*60*12*-1];
        
        //if today is grater than last date + 24 hours
        NSTimeInterval interval = [today timeIntervalSinceDate:lastRecipesDate];
        if (interval >= 0){
            [defaults removeObjectForKey: @"foodlefttoswipe"];
            [defaults synchronize];
            return true;
        }
    }else{
        [defaults removeObjectForKey: @"foodlefttoswipe"];
        [defaults synchronize];
        return true;
    }
    
    return false;
}

- (void)updatedRecipes{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:60*60*12*-1];
    
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    
    [defaults setObject:dateOnly forKey:@"lastRecipesDate"];
    [defaults synchronize];
}

@end
