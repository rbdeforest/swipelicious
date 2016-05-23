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
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "MainViewController.h"
#import "MasterViewController.h"
UILocalNotification *notification;
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [launchOptions valueForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"OljqdevZuNmaIveVYrLT84v6TqI1SjfThAsp35MS" clientKey:@"qEcTRyV4GU3lCOTFKBT9H22VnAF1dj3pOmrhNMi7"];
    [PFFacebookUtils initializeFacebook];
    
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
    /////////////////////////////////////////////////////////////////////////////////////
//    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
//    
//    NSDateComponents *componentsForReferenceDate = [calendar components:(NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth ) fromDate:[NSDate date]];
//    
//    [componentsForReferenceDate setDay:1];
//    [componentsForReferenceDate setMonth:9];
//    [componentsForReferenceDate setYear:2015];
//    
//    NSDate *referenceDate = [calendar dateFromComponents:componentsForReferenceDate];
//    
//    // set components for time 7:00 a.m.
//    
//    NSDateComponents *componentsForFireDate = [calendar components:(NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate: referenceDate];
//    
//    [componentsForFireDate setHour:6];
//    [componentsForFireDate setMinute:10];
//    [componentsForFireDate setSecond:10];
//    
//    NSDate *fireDateOfNotification = [calendar dateFromComponents:componentsForFireDate];
//    
//    // Create the notification
//    
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    
//    notification.fireDate = fireDateOfNotification;
//    notification.timeZone = [NSTimeZone localTimeZone];
//    notification.alertBody = [NSString stringWithFormat: @"5 new recipes arrived"];
//    notification.alertAction = @"1";
//    notification.userInfo= @{@"information": [NSString stringWithFormat:@"Some information"]};
//    notification.repeatInterval= NSCalendarUnitDay;
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    if(notification)
//        application.applicationIconBadgeNumber=0;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    // Override point for customization after application launch.
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
        UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"Notification"    message:@"5 new recipes arrived"
                                                               delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [notificationAlert show];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        MasterViewController *master = [[MasterViewController alloc] init];
        [master viewWillAppear:YES];
    }
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
        
        NSDate *today = [NSDate date];
        
        //if today is grater than last date + 24 hours
        NSTimeInterval interval = [today timeIntervalSinceDate:lastRecipesDate];
        if (interval >= 0){
            return true;
        }
    }else{
        return true;
    }
    
    return false;
}

- (void)updatedRecipes{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *date = [NSDate date];
    
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    
    [defaults setObject:dateOnly forKey:@"lastRecipesDate"];
    [defaults synchronize];
}

@end
