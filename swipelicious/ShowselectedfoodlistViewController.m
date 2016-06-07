//
//  ShowselectedfoodlistViewController.m
//  swipelicious
//
//  Created by iosdev on 8/21/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

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


@end

@implementation ShowselectedfoodlistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    ingredients = [[NSArray alloc] init];
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
    return likefoodcount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FoodCell";
    NSInteger index = (NSInteger)likefoodcount-indexPath.row-1;
    FoodTableViewCell *cell = (FoodTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (FoodTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
    cell.foodImage.image = nil;
    
    NSString *title = [foodTitleData objectAtIndex:index];
    cell.foodTitleLabel.text = title.uppercaseString;
    NSString *imageUrl = [foodImageUrlData objectAtIndex:index];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //self.sampleimage = [UIImage imageWithData:data];
        cell.foodImage.image= [UIImage imageWithData:data];
    }];
    
    //cell.rating = [foodRatingData objectAtIndex:index];
    
//    
//    cell.backgroundColor = [UIColor clearColor];
//    
//    UIImageView *cell_background =[[UIImageView alloc]initWithFrame:CGRectMake(13,13,294,64)];
//    cell_background.image =[UIImage imageNamed:@"cell_background.png"];
//    [cell addSubview:cell_background];
//
//    UILabel *foodtitleLabel;
//    // Set font and calculate used space
//    UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:18];
//    // Position of the text
//    foodtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25,13,250,64)];
//    // Set text attributes
//    foodtitleLabel.textColor = [UIColor orangeColor];
//    foodtitleLabel.backgroundColor = [UIColor clearColor];
//    foodtitleLabel.font = textFont;
//    foodtitleLabel.text = [foodTitleData objectAtIndex:index];
//    foodtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    foodtitleLabel.numberOfLines = 0;
//    // Display text
//    [cell addSubview:foodtitleLabel];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_RECIPE_TO_VIEW_INGREDIENTS by:@1];
    [mixpanel track: USER_CLICKED_RECIPE_TO_VIEW_INGREDIENTS];
    
    
    selectedfoodindex = indexPath.row;
    NSInteger index = (NSInteger)likefoodcount-indexPath.row-1;

    selectedfoodid=foodIdData[index];
    
    NSString*imgurl=foodImageUrlData[index];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imgurl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        selectedfoodimage= [UIImage imageWithData:data];
    }];
    
    NSString *requestURL = [NSString stringWithFormat:@"http://food2fork.com/api/get?key=%@", apiKey];
    requestURL = [NSString stringWithFormat:@"%@&rId=%@", requestURL, selectedfoodid];
    requestURL = [requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [ProgressHUD show:@"Loading" Interaction:NO];
    
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 3
        NSLog(@"%@", responseObject);
        NSDictionary *recipes = [responseObject objectForKey:@"recipe"];
        ingredients=[recipes objectForKey:@"ingredients"];
        detaillink=[recipes objectForKey:@"source_url"];
        foodtitle=[recipes objectForKey:@"title"];
        
        [ProgressHUD dismiss];
        [self performSegueWithIdentifier:@"showfooddetail" sender:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    [operation start];
    [operation waitUntilFinished];
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
