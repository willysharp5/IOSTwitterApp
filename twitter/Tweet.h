//
//  Tweet.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : RestObject {
    NSNumber *_retweeting;
    NSNumber *_favoriting;
}

- (NSString *)id;
- (NSString *)text;
- (NSArray *)userMentions;
- (NSInteger)retweetCount;
- (NSDate *)createdAt;
- (NSInteger)favoriteCount;


- (User *)user;

@property (assign, nonatomic) BOOL favoriting;
@property (assign, nonatomic) BOOL retweeting;

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array;

@end
