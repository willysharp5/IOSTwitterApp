//
//  TimelineVC.m
//  twitter
//
//  Created by Timothy Lee on 8/4/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TimelineVC.h"
#import "TweetCell.h"
#import "ProfileVC.h"
#import "WriteTweetVC.h"


@interface TimelineVC ()

@property (strong, nonatomic) NSMutableArray *tweets;
@property (strong, nonatomic) ProfileVC *profileVC;
@property (strong, nonatomic) WriteTweetVC *writeTweetVC;

- (void)onSignOutButton;
- (void)onComposeButton;
- (void)reload;

@end

@implementation TimelineVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Back";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Set the cell for display
    UINib *nib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TweetCell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //Set Navigation Properties
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose"] style:UIBarButtonItemStylePlain target:self action:@selector(onComposeButton)];

    //Set Image
    UIImage *image = [UIImage imageNamed:@"twitter"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imageView;
   

    //Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.refreshControl beginRefreshing];
    [self reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count; //set number of rows
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.tweets[indexPath.row];
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    cell.tweet = tweet;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set the width and hight of the cell for expanding text
    Tweet *tweet = self.tweets[indexPath.row];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:tweet.text];
    NSRange range = NSMakeRange(0, [string length]);
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:range];

    CGRect frame = [string boundingRectWithSize:CGSizeMake(250, 1000)
                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                        context:nil];
    return MAX(70.0, frame.size.height + 35);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //When row is selected show the profle view controller page
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Tweet *tweet = self.tweets[indexPath.row];
    self.profileVC.tweet = tweet;
    [self.navigationController pushViewController:self.profileVC animated:YES];
}

#pragma mark - Private methods

- (void)onSignOutButton
{
    [User setCurrentUser:nil];
}

- (void)onComposeButton
{
    self.writeTweetVC.tweet = nil;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:self.writeTweetVC animated:YES];
}

- (void)reload
{
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        // Do nothing
    }];
}

- (ProfileVC *)profileVC
{
    if (!_profileVC) {
        _profileVC = [[ProfileVC alloc] init];
    }
    return _profileVC;
}

- (WriteTweetVC *)writeTweetVC
{
    if (!_writeTweetVC) {
        _writeTweetVC = [[WriteTweetVC alloc] init];
    }
    return _writeTweetVC;
}


@end
