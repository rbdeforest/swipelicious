//
//  ShowselectedfoodlistViewController.h
//  swipelicious
//
//  Created by iosdev on 8/21/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ShowselectedfoodlistViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, FBSDKSharingDelegate, UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UITableView *Selectedfoodlist;
@property (weak, nonatomic) IBOutlet UIView *tabView;
@property (weak, nonatomic) IBOutlet UIView *footer;

@property (strong, nonatomic) NSArray *recipes;
@property (nonatomic) BOOL sharing;

extern NSString *selectedfoodid;
extern int selectedfoodindex;
extern NSArray *ingredients;
@end
