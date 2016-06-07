//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

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
static const float CARD_HEIGHT = 260; //%%% height of the draggable card
static const float CARD_WIDTH = 263; //%%% width of the draggable card

@synthesize foodimageurls5; //%%% all the labels I'm using as example data at the moment
//@synthesize foodtitles;
@synthesize foodids5;
@synthesize ingredients;
@synthesize allCards;//%%% all the cards
@synthesize page;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];
         page = arc4random() % 2999 + 1;
        //int randomorderofpage = arc4random() % 29 + 1;
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        foodimageurls5 = [[NSMutableArray alloc] init];
        foodtitles5 = [[NSMutableArray alloc ] init];
        foodids5 = [[NSMutableArray alloc ] init];
        
        NSString *requestURL = [NSString stringWithFormat:@"http://food2fork.com/api/search?key=%@", apiKey];
        requestURL = [NSString stringWithFormat:@"%@&page=%d", requestURL, page];
        requestURL = [requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ProgressHUD show:@"Loading" Interaction:NO];
       
        NSURL *url = [NSURL URLWithString:requestURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate updatedRecipes];
            
            // 3
     //       NSLog(@"%@", responseObject);
            NSArray *recipes = [responseObject objectForKey:@"recipes"];
            [foodimageurls5 addObject:recipes[1][@"image_url"]];
            [foodimageurls5 addObject:recipes[2][@"image_url"]];
            [foodimageurls5 addObject:recipes[3][@"image_url"]];
            [foodimageurls5 addObject:recipes[4][@"image_url"]];
            [foodimageurls5 addObject:recipes[5][@"image_url"]];
            
            [foodtitles5 addObject:recipes[1][@"title"]];
            [foodtitles5 addObject:recipes[2][@"title"]];
            [foodtitles5 addObject:recipes[3][@"title"]];
            [foodtitles5 addObject:recipes[4][@"title"]];
            [foodtitles5 addObject:recipes[5][@"title"]];
            [foodtitles5 addObject:@""];
            
            [foodids5 addObject:recipes[1][@"recipe_id"]];
            [foodids5 addObject:recipes[2][@"recipe_id"]];
            [foodids5 addObject:recipes[3][@"recipe_id"]];
            [foodids5 addObject:recipes[4][@"recipe_id"]];
            [foodids5 addObject:recipes[5][@"recipe_id"]];
    
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
            remainfoodimagecount = 5;
      
        
        
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
        page = arc4random() % 2999 + 1;
        //int randomorderofpage = arc4random() % 29 + 1;
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        foodimageurls5 = [[NSMutableArray alloc] init];
        foodtitles5 = [[NSMutableArray alloc ] init];
        foodids5 = [[NSMutableArray alloc ] init];
        
        NSString *requestURL = [NSString stringWithFormat:@"http://food2fork.com/api/search?key=%@", apiKey];
        requestURL = [NSString stringWithFormat:@"%@&page=%d", requestURL, page];
        requestURL = [requestURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [ProgressHUD show:@"Loading" Interaction:NO];
        
        NSURL *url = [NSURL URLWithString:requestURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
             [appDelegate updatedRecipes];
             
             // 3
             //       NSLog(@"%@", responseObject);
             NSArray *recipes = [responseObject objectForKey:@"recipes"];
             [foodimageurls5 addObject:recipes[1][@"image_url"]];
             [foodimageurls5 addObject:recipes[2][@"image_url"]];
             [foodimageurls5 addObject:recipes[3][@"image_url"]];
             [foodimageurls5 addObject:recipes[4][@"image_url"]];
             [foodimageurls5 addObject:recipes[5][@"image_url"]];
             
             [foodtitles5 addObject:recipes[1][@"title"]];
             [foodtitles5 addObject:recipes[2][@"title"]];
             [foodtitles5 addObject:recipes[3][@"title"]];
             [foodtitles5 addObject:recipes[4][@"title"]];
             [foodtitles5 addObject:recipes[5][@"title"]];
             [foodtitles5 addObject:@""];
             
             [foodids5 addObject:recipes[1][@"recipe_id"]];
             [foodids5 addObject:recipes[2][@"recipe_id"]];
             [foodids5 addObject:recipes[3][@"recipe_id"]];
             [foodids5 addObject:recipes[4][@"recipe_id"]];
             [foodids5 addObject:recipes[5][@"recipe_id"]];
             
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
        remainfoodimagecount = 5;
        
        
        
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

#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    //DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake(29,0, CARD_WIDTH, CARD_HEIGHT)];
    
    DraggableView *draggableView = (DraggableView *)[[[NSBundle mainBundle] loadNibNamed:@"RecipeView" owner:self options:nil] firstObject];
    draggableView.foodimage.layer.cornerRadius = 4;
    
    NSString *imageUrl = [foodimageurls5 objectAtIndex:index];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //self.sampleimage = [UIImage imageWithData:data];
        draggableView.foodimage.image= [UIImage imageWithData:data];
    }];
    self.foodtitle.text = [foodtitles5 objectAtIndex:0];
    
    NSString *title = [foodtitles5 objectAtIndex:index];
    draggableView.title.text= title.uppercaseString;
    
    draggableView.delegate = self;
    
    [draggableView addConstraint:[NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:290]];
    
    [draggableView addConstraint:[NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:329]];
    
    draggableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return draggableView;
}
//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([foodimageurls5 count] > 0) {
        NSInteger numLoadedCardsCap =(([foodimageurls5 count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[foodimageurls5 count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "foodimageurls" with your own array of data
        for (int i = 0; i<[foodimageurls5 count]; i++) {
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

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    [mixpanel.people increment:USER_LIKED_RECIPES by:@1];
    [mixpanel track: USER_LIKED_RECIPES];

    
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
    }
   
    if(remainfoodimagecount){
    self.foodtitle.text=[foodtitles5 objectAtIndex:6-remainfoodimagecount];
    remainfoodimagecount--;
    }
    if(remainfoodimagecount == 0){

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
    }

    if(remainfoodimagecount){
    self.foodtitle.text=[foodtitles5 objectAtIndex:6-remainfoodimagecount];
    remainfoodimagecount--;
    }
    if(remainfoodimagecount == 0){
        
        // Mixpanel
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
        [mixpanel.people increment:USER_WENT_ALL_FIVE_RECIPES by:@1];
        [mixpanel track: USER_WENT_ALL_FIVE_RECIPES];

        NSDate* dateStart = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey: @"TimeStartSwipe"];
        NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:dateStart];
        [mixpanel.people set:USER_TIME_GO_ALL_FIVE_RECIPES to: [NSString stringWithFormat: @"%f Seconds", diff]];

        
        self.notification.hidden = NO;
        self.xButton.hidden = NO;
        self.checkButton.hidden = NO;
    }
    
    NSString *foodid = foodids5[4-remainfoodimagecount];
    NSString *foodtitle = foodtitles5[4-remainfoodimagecount];
    //NSString *page = [NSString stringWithFormat:@"%d", self.page];
    NSString *imageurl = foodimageurls5[4-remainfoodimagecount];
    
    PFObject *object = [PFObject objectWithClassName:@"FoodData"];
    object[@"facebook_id"] = userfacebookid;
    object[@"recipe_id"] = foodid;
    object[@"title"] = foodtitle;
    //object[@"page"] = page;
    object[@"image_url"] = imageurl;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self addFoodData :foodids5[4-remainfoodimagecount]:foodtitles5[4-remainfoodimagecount]:foodimageurls5[4-remainfoodimagecount]];
        }
    }];
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

-(void)addFoodData:(NSString *)recipeid:(NSString *)foodtitle:(NSString *)imageurl {
    [foodIdData addObject:recipeid];
    [foodTitleData addObject:foodtitle];
    [foodImageUrlData addObject:imageurl];
    likefoodcount ++;
}

@end
