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
#import <malloc/malloc.h>

NSString *apiKey;
int likefoodcount;
int currentOverlay;


@interface MasterViewController ()
    @property (strong, nonatomic) NSArray *shareRecipes;
    @property (weak, nonatomic) DraggableViewBackground *draggableBackground;
    @property (nonatomic, strong) NSTimer *timer;
@end

@implementation MasterViewController{
    
}

@synthesize draggableBackground;
@synthesize timer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUUID *adId = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString *str = [adId UUIDString];
    
    NSLog(@"%@", str);
    
    apiKey= @"bf12802240eb6023ecbe09595d5e656d";
    
    NSString *urlString = @"http://www.sousrecipes.com/empty.php";
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlString]];
    
    [self.emptyWebView loadRequest:request];
    [self.emptyWebView setHidden:YES];
    
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
        self.myRecipesBarButton.enabled = NO;
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
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:YES];
    [self updateTimeLeft];
}

- (void)viewDidAppear:(BOOL)animated{
    self.shareButton.titleLabel.numberOfLines = 0; // Dynamic number of lines
    self.shareButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.shareButton.imageEdgeInsets = UIEdgeInsetsMake(0., self.shareButton.frame.size.width - self.shareButton.titleEdgeInsets.left, 0., 0.);
    self.shareButton.titleEdgeInsets = UIEdgeInsetsMake(0., 0., 0., 30);
    
    [super viewDidAppear:animated];
}

- (void)onboardTap:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:.4f animations:^{
        [self.onboardViewContainer viewWithTag:currentOverlay].alpha = 0;
        if ([self.onboardViewContainer viewWithTag:currentOverlay+1] != nil){
            [self.onboardViewContainer viewWithTag:currentOverlay+1].alpha = 1;
            currentOverlay ++;
            if (currentOverlay == 3){
                self.onbardTapLabel.text = @"Tap the screen to start swiping!";
            }
        }else{
            self.onboardViewContainer.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (self.onboardViewContainer.alpha == 0) {
            self.myRecipesBarButton.enabled = YES;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (draggableBackground == nil) {
            [self.emptyWebView setHidden:NO];
            [self.timeLeftView setHidden:NO];
        }else{
            if (draggableBackground.remainCount == 0){
                [self.draggableBackground removeFromSuperview];
                self.draggableBackground = nil;
                [self.emptyWebView setHidden:NO];
                [self.timeLeftView setHidden:NO];
            }else{
                [self.emptyWebView setHidden:YES];
                [self.timeLeftView setHidden:YES];
            }
        }
    });
}

- (void)updateTimeLeft{
    NSDate *lastRequest = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastRecipesDate"];
    
    if (lastRequest != nil) {
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        if ([appDelegate shouldUpdateRecipes]) {
            self.timeLeftLabel.text = @"More recipes are waiting for you!";
            self.timeLeftDescription.text = @"Tap to refresh";
            if ([[self.timeLeftView gestureRecognizers] count] == 0) {
                [self.timeLeftView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshview)]];
            }
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:kPreferenceFreeShareRecipes];
        }else{
            if ([[self.timeLeftView gestureRecognizers] count] > 0) {
                UIGestureRecognizer *tap = [self.timeLeftView gestureRecognizers][0];
                [self.timeLeftView removeGestureRecognizer:tap];
            }
            
            NSTimeInterval interval = [[appDelegate nextRefreshDate] timeIntervalSinceNow];
            NSInteger ti = (NSInteger)interval;
            NSInteger seconds = ti % 60;
            NSInteger minutes = (ti / 60) % 60;
            NSInteger hours = (ti / 3600);
            
            self.timeLeftLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld hours", (long)hours, (long)minutes, (long)seconds];
            self.timeLeftDescription.text = @"Until you get 5 more recipes!";
        }
    }else{
        self.timeLeftLabel.text = @"00:00:00 hours";
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
    
    if (draggableBackground != nil) {
        [draggableBackground removeFromSuperview];
        draggableBackground = nil;
    }
    
    draggableBackground = (DraggableViewBackground *)[[[NSBundle mainBundle] loadNibNamed:@"DraggableViewBackground" owner:self options:nil] firstObject];
    [self.view addSubview:draggableBackground];
    
    draggableBackground.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:draggableBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.timeLeftView attribute:NSLayoutAttributeTop multiplier:1 constant:30]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:draggableBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-30]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:draggableBackground attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:draggableBackground attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
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
