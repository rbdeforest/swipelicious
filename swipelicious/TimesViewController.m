//
//  TimesViewController.m
//  swipelicious
//
//  Created by Augusto Guido on 11/9/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import "swipelicious-Swift.h"
#import "TimesViewController.h"

@interface TimesViewController ()

@property (nonatomic, assign) IBOutlet UILabel *cookLabel;
@property (nonatomic, assign) IBOutlet UILabel *prepLabel;

@end

@implementation TimesViewController

@synthesize recipe;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.cookLabel setText:[NSString stringWithFormat:@"%@ minutes", recipe.cook_time]];
    [self.prepLabel setText:[NSString stringWithFormat:@"%@ minutes", recipe.prep_time]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
