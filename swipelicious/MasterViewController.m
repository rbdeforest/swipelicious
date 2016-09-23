//
//  MasterViewController.m
//  swipelicious
//
//  Created by iosdev on 8/6/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import "MasterViewController.h"
#import "MainViewController.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "ProgressHUD.h"
#import "DraggableViewBackground.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "ECSlidingViewController.h"

NSString *apiKey;
DraggableViewBackground *draggableBackground;
UIView *tempview;
int likefoodcount;
int currentOverlay;


@interface MasterViewController ()

@end

@implementation MasterViewController{
        
}


- (void)viewDidLoad {
    [super viewDidLoad];
    apiKey= @"bf12802240eb6023ecbe09595d5e656d";
    
    NSString *urlString = @"http://swipelicious.com/empty.php";
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlString]];
    
    [self.emptyWebView loadRequest:request];
    [self.emptyWebView setHidden:YES];
    
    tempview = [[UIView alloc] init];
    [self.view addSubview:tempview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkRefresh) name:@"refreshMessageMasterView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkEmpty) name:@"checkEmpty" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(checkRefresh)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];

    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_OPENED_APP_COUNT by:@1];
    [mixpanel.people set:USER_OPENED_APP_DATE to:[AUtils stringFromDate: [NSDate date]]];
    [mixpanel track: USER_OPENED_APP_COUNT];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool overlayShown = [defaults boolForKey:@"overlayShown"];
    
    if (!overlayShown) {
        [self.view setBackgroundColor:[UIColor clearColor]];
        self.navigationController.navigationBar.layer.zPosition = -1;
        
        currentOverlay = 1;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onboardTap:)];
        
        [self.onboardViewContainer addGestureRecognizer:tap];
        
        [self.view bringSubviewToFront:self.onboardViewContainer];
        
    }else{
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self.onboardViewContainer removeFromSuperview];
        self.onboardViewContainer = nil;
    }
    
}

- (void)onboardTap:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:.4f animations:^{
        [self.onboardViewContainer viewWithTag:currentOverlay].alpha = 0;
        if ([self.onboardViewContainer viewWithTag:currentOverlay+1] != nil){
            [self.onboardViewContainer viewWithTag:currentOverlay+1].alpha = 1;
            currentOverlay ++;
            if (currentOverlay == 3){
                self.onbardTapLabel.text = @"START SWIPING!";
            }
        }else{
            self.onboardViewContainer.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (self.onboardViewContainer.alpha == 0) {
            [self.view setBackgroundColor:[UIColor whiteColor]];
            [self.onboardViewContainer removeFromSuperview];
            self.onboardViewContainer = nil;
            self.navigationController.navigationBar.layer.zPosition = 0;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:true forKey:@"overlayShown"];
        }
        
    }];
}

-(void)checkRefresh{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([appDelegate shouldUpdateRecipes]){
        [[NSUserDefaults standardUserDefaults] setBool: true forKey: @"shouldupdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self refreshview];
    } else {
        [self checkEmpty];
        if ([[NSUserDefaults standardUserDefaults] objectForKey: @"foodlefttoswipe"] != nil) {
            [[NSUserDefaults standardUserDefaults] setBool: false forKey: @"shouldupdate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self refreshview];
        }
    }
}

-(void)checkEmpty{
    [self.emptyWebView setHidden:NO];
}

-(void)refreshview{
    if ([tempview superview] != nil) {
        [tempview removeFromSuperview];
    }
    //draggableBackground = [[DraggableViewBackground alloc]initWithFrame:CGRectMake(0, 57, 320, 500)];
    
    draggableBackground = (DraggableViewBackground *)[[[NSBundle mainBundle] loadNibNamed:@"DraggableViewBackground" owner:self options:nil] firstObject];
    
    tempview = draggableBackground;
    [self.view addSubview:tempview];
    
    tempview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tempview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.emptyWebView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tempview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.emptyWebView attribute:NSLayoutAttributeHeight multiplier:1 constant:-60]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tempview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.emptyWebView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tempview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.emptyWebView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    if (self.onboardViewContainer) {
        [self.view bringSubviewToFront:self.onboardViewContainer];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    notification.applicationIconBadgeNumber = 0;
    
    [self checkRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickLikebutton:(id)sender {
   
}

- (IBAction)onClickDislikebutton:(id)sender {
    
}

- (IBAction)onClickSetting:(id)sender {
    
    if ([self.navigationController.slidingViewController underLeftShowing]) {
        [self.navigationController.slidingViewController resetTopView];
    } else {
        [self.navigationController.slidingViewController anchorTopViewTo:ECRight];
    }
}

- (IBAction)onClickfoldericon:(id)sender {
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_TOP_RIGHT_BUTTON by:@1];
    [mixpanel track: USER_CLICKED_TOP_RIGHT_BUTTON];

    [self performSegueWithIdentifier:@"showlikefoodlist" sender:self];
}

@end
