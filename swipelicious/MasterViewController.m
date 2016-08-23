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
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AppDelegate.h"
#import "ProgressHUD.h"
#import "DraggableViewBackground.h"
#import <Parse/Parse.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "ECSlidingViewController.h"

NSString *apiKey;
NSMutableArray *foodIdData;
NSMutableArray *foodTitleData;
NSMutableArray *foodImageUrlData;
DraggableViewBackground *draggableBackground;
UIView *tempview;
int likefoodcount;


@interface MasterViewController ()

@end

@implementation MasterViewController{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    apiKey= @"bf12802240eb6023ecbe09595d5e656d";
    
    NSString *urlString = @"http://swipelicious.com/empty.php";
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:urlString]];
    
    [self.emptyWebView loadRequest:request];
    [self.emptyWebView setHidden:YES];
    
    foodIdData = [[NSMutableArray alloc] init];
    foodTitleData = [[NSMutableArray alloc] init];
    foodImageUrlData = [[NSMutableArray alloc] init];
    tempview = [[UIView alloc] init];
    [self.view addSubview:tempview];
    [self setOfFoodData];
    
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
    
}

-(void)checkRefresh{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tempview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.emptyWebView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tempview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.emptyWebView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tempview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.emptyWebView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}


-(void)viewWillAppear:(BOOL)animated{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    notification.applicationIconBadgeNumber = 0;
    
    [self checkRefresh];
}

-(void)setOfFoodData{
    
    PFQuery *query = [PFQuery queryWithClassName:@"FoodData"];
    [query whereKey:@"facebook_id" equalTo :userfacebookid];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count]>0){
        for (int i = 0; i < [objects count]; i ++) {
            [foodIdData addObject:objects[i][@"recipe_id"]];
            [foodTitleData addObject:objects[i][@"title"]];
            [foodImageUrlData addObject:objects[i][@"image_url"]];
        }
        likefoodcount = (int)[objects count];
        }
    }];

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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex ==0) {
        
        [login logOut];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"" forKey:@"userfacebookid"];
        [self.navigationController popToRootViewControllerAnimated:YES];

    }else if(buttonIndex ==1){
        NSString *messagebody;
        
        messagebody = @"";
        //    NSLog(@"%@" , messagebody);
        
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
