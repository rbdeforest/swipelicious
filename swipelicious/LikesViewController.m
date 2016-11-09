//
//  LikesViewController.m
//  swipelicious
//
//  Created by Augusto Guido on 11/9/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import "swipelicious-Swift.h"
#import "LikesViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LikesViewController ()

@property (nonatomic, assign) IBOutlet UILabel *textLabel;

@end

@implementation LikesViewController

@synthesize recipe;

- (void)viewDidLoad {
    [super viewDidLoad];
    if ((int)self.recipe.favorite_count > 0){
        [self.textLabel setText:[NSString stringWithFormat:@"%@ people like this recipe!", self.recipe.favorite_count]];
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)invite:(id)sender{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_INVITE_FRIENDS by:@1];
    [mixpanel track: USER_CLICKED_INVITE_FRIENDS];
    
    
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:kShareAppURL];
    
    [FBSDKAppInviteDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
}


- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"%@", results);
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}


- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
