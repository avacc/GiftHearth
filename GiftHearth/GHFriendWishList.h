//
//  GHFriendWishList.h
//  GiftHearth
//
//  Created by Alex Vaccarino on 5/5/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "GHWishlistViewController.h"
#import "NewWish.h"

@interface GHFriendWishList : GHWishlistViewController

@property (strong, nonatomic) NSString* fbUserID;
@property (strong, nonatomic) NSString* fbUserName;

- (IBAction) saveFriendWish: (UIStoryboardSegue*) segue;
- (IBAction) cancel: (UIStoryboardSegue*) segue;
- (IBAction) done: (id) sender;

@end
