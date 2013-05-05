//
//  AGVAppDelegate.m
//  GiftHearth
//
//  Created by Alex Vaccarino on 4/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "GHAppDelegate.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>


@implementation GHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.navigationController = (UINavigationController*) self.window.rootViewController;
    self.tabBarController = (GHTabBarController*) [self.navigationController.viewControllers objectAtIndex: 0];
    GHFriendsViewController* friendsController = [[self.tabBarController viewControllers] objectAtIndex: 0];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed: 10 green: 0 blue: 0 alpha: 200];
    [Parse setApplicationId: @"8WF5nAJQ35QELC4O2XNOZaB44KAeiHtGyg9FLHDo"
                  clientKey: @"tWc6UMB2Dpe5NDIaUt5PLO55Wvu97PRZuBg8ktLa"];
    [PFFacebookUtils initializeFacebook];
    if([FBSession activeSession].state == FBSessionStateOpen){
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // Store the current user's Facebook ID on the user
                [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                         forKey:@"fbId"];
                
                [[PFUser currentUser] saveInBackground];
            }else{
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    else if([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded){
        [self openSession];
    }else{
        [self showLoginView];
    }
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[FBSession activeSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[FBSession activeSession] close];
}



#pragma mark - Facebook Login

- (void) openSession {
    [PFFacebookUtils logInWithPermissions: [[NSArray alloc] initWithObjects: @"email", @"user_birthday", @"friends_birthday", @"user_photos", @"friends_photos", nil] block: ^(PFUser* user, NSError* error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            [self.navigationController popToRootViewControllerAnimated: NO];
            [[FBSession activeSession] closeAndClearTokenInformation];
            [self showLoginView];
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Store the current user's Facebook ID on the user
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                             forKey:@"fbId"];
                    
                    [[PFUser currentUser] saveInBackground];
                }else{
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
            [self.navigationController popToRootViewControllerAnimated: YES];
            
        } else {
            NSLog(@"User logged in through Facebook!");
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Store the current user's Facebook ID on the user
                    [[PFUser currentUser] setObject:[result objectForKey:@"name"]
                                             forKey:@"name"];
                    [[PFUser currentUser] setObject: [result objectForKey: @"id"] forKey: @"fbID"];
                    [[PFUser currentUser] saveInBackground];
                }
            }];
            [self.navigationController popToRootViewControllerAnimated: YES];
        }
    }];
    /*
    [FBSession openActiveSessionWithReadPermissions: [[NSArray alloc] initWithObjects: @"email", @"user_birthday", @"friends_birthday", @"user_photos", @"friends_photos", nil] allowLoginUI: NO completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        [self sessionStateChanged: session state: state error: error];
    }];*/
}

- (void) sessionStateChanged: (FBSession*) session state: (FBSessionState) state error: (NSError*) error {
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"sessionStateChanged: Open");
            UIViewController* topViewController = [self.navigationController topViewController];
            if([[topViewController presentedViewController] isKindOfClass: [GHLoginViewController class]]){
                //[topViewController dismissViewControllerAnimated: NO completion: nil];
                [self.navigationController popToRootViewControllerAnimated: YES];
            }
            break;
        }
        case FBSessionStateClosed:{
            NSLog(@"sessionStateChanged: Closed");
        }
            
        case FBSessionStateClosedLoginFailed: {
            NSLog(@"sessionStateChanged: ClosedLoginFailed");
            [self.navigationController popToRootViewControllerAnimated: NO];
            [[FBSession activeSession] closeAndClearTokenInformation];
            [self showLoginView];
            break;
        }
        default: {
            break;
        }
    }
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Error" message: error.localizedDescription
                                  delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void) showLoginView {
    UIViewController* topViewController = [self.navigationController topViewController];
    UIViewController* presentedViewController = [topViewController presentedViewController];
    
    if(![presentedViewController isKindOfClass: [GHLoginViewController class]]){
        [topViewController performSegueWithIdentifier: @"LoginViewSegue" sender: topViewController];
    }else{
        GHLoginViewController* loginViewController = (GHLoginViewController*) presentedViewController;
        [loginViewController loginFailed];
    }
}


- (BOOL) application: (UIApplication*) application openURL: (NSURL*) url sourceApplication: (NSString*)sourceApplication annotation: (id) annotation {
    return [PFFacebookUtils handleOpenURL: url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void) handleAppLink:(FBAccessTokenData*) appLinkToken{
    FBSession* appLinkSession = [[FBSession alloc] initWithAppID: nil
                                                    permissions: nil
                                                    defaultAudience: FBSessionDefaultAudienceNone
                                                    urlSchemeSuffix: nil
                                                    tokenCacheStrategy: [FBSessionTokenCachingStrategy nullCacheInstance]
                                 ];
    [FBSession setActiveSession: appLinkSession];
    [appLinkSession openFromAccessTokenData: appLinkToken completionHandler:^(FBSession* session, FBSessionState status, NSError* error) {
        if(error){
            NSLog(@"handleAppLink: %@", error.localizedDescription);
        }
    }];
}
@end
