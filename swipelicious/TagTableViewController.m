//
//  TagTableViewController.m
//  swipelicious
//
//  Created by Augusto Guido on 9/7/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import "swipelicious-Swift.h"
#import "TagTableViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

@interface TagTableViewController ()

@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) NSMutableArray *selectedIds;
@property (nonatomic, retain) NSMutableArray *selectedTitles;

@end

@implementation TagTableViewController

@synthesize tags;
@synthesize selectedIds;
@synthesize selectedTitles;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select Tags";
    self.selectedIds = [NSMutableArray new];
    self.selectedTitles = [NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    
    NSString *requestURL = [Tag getURL];
    
    NSURL *url = [NSURL URLWithString:requestURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *categories = [NSMutableArray new];
        for (NSDictionary *d in responseObject) {
            [categories addObject:[[Tag alloc] initWithData:d]];
        }
        self.tags = [categories copy];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
    [operation start];
}

- (void)done:(id)sender{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.finishedPickingTags(self.selectedTitles);
    }];
    [self.navigationController popViewControllerAnimated:YES];
    [CATransaction commit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tags count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TagCell" forIndexPath:indexPath];
    
    UILabel *label = [cell viewWithTag:1];
    Tag *tag = [self.tags objectAtIndex:indexPath.row];
    label.text = tag.title;
    
    if ([selectedTitles containsObject:tag.title])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    Tag *tag = [self.tags objectAtIndex:indexPath.row];
    
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedTitles addObject:tag.title];
    }else {
        newCell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedTitles removeObject:tag.title];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end
