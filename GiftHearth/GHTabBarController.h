//
//  GHTabBarController.h
//  GiftHearth
//
//  Created by Alex Vaccarino on 4/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "GHLoginViewController.h"
#import "GHFriendsViewController.h"
#import "GHWishlistViewController.h"
#import "NewWish.h"

@interface GHTabBarController : UITabBarController

@property (strong, nonatomic) GHFriendsViewController* friendsController;

- (void) populateUserDetails;
- (IBAction) saveWish: (UIStoryboardSegue*) segue;
- (IBAction) cancelWish: (UIStoryboardSegue*) segue;

@end
