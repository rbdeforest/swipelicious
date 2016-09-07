//
//  TagTableViewController.h
//  swipelicious
//
//  Created by Augusto Guido on 9/7/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagTableViewController : UITableViewController

@property (nonatomic, copy) void (^finishedPickingTags)(NSArray *tags);

@end
