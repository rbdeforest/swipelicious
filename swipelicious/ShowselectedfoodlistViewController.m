//
//  ShowselectedfoodlistViewController.m
//  swipelicious
//
//  Created by iosdev on 8/21/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import "swipelicious-Swift.h"

#import "ShowselectedfoodlistViewController.h"
#import "ShowfooddetailViewController.h"
#import "MasterViewController.h"
#import "DraggableViewBackground.h"
#import "ProgressHUD.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "FoodTableViewCell.h"
#import <Parse/Parse.h>

NSString *selectedfoodid;
int selectedfoodindex;
NSArray *ingredients;//selected food's ingredients

@interface ShowselectedfoodlistViewController ()

@property (nonatomic, retain) NSArray *recipes;

@end

@implementation ShowselectedfoodlistViewController

@synthesize recipes;

- (void)viewDidLoad {
    [super viewDidLoad];
    ingredients = [[NSArray alloc] init];
    self.recipes = [[[AppSession sharedInstance] user] favorites];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];

    // Mixpanel
    [[NSUserDefaults standardUserDefaults] setObject: [NSDate date] forKey: @"StartSelectedFoodListPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.Selectedfoodlist reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];

    NSDate* dateStart = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey: @"StartSelectedFoodListPage"];
    NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:dateStart];
    [mixpanel.people set:USER_TIME_STAYING_RECIPES_LIST_PAGE to: [NSString stringWithFormat: @"%f Seconds", diff]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recipes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FoodCell";
    
    FoodTableViewCell *cell = (FoodTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (FoodTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
    Draw *recipe = self.recipes[indexPath.row];
    cell.foodImage.image = nil;
    NSString *title = recipe.title;
    
    cell.foodTitleLabel.text = title.uppercaseString;
    NSString *imageUrl = recipe.photo_url;
    cell.descriptionLabel.text = recipe.short_description;
    cell.createdByLabel.text = [NSString stringWithFormat:@"Created by %@",recipe.owner];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //self.sampleimage = [UIImage imageWithData:data];
        cell.foodImage.image= [UIImage imageWithData:data];
    }];
    
    UILabel* lblViewRecipe = (UILabel*)[cell viewWithTag: 20];
    if (lblViewRecipe.gestureRecognizers.count == 0) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewRecipeTap:)];
        [lblViewRecipe addGestureRecognizer:singleTap];
    }
    
    return cell;
}

- (void)handleViewRecipeTap:(UITapGestureRecognizer *)tapRecognizer
{
    UILabel* lblViewRecipe = (UILabel*)tapRecognizer.view;
    
    CGPoint pointInTable = [lblViewRecipe convertPoint:lblViewRecipe.bounds.origin toView: self.Selectedfoodlist];
    NSIndexPath *indexPath = [self.Selectedfoodlist indexPathForRowAtPoint:pointInTable];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: ((Draw*)self.recipes[indexPath.row]).link]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_RECIPE_TO_VIEW_INGREDIENTS by:@1];
    [mixpanel track: USER_CLICKED_RECIPE_TO_VIEW_INGREDIENTS];
    
    [self performSegueWithIdentifier:@"showfooddetail" sender:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ShowfooddetailViewController *vc = [segue destinationViewController];
    int row = (int)self.Selectedfoodlist.indexPathForSelectedRow.row;
    vc.recipe = self.recipes[row];
}

- (IBAction)onClickbackbutton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickTabButton:(id)sender {
    for (UIButton *button in self.tabView.subviews) {
        [button setSelected:false];
    }
    [sender setSelected:YES];
}



@end
