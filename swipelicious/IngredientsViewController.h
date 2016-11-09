//
//  IngredientsViewController.h
//  swipelicious
//
//  Created by Augusto Guido on 11/9/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Draw;

@interface IngredientsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Draw *recipe;

@end
