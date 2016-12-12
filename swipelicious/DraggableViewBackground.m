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
#import "IngredientsViewController.h"
#import "LikesViewController.h"
#import "TimesViewController.h"
#import "ReportViewController.h"

@import Haneke;

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
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
@synthesize remainCount;

#define MAX_FOOD_COUNT 10


- (id)initWithCoder:(NSCoder *)aDecorer
{
    self = [super initWithCoder:aDecorer];
    remainCount = MAX_FOOD_COUNT;
    if (self) {
        [super layoutSubviews];
        [self setupView];
        
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        
        NSString *requestURL = [Draw getURL];
        NSMutableDictionary *params = [NSMutableDictionary new];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL freeShare = [[defaults objectForKey:kPreferenceFreeShareRecipes] boolValue];
        
        if (freeShare){
            [params setObject:@"1" forKey:@"free_recipes"];
        }
        
        [ProgressHUD show:@"Loading" Interaction:NO];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        User *user = [[AppSession sharedInstance] user];
        if (user.fbid != nil && ![user.fbid isEqualToString:@""]) {
            [params setObject:user.FBToken forKey:@"fbtoken"];
        }else{
            [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:user.email password:user.password];
        }
        
        [manager GET:requestURL parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"checkEmpty" object:nil];
            
            [ProgressHUD dismiss];
            
            [self loadCards];
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            remainCount = [self.recipes count];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Retrieving Recipes" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
            
            if ([self firstAvailableUIViewController] != nil){
                [[self firstAvailableUIViewController] presentViewController:alert animated:YES completion:nil];
            }
            
            [ProgressHUD dismiss];
            
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
    
    NSLog(@"%@", recipe.ad_identifier);
    
    if (recipe.ad_identifier == nil || [recipe.ad_identifier isEqualToString:@""] || [recipe.ad_identifier isEqual:[NSNull null]]){
        NSString *photoUrl = recipe.photo_url;
        NSLog(@"%@", photoUrl);
        
        HNKCacheFormat *format = [HNKCache sharedCache].formats[@"thumbnail"];
        if (!format)
        {
            format = [[HNKCacheFormat alloc] initWithName:@"thumbnail"];
            format.size = draggableView.foodimage.bounds.size;
            format.scaleMode = HNKScaleModeAspectFill;
            format.compressionQuality = 0.5;
            format.diskCapacity = 10 * 1024 * 1024; // 1MB
            format.preloadPolicy = HNKPreloadPolicyLastSession;
        }
        
        draggableView.foodimage.hnk_cacheFormat = format;
        
        [draggableView.foodimage hnk_setImageFromURL:[NSURL URLWithString:photoUrl]];
        
        self.foodtitle.text = recipe.title;
        
        NSString *title = recipe.title;
        draggableView.title.text= title.uppercaseString;
        draggableView.favoriteCount.text = [NSString stringWithFormat:@"%@", recipe.favorite_count] ;
        draggableView.createdBy.text = [NSString stringWithFormat:@"Recipe by: %@", recipe.owner] ;
        draggableView.descriptionLabel.text = recipe.short_description;
        draggableView.ingredientsCount.text = [NSString stringWithFormat:@"%@", recipe.ingredient_count];
        draggableView.index = index;
        
        draggableView.likeButton.tag = index;
        draggableView.ingredientsButton.tag = index;
        draggableView.timeButton.tag = index;
        
        [draggableView.likeButton addTarget:self action:@selector(likeHandler:) forControlEvents:UIControlEventTouchUpInside];
        [draggableView.ingredientsButton addTarget:self action:@selector(ingredientsHandler:) forControlEvents:UIControlEventTouchUpInside];
        [draggableView.timeButton addTarget:self action:@selector(timeHandler:) forControlEvents:UIControlEventTouchUpInside];
        [draggableView.reportButton addTarget:self action:@selector(reportHandler:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        draggableView.showAd = YES;
        draggableView.nativeExpressAdView.adUnitID = recipe.ad_identifier;
        draggableView.nativeExpressAdView.rootViewController = [self traverseResponderChainForUIViewController];
        
        GADRequest *request = [GADRequest request];
        [draggableView.nativeExpressAdView loadRequest:request];
        request.testDevices = @[ @"fde038bb9247e92af3f6c8ca0a1ad0c2" ];
        
    }
    
    draggableView.delegate = self;
    
    [draggableView addConstraint:[NSLayoutConstraint constraintWithItem:draggableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.frame.size.width]];
    
    draggableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return draggableView;
}

- (void)likeHandler:(UIButton *)sender{
    Draw *recipe = self.recipes[sender.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LikesViewController *likesVC = [storyboard instantiateViewControllerWithIdentifier:@"LikesViewController"];
    likesVC.recipe = recipe;
    
    if ([self firstAvailableUIViewController] != nil){
        id controller = [self firstAvailableUIViewController];
        
        [controller setModalPresentationStyle:UIModalPresentationCurrentContext];
        [[controller navigationController] setModalPresentationStyle:UIModalPresentationCurrentContext];
        [[controller navigationController] setDefinesPresentationContext:YES];
        
        [likesVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [likesVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [[controller navigationController] presentViewController:likesVC animated:YES completion:nil];
    }
    
}

- (void)ingredientsHandler:(UIButton *)sender{
    Draw *recipe = self.recipes[sender.tag];
  
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IngredientsViewController *ingredientsVC = [storyboard instantiateViewControllerWithIdentifier:@"IngredientsViewController"];
    ingredientsVC.recipe = recipe;
    
    if ([self firstAvailableUIViewController] != nil){
        id controller = [self firstAvailableUIViewController];
        
        [controller setModalPresentationStyle:UIModalPresentationCurrentContext];
        [[controller navigationController] setModalPresentationStyle:UIModalPresentationCurrentContext];
        [[controller navigationController] setDefinesPresentationContext:YES];
        
        [ingredientsVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [ingredientsVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [[controller navigationController] presentViewController:ingredientsVC animated:YES completion:nil];
    }
}

- (void)timeHandler:(UIButton *)sender{
    Draw *recipe = self.recipes[sender.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TimesViewController *timesVC = [storyboard instantiateViewControllerWithIdentifier:@"TimesViewController"];
    timesVC.recipe = recipe;
    
    if ([self firstAvailableUIViewController] != nil){
        id controller = [self firstAvailableUIViewController];
        
        [controller setModalPresentationStyle:UIModalPresentationCurrentContext];
        [[controller navigationController] setModalPresentationStyle:UIModalPresentationCurrentContext];
        [[controller navigationController] setDefinesPresentationContext:YES];
        
        [timesVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [timesVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [[controller navigationController] presentViewController:timesVC animated:YES completion:nil];
    }
    
}

- (void)reportHandler:(UIButton *)sender{
    Draw *recipe = self.recipes[sender.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ReportViewController *reportVC = [storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
    reportVC.recipe = recipe;
    
    if ([self firstAvailableUIViewController] != nil){
        id controller = [self firstAvailableUIViewController];
        
        [controller setModalPresentationStyle:UIModalPresentationCurrentContext];
        [[controller navigationController] setModalPresentationStyle:UIModalPresentationCurrentContext];
        [[controller navigationController] setDefinesPresentationContext:YES];
        
        [reportVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [reportVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        [[controller navigationController] presentViewController:reportVC animated:YES completion:nil];
    }
    
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([recipes count] > 0) {
        NSInteger numLoadedCardsCap =((remainCount > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:remainCount);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "foodimageurls" with your own array of data
        
        int i = 0;
        for (i = 0; i<[recipes count]; i++) {
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
    
    DraggableView *dragCard = (DraggableView *)card;
    if (!dragCard.showAd){
        
        Draw *recipe = self.recipes[dragCard.index];
        [[[AppSession sharedInstance] user] addToFavorites:recipe like:like];
        
    }
    
    // Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify: [[NSUserDefaults standardUserDefaults] stringForKey: @"userfacebookid"]];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidFinishSwipingNotification object:self.recipes];
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
