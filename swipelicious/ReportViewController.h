//
//  ReportViewController.h
//  swipelicious
//
//  Created by Augusto Guido on 11/9/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Draw;

@interface ReportViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) Draw *recipe;

@end
