//
//  MainViewController.m
//  swipelicious
//
//  Created by iosdev on 7/26/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import "swipelicious-Swift.h"

#import "MainViewController.h"
#import <MessageUI/MessageUI.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "swipelicious-Bridging-Header.h"

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
    if(fbid && ![fbid isEqual: @""]){
        if ([FBSDKAccessToken currentAccessToken]) {
            //User;
            User * user = [[User alloc] initWithFBToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
            [[AppSession sharedInstance] login:user completion:^(User * _Nullable user, NSError * _Nullable error) {
                if (error == nil){
                    userfacebookid=fbid;
                    [self performSegueWithIdentifier:@"logined" sender:nil];
                }
                
            }];
        }
    }else{
        NSString *email = [defaults objectForKey:@"UserEmail"];
        NSString *password = [defaults objectForKey:@"UserPassword"];
        
        if (email != nil && ![email isEqual:@""] && password != nil && ![password isEqual:@""]) {
            User * user = [[User alloc] initWithEmail:email password:password];
            
            [[AppSession sharedInstance] login:user completion:^(User * _Nullable user, NSError * _Nullable error) {
                if (error == nil){
                    userfacebookid=@"";
                    [self performSegueWithIdentifier:@"logined" sender:nil];
                }
            }];
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDismissLogin:) name:@"kUserDidDismissLogin" object:nil];
    
    //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserLoginViewController.didRegister(_:)), name: Constants.Notifications.UserDidRegister, object: nil)
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    self.navigationController.navigationBarHidden = false;
}

- (void)didDismissLogin:(NSNotification *)notification{
    [self performSegueWithIdentifier:@"logined" sender:self];
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
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
        } else if (result.isCancelled) {
            
        } else {
            if ([FBSDKAccessToken currentAccessToken]) {
                //User;
                User * user = [[User alloc] initWithFBToken:[[FBSDKAccessToken currentAccessToken] tokenString]];
                [FBSDKAccessToken setCurrentAccessToken:[FBSDKAccessToken currentAccessToken]];
                [[AppSession sharedInstance] login:user completion:^(User * _Nullable user, NSError * _Nullable error) {
                    if (error == nil){
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
    
    [self performSegueWithIdentifier:@"register" sender:self];
    
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
