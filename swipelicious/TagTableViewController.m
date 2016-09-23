//
//  TagTableViewController.m
//  swipelicious
//
//  Created by Augusto Guido on 9/7/16.
//  Copyright © 2016 dennis. All rights reserved.
//

#import "swipelicious-Swift.h"
#import "TagTableViewController.h"

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
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:requestURL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSMutableArray *categories = [NSMutableArray new];
        for (NSDictionary *d in responseObject) {
            [categories addObject:[[Tag alloc] initWithData:d]];
        }
        self.tags = [categories copy];
        [self.tableView reloadData];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
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
