//
//  FriendsViewController.m
//  swipelicious
//
//  Created by Augusto Guido on 9/12/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import "FriendsViewController.h"

#import "swipelicious-Swift.h"

#import "FriendTableViewCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@import Haneke;

@interface FriendsViewController ()

@property (nonatomic, retain) NSArray *friends;

@end

@implementation FriendsViewController

@synthesize friends;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *fbid = [[[AppSession sharedInstance] user] fbid];
    NSString *path = [NSString stringWithFormat:@"/%@/friends?fields=name,picture", fbid];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:path
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        self.friends = [result objectForKey:@"data"];
        [self.friendsTable reloadData];
    }];
    
    self.title = @"My Friends";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)inviteMore:(id)sender{
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://itunes.apple.com/uy/app/gameon-edicion-copa-america/id986474919?l=es&mt=8"];
    
    //content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.swipelicious.com/my_invite_image.jpg"];
    
    [FBSDKAppInviteDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"%@", results);
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell *cell = (FriendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    id friend = self.friends[indexPath.row];
    cell.friendNameLabel.text = [friend objectForKey:@"name"];
    NSURL *url = [NSURL URLWithString:friend[@"picture"][@"data"][@"url"]];
    [cell.friendImage hnk_setImageFromURL:url];
    
    return cell;
}

@end
