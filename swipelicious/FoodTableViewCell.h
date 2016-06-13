//
//  FoodTableViewCell.h
//  swipelicious
//
//  Created by Augusto Guido on 5/5/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"

@interface FoodTableViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *foodTitleLabel;
@property (nonatomic, assign) IBOutlet UILabel *createdByLabel;
@property (nonatomic, assign) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, assign) IBOutlet UILabel *reviewsCount;
@property (nonatomic, assign) IBOutlet UIImageView *foodImage;
@property (nonatomic, assign) IBOutlet HCSStarRatingView *rating;

@end
