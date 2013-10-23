//
//  WriteTweetVC.m
//  twitter
//
//  Created by Edo williams on 10/20/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "WriteTweetVC.h"
#import "User.h"

@interface WriteTweetVC ()

@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UIImageView *pictureProfileimageView;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screennamelabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;


- (IBAction)onCancelButton;
- (IBAction)onTweetButton;

@end

@implementation WriteTweetVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    User *user = [User currentUser];
    
    
    //Image
    NSURL *url = [NSURL URLWithString:user.profilePicture];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    self.pictureProfileimageView.image = image;
    
    //Name
    self.fullnameLabel.text = user.fullname;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
    
    //Tweet text
    if (self.tweet) {
        NSMutableString *string = [[NSMutableString alloc] init];
        [string appendString:[NSString stringWithFormat:@"@%@ ", user.screenName]];
        for (NSDictionary *params in self.tweet.userMentions) {
            [string appendString:[NSString stringWithFormat:@"@%@ ", params[@"screenName"]]];
        }
        self.textView.text = string;
    } else {
        self.textView.text = @"";
    }
    
    //Text count and Keyboard show
    [self textViewDidChange:self.textView];
    [self.textView becomeFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger length = [textView.text length];
    self.screennamelabel.hidden = length > 0;
    self.lengthLabel.text = [NSString stringWithFormat:@"%d", 140 - length];
}

- (IBAction)onCancelButton
{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTweetButton
{
    self.tweetButton.enabled = NO;
    [[TwitterClient instance] tweetingResponseWithStatusId:self.textView.text ResponseStatusId:self.tweet.id success:^(AFHTTPRequestOperation *operation, id response) {
        self.tweetButton.enabled = YES;
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popViewControllerAnimated:YES];
        [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Tweeted!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.tweetButton.enabled = YES;
        [self onError:error];
    }];
}

- (void)onError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't access twitter, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


@end
