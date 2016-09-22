//
//  FriendsViewController.h
//  swipelicious
//
//  Created by Augusto Guido on 9/12/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FBSDKAppInviteDialogDelegate>

@property (nonatomic, weak) IBOutlet UITableView *friendsTable;

@end
