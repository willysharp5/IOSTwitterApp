//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (NSString *)id
{
    return [self.data valueOrNilForKeyPath:@"id_str"];
}

- (NSString *)text
{
    return [self.data valueOrNilForKeyPath:@"text"];
}

- (NSDate *)createdAt
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EE MM dd HH:mm:ss ZZZ yyyy"];
    }
    return [formatter dateFromString:[self.data valueOrNilForKeyPath:@"created_at"]];
}

- (NSInteger)retweetCount
{
    return [[self.data valueOrNilForKeyPath:@"retweet_count"] integerValue];
}

- (NSInteger)favoriteCount
{
    return [[self.data valueOrNilForKeyPath:@"favorite_count"] integerValue];
}

- (NSArray *)userMentions
{
    NSDictionary *entities = [self.data valueOrNilForKeyPath:@"entities"];
    return [entities valueOrNilForKeyPath:@"user_mentions"];
}

- (User*)user
{
    NSDictionary *user = [self.data valueOrNilForKeyPath:@"user"];
    return [[User alloc] initWithDictionary:user];
}

- (void)setRetweeting:(BOOL)retweeted
{
    _retweeting = @(retweeted);
}

- (BOOL)retweeting
{
    if (_retweeting != nil) {
        return [_retweeting boolValue];
    } else {
        return [[self.data valueOrNilForKeyPath:@"retweeted"] integerValue];
    }
}

- (void)setFavoriting:(BOOL)favorited
{
    _favoriting = @(favorited);
}

- (BOOL)favoriting
{
    if (_favoriting != nil) {
        return [_favoriting boolValue];
    } else {
        return [[self.data valueOrNilForKeyPath:@"favorited"] integerValue];
    }
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array
{
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:params]];
    }
    return tweets;
}

@end
