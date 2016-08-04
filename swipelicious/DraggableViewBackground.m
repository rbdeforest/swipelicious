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
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import <Parse/Parse.h>
#import "MasterViewController.h"
#import "AppDelegate.h"

NSMutableArray *foodtitles5;
NSMutableArray *imageUrls;

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSInteger remainfoodimagecount;
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    NSMutableArray *likefoods;
    
   
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
//static const float CARD_HEIGHT = 260; //%%% height of the draggable card
//static const float CARD_WIDTH = 263; //%%% width of the draggable card

@synthesize foodimageurls5; //%%% all the labels I'm using as example data at the moment
//@synthesize foodtitles;
@synthesize foodids5;
@synthesize ingredients;
@synthesize allCards;//%%% all the cards
@synthesize page;
@synthesize recipes;

#define MAX_FOOD_COUNT 5

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey: @"foodlefttoswipe"] == nil) {
            remainfoodimagecount = MAX_FOOD_COUNT;
        } else {
            NSNumber* tmp = [[NSUserDefaults standardUserDefaults] objectForKey: @"foodlefttoswipe"];
            remainfoodimagecount = tmp.integerValue;
        }
        
        
        
         page = arc4random() % 2999 + 1;
        //int randomorderofpage = arc4random() % 29 + 1;
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        foodimageurls5 = [[NSMutableArray alloc] init];
        foodtitles5 = [[NSMutableArray alloc ] init];
        foodids5 = [[NSMutableArray alloc ] init];
        
        NSString *requestURL = @"http://localhost/~augusto/Swipelicious/draws.json";//[NSString stringWithFormat:@"http://food2fork.com/api/search?key=%@", apiKey];
        //requestURL = [NSString stringWithFormat:@"%@&page=%d", requestURL, page];
        //requestURL = [requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ProgressHUD show:@"Loading" Interaction:NO];
       
        NSURL *url = [NSURL URLWithString:requestURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey: @"shouldupdate"]) {
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [appDelegate updatedRecipes];
            }
            
            // 3
     //       NSLog(@"%@", responseObject);
            self.recipes = [responseObject objectForKey:@"recipes"];
            
            [foodimageurls5 addObject:recipes[0][@"photo_url"]];
            [foodimageurls5 addObject:recipes[1][@"photo_url"]];
            [foodimageurls5 addObject:recipes[2][@"photo_url"]];
            [foodimageurls5 addObject:recipes[3][@"photo_url"]];
            [foodimageurls5 addObject:recipes[4][@"photo_url"]];
            
            [foodtitles5 addObject:recipes[0][@"title"]];
            [foodtitles5 addObject:recipes[1][@"title"]];
            [foodtitles5 addObject:recipes[2][@"title"]];
            [foodtitles5 addObject:recipes[3][@"title"]];
            [foodtitles5 addObject:recipes[4][@"title"]];
            
            [foodtitles5 addObject:@""];
            
            [foodids5 addObject:recipes[0][@"id"]];
            [foodids5 addObject:recipes[1][@"id"]];
            [foodids5 addObject:recipes[2][@"id"]];
            [foodids5 addObject:recipes[3][@"id"]];
            [foodids5 addObject:recipes[4][@"id"]];

            for (int i = 0; i < MAX_FOOD_COUNT - remainfoodimagecount; i++) {
                [self.recipes removeObjectAtIndex: 0];
            }
    
            [ProgressHUD dismiss];
            
            [self loadCards];

            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        [operation start];
        
        
        
       // [self loadCards];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecorer
{
    self = [super initWithCoder:aDecorer];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey: @"foodlefttoswipe"] == nil) {
            remainfoodimagecount = MAX_FOOD_COUNT;
        } else {
            NSNumber* tmp = [[NSUserDefaults standardUserDefaults] objectForKey: @"foodlefttoswipe"];
            remainfoodimagecount = tmp.integerValue;
        }
        
        page = arc4random() % 2999 + 1;
        //int randomorderofpage = arc4random() % 29 + 1;
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        foodimageurls5 = [[NSMutableArray alloc] init];
        foodtitles5 = [[NSMutableArray alloc ] init];
        foodids5 = [[NSMutableArray alloc ] init];
        
        NSString *requestURL = [Draw getURL];
        [ProgressHUD show:@"Loading" Interaction:NO];
        
        NSURL *url = [NSURL URLWithString:requestURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if ([[NSUserDefaults standardUserDefaults] boolForKey: @"shouldupdate"]) {
                 AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                 [appDelegate updatedRecipes];
             }
             // 3
             //       NSLog(@"%@", responseObject);
             //NSArray *recipes = responseObject;//[responseObject objectForKey:@"recipes"];
             NSMutableArray *recipesD = [NSMutableArray new];
             for (NSDictionary *d in responseObject) {
                 [recipesD addObject:[[Draw alloc] initWithData:d]];
             }
             
             self.recipes = recipesD;
             remainfoodimagecount = [self.recipes count];
             
             for (int i = 0; i < MAX_FOOD_COUNT - remainfoodimagecount; i++) {
                 if (self.recipes.count > 0)
                     [self.recipes removeObjectAtIndex: 0];
             }

             [ProgressHUD dismiss];
             
             [self loadCards];
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Recipes"
                                                                 message:[error localizedDescription]
                                                                delegate:nil
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil];
             [alertView show];
         }];
        [operation start];

        
        if ([[NSUserDefaults standardUserDefaults] objectForKey: @"foodlefttoswipe"] == nil) {
            remainfoodimagecount = 5;
        } else {
            NSNumber* tmp = [[NSUserDefaults standardUserDefaults] objectForKey: @"foodlefttoswipe"];
            remainfoodimagecount = tmp.integerValue;
        }
        
        
        // [self loadCards];
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
    NSString *imageUrl = [recipe.photo_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];// recipe.photo_url;
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //self.sampleimage = [UIImage imageWithData:data];
        draggableView.foodimage.image= [UIImage imageWithData:data];
    }];
    self.foodtitle.text = recipe.title;
    
    NSString *title = recipe.title;
    draggableView.title.text= title.uppercaseString;
    draggableView.favoriteCount.text = [NSString stringWithFormat:@"%@", recipe.favorite_count] ;
    draggableView.createdBy.text = [NSString stringWithFormat:@"Recipe by: %@", recipe.owner] ;
    draggableView.ingredientsCount.text = [NSString stringWithFormat:@"%@", recipe.ingredient_count];
    draggableView.index = index;
    
    draggableView.delegate = self;
    
    [draggableView addConstraint:[NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.frame.size.width]];
//    
//    [draggableView addConstraint:[NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.frame.size.height]];
    
    draggableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return draggableView;
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

//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    DraggableView *c = (DraggableView *)card;
    Draw *recipe = self.recipes[c.index];
    [[[AppSession sharedInstance] user] addToFavorites:recipe like:NO];
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_LIKED_RECIPES by:@1];
    [mixpanel track: USER_LIKED_RECIPES];

    
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
    if (remainfoodimagecount == 5) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey: @"TimeStartSwipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: remainfoodimagecount] forKey: @"foodlefttoswipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
   
    if(remainfoodimagecount){
    //self.foodtitle.text=[foodtitles5 objectAtIndex:6-remainfoodimagecount];
    remainfoodimagecount--;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: remainfoodimagecount] forKey: @"foodlefttoswipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if(remainfoodimagecount == 0){

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

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    DraggableView *c = (DraggableView *)card;
    Draw *recipe = self.recipes[c.index];
    User *user = [[AppSession sharedInstance] user];
    [user addToFavorites:recipe like:YES];
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_NOTLIKED_RECIPES by:@1];
    [mixpanel track: USER_NOTLIKED_RECIPES];

    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        
    }
    
    // Mixpanel
    if (remainfoodimagecount == 5) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey: @"TimeStartSwipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: remainfoodimagecount] forKey: @"foodlefttoswipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if(remainfoodimagecount){
    //self.foodtitle.text=[foodtitles5 objectAtIndex:6-remainfoodimagecount];
    remainfoodimagecount--;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger: remainfoodimagecount] forKey: @"foodlefttoswipe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if(remainfoodimagecount == 0){
        
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
//        self.xButton.hidden = NO;
//        self.checkButton.hidden = NO;
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


-(void)addFoodData:(NSString *)recipeid:(NSString *)foodtitle:(NSString *)imageurl {
    [foodIdData addObject:recipeid];
    [foodTitleData addObject:foodtitle];
    [foodImageUrlData addObject:imageurl];
    likefoodcount ++;
}

@end
