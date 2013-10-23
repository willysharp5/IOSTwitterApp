//
//  User.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"


NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

NSString * const kCurrentUserKey = @"kCurrentUserKey";

@implementation User

- (NSString *)fullname
{
    return [self.data valueOrNilForKeyPath:@"name"];
}

- (NSString *)screenName
{
    return [self.data valueOrNilForKeyPath:@"screen_name"];
}

- (NSString *)profilePicture
{
    return [self.data valueOrNilForKeyPath:@"profile_image_url"];
}

- (NSInteger)Total
{
    return [[self.data valueOrNilForKeyPath:@"statuses_count"] integerValue];
}

- (NSInteger)totalFollowers
{
    return [[self.data valueOrNilForKeyPath:@"followers_count"] integerValue];
}

- (NSInteger)totalFriends
{
    return [[self.data valueOrNilForKeyPath:@"friends_count"] integerValue];
}

static User *_currentUser;

+ (User *)currentUser
{
    if (!_currentUser) {
        NSData *userData = [[NSUserDefaults standardUserDefaults] dataForKey:kCurrentUserKey];
        if (userData) {
            NSDictionary *userDictionary = [NSJSONSerialization JSONObjectWithData:userData options:NSJSONReadingMutableContainers error:nil];
            _currentUser = [[User alloc] initWithDictionary:userDictionary];
        }
    }
    
    return _currentUser;
}

+ (void)setCurrentUser:(User *)currentUser
{
    if (currentUser) {
        NSData *userData = [NSJSONSerialization dataWithJSONObject:currentUser.data options:NSJSONWritingPrettyPrinted error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:userData forKey:kCurrentUserKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentUserKey];
        [TwitterClient instance].accessToken = nil;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!_currentUser && currentUser) {
        _currentUser = currentUser; // Needs to be set before firing the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
    } else if (_currentUser && !currentUser) {
        _currentUser = currentUser; // Needs to be set before firing the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
    }
}

@end
