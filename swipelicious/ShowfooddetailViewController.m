//
//  ShowfooddetailViewController.m
//  swipelicious
//
//  Created by iosdev on 8/23/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//
#import "swipelicious-Swift.h"
#import "ShowfooddetailViewController.h"
#import "MasterViewController.h"
#import "MainViewController.h"
#import "ShowselectedfoodlistViewController.h"
#import "ProgressHUD.h"
#import "WebViewController.h"

@import Haneke;

@interface ShowfooddetailViewController ()

@end

@implementation ShowfooddetailViewController

@synthesize recipe;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.foodtitle.numberOfLines=0;
    self.foodtitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.foodtitle.text= recipe.title.uppercaseString;
    [self.foodimage hnk_setImageFromURL:[NSURL URLWithString:recipe.photo_url]];
    
    [self.ingredientslist setRowHeight:UITableViewAutomaticDimension];
    [self.ingredientslist setEstimatedRowHeight:20];
    
}
- (IBAction)gotodetailrecipe:(id)sender {
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_VIEW_FULL_RECIPE by:@1];
    [mixpanel track: USER_CLICKED_VIEW_FULL_RECIPE];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewController *webVC = [sb instantiateViewControllerWithIdentifier:@"WebViewController"];
    
    webVC.urlToLoad = [NSURL URLWithString:recipe.link];
    [self.navigationController pushViewController:webVC animated:true];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return likefoodcount;
    return [recipe.ingredients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
    UILabel * title = (UILabel *)[cell viewWithTag:1];
    title.text=recipe.ingredients[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)onTapDelete:(id)sender {
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_DELETE by:@1];
    [mixpanel track: USER_CLICKED_DELETE];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Are you sure to delete this recipe?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[[AppSession sharedInstance] user] addToFavorites:recipe like:NO];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    

}

- (IBAction)onTapShare:(id)sender{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_SHARE by:@1];
    [mixpanel track: USER_CLICKED_SHARE];
    
    NSArray *items = [NSArray arrayWithObjects:recipe.blog_url, @"Check out this recipe", nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activityVC animated:true completion:nil];
    
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//    content.contentURL = [NSURL URLWithString:recipe.blog_url ? recipe.blog_url : recipe.link];
//    [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
}


- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:kPreferenceFreeShareRecipes] == nil){
        [defaults setObject:@YES forKey:kPreferenceFreeShareRecipes];
        [defaults synchronize];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!" message:@"You get 10 more recipes for sharing" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

- (IBAction)onTapCart:(id)sender{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_CART by:@1];
    [mixpanel track: USER_CLICKED_CART];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Coming Soon" message:@"Cart" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
