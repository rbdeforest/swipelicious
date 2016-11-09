//
//  LikesViewController.h
//  swipelicious
//
//  Created by Augusto Guido on 11/9/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@class Draw;

@interface LikesViewController : UIViewController <FBSDKAppInviteDialogDelegate>

@property (strong, nonatomic) Draw *recipe;

@end
