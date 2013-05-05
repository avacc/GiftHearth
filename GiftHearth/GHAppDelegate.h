//
//  AGVAppDelegate.h
//  GiftHearth
//
//  Created by Alex Vaccarino on 4/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>
#import "GHTabBarController.h"

@interface GHAppDelegate : UIResponder <UIApplicationDelegate, FBFriendPickerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) GHTabBarController* tabBarController;
@property (strong, nonatomic) GHLoginViewController* loginViewController;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;

- (void) openSession;
- (void) sessionStateChanged: (FBSession*) session state: (FBSessionState) state error: (NSError*) error;
- (void) showLoginView;
- (void) handleAppLink: (FBAccessTokenData*) appLinkToken;

@end
