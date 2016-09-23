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
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Are you sure to delete this recipe?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[[AppSession sharedInstance] user] addToFavorites:recipe like:NO];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    

}

- (IBAction)onTapShare:(id)sender{
    NSArray *items = [NSArray arrayWithObjects:recipe.blog_url ? recipe.blog_url : recipe.link, @"Check out this recipe", nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activityVC animated:true completion:nil];
}

- (IBAction)onTapCart:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Cart" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
