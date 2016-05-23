//
//  ShowfooddetailViewController.h
//  swipelicious
//
//  Created by iosdev on 8/23/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowfooddetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *foodtitle;
@property (weak, nonatomic) IBOutlet UIImageView *foodimage;


@property (weak, nonatomic) IBOutlet UITableView *ingredientslist;
@property NSString *deleteobjectId;

extern NSString *detaillink;
extern NSString *foodtitle;
extern UIImage *selectedfoodimage;
@end
