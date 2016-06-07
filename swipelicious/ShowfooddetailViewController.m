//
//  ShowfooddetailViewController.m
//  swipelicious
//
//  Created by iosdev on 8/23/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import "ShowfooddetailViewController.h"
#import "MasterViewController.h"
#import "MainViewController.h"
#import "ShowselectedfoodlistViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "ProgressHUD.h"
#import <Parse/Parse.h>

NSString *detaillink;//selected food's detaillink
NSString *foodtitle;//selected food's foodtitle
UIImage *selectedfoodimage;//selected food's image
#define kTopMargin 10.0f
#define kBottomMargin 10.0f
#define kLeftMargin 20.0f
#define kRightMargin 20.0f
#define GROWING_TEXT_CELL_FONT [UIFont fontWithName:@"Helvetica" size:17]
@interface ShowfooddetailViewController ()

@end

@implementation ShowfooddetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.foodtitle.numberOfLines=0;
    self.foodtitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.foodtitle.text=foodtitle.uppercaseString;
    self.foodimage.image= selectedfoodimage;


}
- (IBAction)gotodetailrecipe:(id)sender {
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_CLICKED_VIEW_FULL_RECIPE by:@1];
    [mixpanel track: USER_CLICKED_VIEW_FULL_RECIPE];

    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:detaillink]];
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
    return [ingredients count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
//   // cell.backgroundColor = [UIColor clearColor];
//    UILabel *ingredient;
//    // Set font and calculate used space
//    UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:17];
//    // Position of the text
//    ingredient = [[UILabel alloc] initWithFrame:CGRectMake(10,5,280,35)];
//    // Set text attributes
//    ingredient.textColor = [UIColor orangeColor];
//    ingredient.backgroundColor = [UIColor clearColor];
//    ingredient.font = textFont;
//    
//    ingredient.text = ingredients[indexPath.row];
//    [ingredient setLineBreakMode:NSLineBreakByWordWrapping];
//    ingredient.numberOfLines = 0;
//    CGSize labelSize = CGSizeMake(280, 40);
//    CGSize theStringSize = [ingredient.text sizeWithFont:ingredient.font constrainedToSize:labelSize];
//    
//    ingredient.frame = CGRectMake(ingredient.frame.origin.x, ingredient.frame.origin.y, theStringSize.width, theStringSize.height);
//    CGRect labelFrame = ingredient.frame;
//    labelFrame.size = [ingredient.text sizeWithFont:ingredient.font constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)];
//    ingredient.frame = labelFrame;
//    [cell addSubview:ingredient];
    
    UILabel * title = (UILabel *)[cell viewWithTag:1];
    title.text=ingredients[indexPath.row];
    
    //[cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    //cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (IBAction)onTapDelete:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert"
                                                   message:@"Are you sure to delete this recipe?"
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    [alert show];

}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 = Tapped yes
    if (buttonIndex == 1)
    {
        NSInteger index = likefoodcount-selectedfoodindex-1;
        [foodIdData removeObject: [foodIdData objectAtIndex:index]];
        [foodTitleData removeObject: [foodTitleData objectAtIndex:index]];
        [foodImageUrlData removeObject:[foodImageUrlData objectAtIndex:index]];
        likefoodcount--;
        PFQuery *query = [PFQuery queryWithClassName:@"FoodData"];
        [query whereKey:@"facebook_id" equalTo :userfacebookid ];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (int i = 0; i < [objects count]; i ++) {
                if([objects[i][@"recipe_id"] isEqualToString:selectedfoodid]){
                    PFObject *deleteObject  =objects[i];
                    [deleteObject deleteInBackground];
                   
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }];
    }
    
}

@end
