//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "swipelicious-Swift.h"
#import "DraggableViewBackground.h"
#import "MasterViewController.h"
#import "MainViewController.h"
#import "ProgressHUD.h"
#import "MasterViewController.h"
#import "AppDelegate.h"

@import Haneke;

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSInteger remainCount;
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    NSMutableArray *likefoods;
}

//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
//static const float CARD_HEIGHT = 260; //%%% height of the draggable card
//static const float CARD_WIDTH = 263; //%%% width of the draggable card

@synthesize ingredients;
@synthesize allCards;//%%% all the cards
@synthesize recipes;

#define MAX_FOOD_COUNT 5

- (id)initWithCoder:(NSCoder *)aDecorer
{
    self = [super initWithCoder:aDecorer];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        
        NSString *requestURL = [Draw getURL];
        [ProgressHUD show:@"Loading" Interaction:NO];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:requestURL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey: @"shouldupdate"]) {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate updatedRecipes];
            }
            
            NSMutableArray *recipesD = [NSMutableArray new];
            for (NSDictionary *d in responseObject) {
                [recipesD addObject:[[Draw alloc] initWithData:d]];
            }
            
            self.recipes = recipesD;
            remainCount = [self.recipes count];
            if (self.recipes.count == 0){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"checkEmpty" object:nil];
            }
            
            [ProgressHUD dismiss];
            
            [self loadCards];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Retrieving Recipes" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
            
            if ([self firstAvailableUIViewController] != nil){
                [[self firstAvailableUIViewController] presentViewController:alert animated:YES completion:nil];
            }
        }];
        
    }
    return self;
}


//%%% sets up the extra buttons on the screen
-(void)setupView
{
    self.backgroundColor = [UIColor clearColor];
    
    [self.xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    
    [self.checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    
    self.notification = [[UILabel alloc]initWithFrame:CGRectMake(60, 100, 230, 50)];
    self.notification.hidden = YES;
    
}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    //DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake(29,0, CARD_WIDTH, CARD_HEIGHT)];
    
    DraggableView *draggableView = (DraggableView *)[[[NSBundle mainBundle] loadNibNamed:@"RecipeView" owner:self options:nil] firstObject];
    draggableView.foodimage.layer.cornerRadius = 4;
    
    Draw *recipe = self.recipes[index];
    
    [draggableView.foodimage hnk_setImageFromURL:[NSURL URLWithString:recipe.photo_url]];
    
    self.foodtitle.text = recipe.title;
    
    NSString *title = recipe.title;
    draggableView.title.text= title.uppercaseString;
    draggableView.favoriteCount.text = [NSString stringWithFormat:@"%@", recipe.favorite_count] ;
    draggableView.createdBy.text = [NSString stringWithFormat:@"Recipe by: %@", recipe.owner] ;
    draggableView.descriptionLabel.text = recipe.short_description;
    draggableView.ingredientsCount.text = [NSString stringWithFormat:@"%@", recipe.ingredient_count];
    draggableView.index = index;
    
    draggableView.delegate = self;
    
    [draggableView addConstraint:[NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.frame.size.width]];
    
    draggableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    draggableView.likeButton.tag = index;
    draggableView.ingredientsButton.tag = index;
    draggableView.timeButton.tag = index;
    
    [draggableView.likeButton addTarget:self action:@selector(likeHandler:) forControlEvents:UIControlEventTouchUpInside];
    [draggableView.ingredientsButton addTarget:self action:@selector(ingredientsHandler:) forControlEvents:UIControlEventTouchUpInside];
    [draggableView.timeButton addTarget:self action:@selector(timeHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return draggableView;
}

- (void)likeHandler:(UIButton *)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Like" message:@"a message" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    
    if ([self firstAvailableUIViewController] != nil){
        [[self firstAvailableUIViewController] presentViewController:alert animated:YES completion:nil];
    }
}

- (void)ingredientsHandler:(UIButton *)sender{
    Draw *recipe = self.recipes[sender.tag];
    NSString *sentence = [recipe.ingredients componentsJoinedByString:@", "];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ingredients" message:sentence preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    
    if ([self firstAvailableUIViewController] != nil){
        [[self firstAvailableUIViewController] presentViewController:alert animated:YES completion:nil];
    }
}

- (void)timeHandler:(UIButton *)sender{
    Draw *recipe = self.recipes[sender.tag];
    
    NSMutableArray *times = [[NSMutableArray alloc] init];
    
    if (recipe.prep_time != nil && ![recipe.prep_time isEqualToString:@""])
        [times addObject:[NSString stringWithFormat:@"Prep time: %@", recipe.prep_time]];
    
    if (recipe.cook_time != nil && ![recipe.cook_time isEqualToString:@""])
        [times addObject:[NSString stringWithFormat:@"Cook time: %@", recipe.cook_time]];
    
    if (recipe.ready_time != nil && ![recipe.ready_time isEqualToString:@""])
        [times addObject:[NSString stringWithFormat:@"Ready time: %@", recipe.ready_time]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cooking Times" message:[times componentsJoinedByString:@", "] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    
    if ([self firstAvailableUIViewController] != nil){
        [[self firstAvailableUIViewController] presentViewController:alert animated:YES completion:nil];
    }
    
}



//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([recipes count] > 0) {
        NSInteger numLoadedCardsCap =(([recipes count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[recipes count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "foodimageurls" with your own array of data
        for (int i = 0; i<[recipes count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[loadedCards objectAtIndex:i] attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[loadedCards objectAtIndex:i] attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

-(void)cardSwipedLeft:(UIView *)card{
    [self swipedLeft:YES card:card];
}

-(void)cardSwipedRight:(UIView *)card{
    [self swipedLeft:NO card:card];
}

- (void)swipedLeft:(BOOL)left card:(UIView *)card{
    
    BOOL like = !left;
    
    DraggableView *c = (DraggableView *)card;
    Draw *recipe = self.recipes[c.index];
    [[[AppSession sharedInstance] user] addToFavorites:recipe like:like];
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    if (like){
        [mixpanel.people increment:USER_LIKED_RECIPES by:@1];
        [mixpanel track: USER_LIKED_RECIPES];
    }else{
        [mixpanel.people increment:USER_NOTLIKED_RECIPES by:@1];
        [mixpanel track: USER_NOTLIKED_RECIPES];
    }
    
    
    //do whatever you want with the card that was swiped
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        
    }
    
    // Mixpanel
    if (remainCount == [recipes count]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey: @"TimeStartSwipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: remainCount] forKey: @"foodlefttoswipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if(remainCount > 0){
        //self.foodtitle.text=[foodtitles5 objectAtIndex:6-remainfoodimagecount];
        remainCount--;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: remainCount] forKey: @"foodlefttoswipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if(remainCount == 0){
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: @"foodlefttoswipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self endReached];
        
        // Mixpanel
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
        [mixpanel.people increment:USER_WENT_ALL_FIVE_RECIPES by:@1];
        [mixpanel track: USER_WENT_ALL_FIVE_RECIPES];
        
        NSDate* dateStart = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey: @"TimeStartSwipe"];
        NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:dateStart];
        [mixpanel.people set:USER_TIME_GO_ALL_FIVE_RECIPES to: [NSString stringWithFormat: @"%f Seconds", diff]];
        
        self.notification.hidden = NO;
    }
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(IBAction)swipeRight
{
    if (loadedCards.count == 0) {
        return;
    }
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}
//%%% when you hit the left button, this is called and substitutes the swipe
-(IBAction)swipeLeft
{
    if (loadedCards.count == 0) {
        return;
    }
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}


-(void)endReached{
    [self.xButton setHidden:YES];
    [self.checkButton setHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkEmpty" object:nil];
}

- (UIViewController *) firstAvailableUIViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}

@end
