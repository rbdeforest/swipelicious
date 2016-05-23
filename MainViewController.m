//
//  MainViewController.m
//  swipelicious
//
//  Created by iosdev on 7/26/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import "MainViewController.h"
#import <MessageUI/MessageUI.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "AFHTTPRequestOperation.h"
#import <LocalAuthentication/LocalAuthentication.h>
NSString *userfacebookid;
#define PF_USER_FACEBOOKID   @"facebookId"
FBSDKLoginManager *login;
@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    userfacebookid = @"";
    self.scrollView.contentSize = CGSizeMake(960, 392);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fbid = [defaults objectForKey:@"userfacebookid"];
    if(fbid){
        userfacebookid=fbid;
        [self performSegueWithIdentifier:@"logined" sender:nil];
    }
}

-(void) scheduleNotificationForDate:(NSDate *)date AlertBody:(NSString *)alertBody ActionButtonTitle:(NSString *)actionButtonTitle NotificationID:(NSString *)notificationID{
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.alertBody = alertBody;
    localNotification.alertAction = actionButtonTitle;
    //localNotification.soundName = @"yourSound.wav";
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:notificationID forKey:notificationID];
    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    
    
}
- (IBAction)onClickfbbutton:(id)sender {
    
    login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
        } else if (result.isCancelled) {

        } else {
            if ([FBSDKAccessToken currentAccessToken]) {
                NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                [parameters setValue:@"id,name,email" forKey:@"fields"];
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         NSLog(@"fetched user:%@", result);
                         userfacebookid = result[@"id"];
                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                         [defaults setObject:result[@"id"] forKey:@"userfacebookid"];
                         [defaults synchronize];
                         [self performSegueWithIdentifier:@"logined" sender:nil];
                     }
                 }];
            }
        }
    }];
    
}

- (IBAction)onClickfirstpageicon:(id)sender {
    self.scrollView.contentOffset = CGPointMake(0,0);
    [self setChecked:self.firstpageicon];
}

- (IBAction)onClicksecondpageicon:(id)sender {
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width,0);
    [self setChecked:self.secondpageicon];
}

- (IBAction)onClickthirdpageicon:(id)sender {
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width*2,0);
    [self setChecked:self.thirdpageicon];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.scrollView.contentOffset.x == 0){
        [self setChecked:self.firstpageicon];
    }else if (self.scrollView.contentOffset.x == self.scrollView.bounds.size.width){
        [self setChecked:self.secondpageicon];
    }else if (self.scrollView.contentOffset.x == self.scrollView.bounds.size.width*2){
        [self setChecked:self.thirdpageicon];
    }
}

- (void)setChecked:(UIButton *)icon{
    [self.firstpageicon setImage:[UIImage imageNamed:@"uncheckedicon"]  forState:UIControlStateNormal];
    [self.secondpageicon setImage:[UIImage imageNamed:@"uncheckedicon"]  forState:UIControlStateNormal];
    [self.thirdpageicon setImage:[UIImage imageNamed:@"uncheckedicon"]  forState:UIControlStateNormal];
    [icon setImage:[UIImage imageNamed:@"checkedicon"]  forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickContactUs:(id)sender {
    NSString *messagebody;
    messagebody = @"";
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Recipes App Submission"];
        [mail setMessageBody:messagebody isHTML:NO];
        [mail setToRecipients:@[@"contact@swipelicious.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
