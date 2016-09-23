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
#import "TagTableViewController.h"

NSString *selectedfoodid;
int selectedfoodindex;
NSArray *ingredients;//selected food's ingredients

@interface ShowselectedfoodlistViewController ()

@property (nonatomic, retain) NSArray *recipes;
@property (nonatomic, retain) NSMutableArray *filteredRecipes;
@property (nonatomic, retain) NSArray *currentList;

@end

@implementation ShowselectedfoodlistViewController

@synthesize recipes;
@synthesize filteredRecipes;

- (void)viewDidLoad {
    [super viewDidLoad];
    ingredients = [[NSArray alloc] init];
    self.filteredRecipes = [NSMutableArray new];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];

    // Mixpanel
    [[NSUserDefaults standardUserDefaults] setObject: [NSDate date] forKey: @"StartSelectedFoodListPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.recipes == nil) {
        self.recipes = [[[AppSession sharedInstance] user] favorites];
        [self.Selectedfoodlist reloadData];
    }
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

- (NSArray *)currentList{
    if ([self.filteredRecipes count] == 0){
        return self.recipes;
    }else{
        return self.filteredRecipes;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self currentList] count];
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
    
    Draw *recipe = self.currentList[indexPath.row];
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
    if ([[segue identifier] isEqualToString:@"showfooddetail"]){
        ShowfooddetailViewController *vc = [segue destinationViewController];
        int row = (int)self.Selectedfoodlist.indexPathForSelectedRow.row;
        vc.recipe = self.currentList[row];
    }else{
        TagTableViewController *vc = [segue destinationViewController];
        vc.finishedPickingTags = ^(NSArray *tags){
            [self filterWithTags:tags];
            NSLog(@"%@", tags);
        };
    }
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

- (void)filterWithTags:(NSArray *)tags{
    [self.filteredRecipes removeAllObjects];
    for (Draw *recipe in self.recipes) {
        BOOL isSubset = [[NSSet setWithArray: tags] isSubsetOfSet: [NSSet setWithArray:recipe.categories]];
        
        if (isSubset){
            [self.filteredRecipes addObject:recipe];
        }
    }
    
    if ([self.filteredRecipes count] == 0){
        UIAlertController* alert = [UIAlertController
                                    alertControllerWithTitle:@"No recipes found"
                                    message:@"No recipes have been found with selected tags"
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self.Selectedfoodlist reloadData];
}

- (IBAction)sortButton:(id)sender{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Recently added" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.filteredRecipes = [[self.currentList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int first = [((Draw *)a).pos intValue];
            int second = [((Draw *)b).pos intValue];
            if (first < second)
                return NSOrderedAscending;
            else if (first > second)
                return NSOrderedDescending;
            else
                return NSOrderedSame;
            
        }] mutableCopy];
        [self.Selectedfoodlist reloadData];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ingredients count" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.filteredRecipes = [[self.currentList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int first = [((Draw *)a).ingredient_count intValue];
            int second = [((Draw *)b).ingredient_count intValue];
            if (first < second)
                return NSOrderedAscending;
            else if (first > second)
                return NSOrderedDescending;
            else 
                return NSOrderedSame;
            
        }] mutableCopy];
        [self.Selectedfoodlist reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ingredients count desc" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.filteredRecipes = [[self.currentList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int first = [((Draw *)a).ingredient_count intValue];
            int second = [((Draw *)b).ingredient_count intValue];
            if (first < second)
                return NSOrderedDescending;
            else if (first > second)
                return NSOrderedAscending;
            else
                return NSOrderedSame;
            
        }] mutableCopy];
        [self.Selectedfoodlist reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cook time" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.filteredRecipes = [[self.currentList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int first = [((Draw *)a).total_time intValue];
            int second = [((Draw *)b).total_time intValue];
            if (first < second)
                return NSOrderedDescending;
            else if (first > second)
                return NSOrderedAscending;
            else
                return NSOrderedSame;
            
        }] mutableCopy];
        [self.Selectedfoodlist reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cook time desc" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.filteredRecipes = [[self.currentList sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int first = [((Draw *)a).total_time intValue];
            int second = [((Draw *)b).total_time intValue];
            if (first < second)
                return NSOrderedDescending;
            else if (first > second)
                return NSOrderedAscending;
            else
                return NSOrderedSame;
            
        }] mutableCopy];
        [self.Selectedfoodlist reloadData];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:true completion:nil];
}



@end
