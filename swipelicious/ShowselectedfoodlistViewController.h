//
//  ShowselectedfoodlistViewController.h
//  swipelicious
//
//  Created by iosdev on 8/21/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowselectedfoodlistViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *Selectedfoodlist;
@property (weak, nonatomic) IBOutlet UIView *tabView;
extern NSString *selectedfoodid;
extern int selectedfoodindex;
extern NSArray *ingredients;
@end
