//
//  ComposeViewController.h
//  twitter
//
//  Created by Edo Wiliams on 10/20/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface WriteTweetVC : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Tweet *tweet;

@end
