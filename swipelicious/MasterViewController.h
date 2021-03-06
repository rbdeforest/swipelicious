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

@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIWebView *emptyWebView;

@property (weak, nonatomic) IBOutlet UIView *onboardViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *onbardTapLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *myRecipesBarButton;

@property (weak, nonatomic) IBOutlet UIView *timeLeftView;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftDescription;

extern int likefoodcount;
extern NSString *apiKey;

@end
