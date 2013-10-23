//
//  TweetCell.m
//  twitter
//
//  Created by Timothy Lee on 8/6/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TweetCell.h"

@interface TweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) IBOutlet UILabel *handleLabel;

- (IBAction)onFavoriteButton;

@end

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTweet:(Tweet *)tweet
{
    _tweet = tweet;
    User *user = tweet.user;
    
    // profile pic
    NSURL *url = [NSURL URLWithString:user.profilePicture];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    self.profileImageView.image = image;

    //Name, handle
    self.fullnameLabel.text = user.fullname;
    self.handleLabel.text = user.screenName;
    
    //fav Button
    self.favoriteButton.enabled = YES;
    [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateSelected];
    
    
    //Date
    float delta = [tweet.createdAt timeIntervalSinceNow] * -1;
    NSString * prettyTimestamp;
    
    if (delta < 60) {
        prettyTimestamp = @"now";
    }else if (delta < 120) {
        prettyTimestamp = @"1m";
    } else if (delta < 3600) {
        prettyTimestamp = [NSString stringWithFormat:@"%0dh", (int) floor(delta/60.0) ];
    } else if (delta < 7200) {
        prettyTimestamp = @"1h";
    } else if (delta < 86400) {
        prettyTimestamp = [NSString stringWithFormat:@"%dm", (int) floor(delta/3600.0) ];
    } else if (delta < ( 86400 * 2 ) ) {
        prettyTimestamp = @"1d";
    } else if (delta < ( 86400 * 7 ) ) {
        prettyTimestamp = [NSString stringWithFormat:@"%dd", (int) floor(delta/86400.0) ];
    }
    
    self.timeStampLabel.text = prettyTimestamp;
    
    //Tweet text
    self.tweetTextLabel.text = tweet.text;
}

# pragma mark - Private methods

- (IBAction)onFavoriteButton
{
    self.favoriteButton.enabled = NO;
    if (self.tweet.favoriting) {
        [[TwitterClient instance] removeFavoriteRespondingWithStatusId:self.tweet.id success:^(AFHTTPRequestOperation *operation, id response) {
            
            //set favourite
            self.favoriteButton.selected = NO;
            self.favoriteButton.enabled = YES;
            self.tweet.favoriting = NO;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self onError:error];
        }];
    } else {
        [[TwitterClient instance] setfavoriteRespondingWithStatusId:self.tweet.id success:^(AFHTTPRequestOperation *operation, id response) {
            
            //set favourite
            self.favoriteButton.selected = YES;
            self.favoriteButton.enabled = YES;
            self.tweet.favoriting = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self onError:error];
        }];
    }
}

- (void)onError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Network Error Try Again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
