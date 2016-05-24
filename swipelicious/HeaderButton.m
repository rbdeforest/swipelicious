//
//  HeaderButton.m
//  swipelicious
//
//  Created by Augusto Guido on 5/5/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import "HeaderButton.h"

@implementation HeaderButton

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted || self.selected) {
        self.backgroundColor = [UIColor colorWithRed:95/255.0f green:169/255.0f blue:148/255.0f alpha:1];
    }
    else {
        self.backgroundColor = [UIColor colorWithRed:147/255.0f green:149/255.0f blue:152/255.0f alpha:1];
    }
}

- (void) setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundColor = [UIColor colorWithRed:95/255.0f green:169/255.0f blue:148/255.0f alpha:1];
    }
    else {
        self.backgroundColor = [UIColor colorWithRed:147/255.0f green:149/255.0f blue:152/255.0f alpha:1];
    }
}

@end
