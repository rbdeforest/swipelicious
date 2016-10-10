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
#import <AdSupport/ASIdentifierManager.h>

#import "ShowselectedfoodlistViewController.h"

NSString *apiKey;
DraggableViewBackground *draggableBackground;
UIView *tempview;
int likefoodcount;
int currentOverlay;


@interface MasterViewController ()
    @property (strong, nonatomic) NSArray *shareRecipes;

@end

@implementation MasterViewController{
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUUID *adId = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString *str = [adId UUIDString];
    
    NSLog(@"%@", str);
    
    apiKey= @"bf12802240eb6023ecbe09595d5e656d";
    
    NSString *urlString = @"http://swipelicious.com/empty.php";
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlString]];
    
    [self.emptyWebView loadRequest:request];
    [self.emptyWebView setHidden:YES];
    
    tempview = [[UIView alloc] init];
    [self.view addSubview:tempview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkRefresh) name:@"refreshMessageMasterView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishSwiping:) name:kDidFinishSwipingNotification object:nil];
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
    
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    notification.applicationIconBadgeNumber = 0;
    
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.shareButton.hidden = YES;
    [self.emptyWebView setHidden:YES];
    
    if ([appDelegate shouldUpdateRecipes]){
        [defaults setBool:true forKey: @"shouldupdate"];
        [defaults synchronize];
        [self refreshview];
    } else {
        id freeShare = [defaults objectForKey:kPreferenceFreeShareRecipes];
        if ([freeShare boolValue]){
            [defaults setBool:true forKey: @"shouldupdate"];
            [self refreshview];
            [defaults setBool:false forKey:kPreferenceFreeShareRecipes];
            [defaults synchronize];
        }else{
            if ([[NSUserDefaults standardUserDefaults] objectForKey: @"foodlefttoswipe"] != nil) {
                [[NSUserDefaults standardUserDefaults] setBool: false forKey: @"shouldupdate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self refreshview];
            }
        }
        
    }
    
    [self checkEmpty];
}

-(void)checkEmpty{
    if (draggableBackground == nil) {
        [self.emptyWebView setHidden:YES];
    }else{
        if (draggableBackground.remainCount == 0){
            [self.emptyWebView setHidden:YES];
        }else{
            [self.emptyWebView setHidden:NO];
        }
    }
}

- (void)didFinishSwiping:(NSNotification *)notification{
    [self checkEmpty];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id freeShare = [defaults objectForKey:kPreferenceFreeShareRecipes];
    
    if (freeShare == nil){
        self.shareRecipes = [notification object];
        if (self.shareRecipes != nil && [self.shareRecipes count] > 0){
            self.shareButton.hidden = NO;
            self.emptyWebView.hidden = YES;
            [self.view bringSubviewToFront:self.shareButton];
        }
        
        [[Kiip sharedInstance] saveMoment:@"my_first_moment" withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
            if (error) {
                NSLog(@"something's wrong");
                // handle with an Alert dialog.
            }
            if (poptart) {
                [poptart show];
            }
            if (!poptart) {
                // handle logic when there is no reward to give.
            }
        }];
    }
}

- (IBAction)shareRecipe:(id)sender{
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_SHARE_FOR_10_MORE by:@1];
    [mixpanel track: USER_CLICKED_SHARE_FOR_10_MORE];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowselectedfoodlistViewController *showRecipesViewController = [sb instantiateViewControllerWithIdentifier:@"ShowselectedfoodlistViewController"];
    showRecipesViewController.recipes = self.shareRecipes;
    showRecipesViewController.sharing = YES;
    [self.navigationController pushViewController:showRecipesViewController animated:YES];
}

-(void)refreshview{
    if ([tempview superview] != nil) {
        [tempview removeFromSuperview];
    }
    
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
    [super viewWillAppear:animated];
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
