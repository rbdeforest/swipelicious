//
//  MainViewController.h
//  swipelicious
//
//  Created by iosdev on 7/26/15.
//  Copyright (c) 2015 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface MainViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *firstpageicon;
@property (weak, nonatomic) IBOutlet UIButton *secondpageicon;
@property (weak, nonatomic) IBOutlet UIButton *thirdpageicon;
extern FBSDKLoginManager *login;
extern NSString* userfacebookid;
@end
