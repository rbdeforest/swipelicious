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
#import "FoodTableViewCell.h"
#import "TagTableViewController.h"
@import Haneke;

@interface ShowselectedfoodlistViewController ()

@property (nonatomic, retain) NSMutableArray *filteredRecipes;
@property (nonatomic, retain) NSArray *currentList;

@end

@implementation ShowselectedfoodlistViewController

@synthesize recipes;
@synthesize filteredRecipes;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filteredRecipes = [NSMutableArray new];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];

    // Mixpanel
    [[NSUserDefaults standardUserDefaults] setObject: [NSDate date] forKey: @"StartSelectedFoodListPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.sharing){
        self.footer.hidden = YES;
        self.title = @"Share a Recipe";
        self.navigationItem.title = @"Share a Recipe";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(didCancelShare:)];
    }else{
        self.recipes = [[[AppSession sharedInstance] user] favorites];
        [self.Selectedfoodlist reloadData];
    }
}
    
-(void)didCancelShare:(UIBarButtonItem *)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm" message:@"Are you sure you want to cancel sharing a recipe to get 10 more for free?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    
    cell.descriptionLabel.text = [NSString stringWithFormat:@"prep %@ minutes, cook %@ minutes, total %@ minutes, \nIngredients %@", recipe.prep_time, recipe.cook_time, recipe.total_time, recipe.ingredient_count];
    
    cell.createdByLabel.text = [NSString stringWithFormat:@"Created by %@",recipe.owner];
    
    [cell.foodImage hnk_setImageFromURL:[NSURL URLWithString:imageUrl]];
    
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
    
    if (self.sharing){
        Draw *recipe = [self.recipes objectAtIndex:indexPath.row];
        
        NSURL *shareUrl = [NSURL URLWithString:recipe.blog_url];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[shareUrl] applicationActivities:nil];
        [activityController setExcludedActivityTypes:@
         [UIActivityTypeCopyToPasteboard,
          UIActivityTypeAddToReadingList,
          @"com.apple.mobilenotes.SharingExtension",
          @"com.apple.reminders.RemindersEditorExtension"
          ]
        ];
        
        [self presentViewController:activityController animated:YES completion:nil];
        
        [activityController setCompletionWithItemsHandler:^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
            
            if (completed){
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                
                if ([defaults objectForKey:kPreferenceFreeShareRecipes] == nil){
                    [defaults setObject:@YES forKey:kPreferenceFreeShareRecipes];
                    [defaults synchronize];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!" message:@"You get 10 more recipes for sharing" preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
            
            
        }];
        
//        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//        content.contentURL = [NSURL URLWithString:recipe.blog_url];
//        [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
//        
    }else{
        [self performSegueWithIdentifier:@"showfooddetail" sender:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:kPreferenceFreeShareRecipes] == nil){
        [defaults setObject:@YES forKey:kPreferenceFreeShareRecipes];
        [defaults synchronize];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!" message:@"You get 10 more recipes for sharing" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:^{
            //[self.navigationController popViewControllerAnimated:YES];
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{}
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"showfooddetail"]){
        ShowfooddetailViewController *vc = [segue destinationViewController];
        int row = (int)self.Selectedfoodlist.indexPathForSelectedRow.row;
        vc.recipe = self.currentList[row];
    }else{
        
        // Mixpanel
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
        [mixpanel.people increment:USER_CLICKED_FILTER_BUTTON by:@1];
        [mixpanel track: USER_CLICKED_FILTER_BUTTON];
         
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
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_SORT_BUTTON by:@1];
    [mixpanel track: USER_CLICKED_SORT_BUTTON];
    
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
                return NSOrderedAscending;
            else if (first > second)
                return NSOrderedDescending;
            else
                return NSOrderedSame;
            
        }] mutableCopy];
        [self.Selectedfoodlist reloadData];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:true completion:nil];
}



@end
