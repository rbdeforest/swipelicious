//
//  MasterViewController.h
//  swipelicious
//
//  Created by iosdev on 8/6/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableViewBackground.h"
@interface MasterViewController : UIViewController
-(void)reloadview;
@property (weak, nonatomic) IBOutlet UIImageView *foodimage;
@property (weak, nonatomic) IBOutlet UILabel *foodname;
@property (weak, nonatomic) IBOutlet UILabel *readytime;
@property (weak, nonatomic) IBOutlet UILabel *countoftotalingredients;
@property (weak, nonatomic) IBOutlet UIButton *dislikebutton;
@property (weak, nonatomic) IBOutlet UIButton *likebutton;
extern NSMutableArray *foodIdData;
extern NSMutableArray * foodTitleData;
extern NSMutableArray *foodImageUrlData;
extern int likefoodcount;
extern NSString *apiKey;
extern DraggableViewBackground *draggableBackground;
@end
