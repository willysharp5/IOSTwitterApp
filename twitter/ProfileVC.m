//
//  TweetViewController.m
//  twitter
//
//  Created by Edo Williams on 10/20/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "ProfileVC.h"
#import "WriteTweetVC.h"

@interface ProfileVC ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (strong, nonatomic) IBOutlet UILabel *retweetTotal;
@property (strong, nonatomic) IBOutlet UILabel *favouriteTotal;

@property (strong, nonatomic) WriteTweetVC *writeTweetVC;


- (void)onWriteTweetButton;
- (IBAction)onReplyButton;
- (IBAction)onRetweetButton;
- (IBAction)onFavoriteButton;

- (void)onError:(NSError *)error;

@end

@implementation ProfileVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    //Set Image
    UIImage *image = [UIImage imageNamed:@"twitter"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imageView;
    

    //Navigation properties settings
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose"] style:UIBarButtonItemStylePlain target:self action:@selector(onWriteTweetButton)];


    [self.retweetButton setImage:[UIImage imageNamed:@"retweet_hover"] forState:UIControlStateSelected|UIControlStateDisabled];
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_hover"] forState:UIControlStateSelected];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    
    User *user = self.tweet.user;
    
    //Image
    NSURL *url = [NSURL URLWithString:user.profilePicture];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    self.profileImageView.image = image;

    //Name
    self.fullnameLabel.text = user.fullname;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];

    //Tweet Text
    self.tweetTextLabel.text = self.tweet.text;

    //Date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    self.timeStampLabel.text = [formatter stringFromDate:self.tweet.createdAt];

    //fav and Retweet Totals
    self.favouriteTotal.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    self.retweetTotal.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    
    //button hover on and off
    self.retweetButton.enabled = !self.tweet.retweeting;
    self.retweetButton.selected = self.tweet.retweeting;
    self.favoriteButton.selected = self.tweet.favoriting;
    
}

- (void)viewDidLayoutSubviews
{
    [self.tweetTextLabel sizeToFit];
}

# pragma mark - Private methods
- (IBAction)onReplyButton
{
    //Show the reply view
    self.writeTweetVC.tweet = self.tweet;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:self.writeTweetVC animated:YES];
}

- (IBAction)onFavoriteButton
{
    self.favoriteButton.enabled = NO;
    if (self.tweet.favoriting) {
        [[TwitterClient instance] removeFavoriteRespondingWithStatusId:self.tweet.id success:^(AFHTTPRequestOperation *operation, id response) {
            
            //set favourite
            self.favoriteButton.enabled = YES;
            self.favoriteButton.selected = NO;
            self.tweet.favoriting = NO;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self onError:error];
        }];
    } else {
        [[TwitterClient instance] setfavoriteRespondingWithStatusId:self.tweet.id success:^(AFHTTPRequestOperation *operation, id response) {
            
            //set favourite
            self.tweet.favoriting = YES;
            self.favoriteButton.selected = YES;
            self.favoriteButton.enabled = YES;
            [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateSelected];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self onError:error];
        }];
    }
}


- (WriteTweetVC *)writeTweetVC
{
    if (!_writeTweetVC) {
        _writeTweetVC = [[WriteTweetVC alloc] init];
    }
    return _writeTweetVC;
}

- (IBAction)onRetweetButton
{
    self.retweetButton.enabled = NO;
    if (!self.tweet.retweeting) {
        [[TwitterClient instance] retweetRespondingWithStatusId:self.tweet.id success:^(AFHTTPRequestOperation *operation, id response) {
            
            self.tweet.retweeting = YES;
            self.retweetButton.selected = YES;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            self.retweetButton.enabled = YES;
            [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateSelected];
            [self onError:error];
        }];
    }
}

- (void)onWriteTweetButton
{
    self.writeTweetVC.tweet = nil;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:self.writeTweetVC animated:YES];
}



- (void)onError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't access twitter, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
