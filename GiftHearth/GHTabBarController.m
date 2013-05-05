//
//  GHTabBarController.m
//  GiftHearth
//
//  Created by Alex Vaccarino on 4/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "GHTabBarController.h"
#import "GHAppDelegate.h"


@implementation GHTabBarController

BOOL populated2 = NO;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSSet* extraFieldsForFriendRequest = [NSSet setWithObjects: @"birthday", nil];
    FBCacheDescriptor* cacheDescriptor = [FBFriendPickerViewController cacheDescriptorWithUserID: nil fieldsForRequest: extraFieldsForFriendRequest];
    [cacheDescriptor prefetchAndCacheForSession: [FBSession activeSession]];
    
    GHWishlistViewController* wishlistController = [self.viewControllers objectAtIndex: 1];
    //wishlistController = [wishlistController initWithStyle: UITableViewStyleGrouped className: @"Wish"];
    [wishlistController.tableView setFrame: CGRectMake(wishlistController.tableView.frame.origin.x, 38, wishlistController.tableView.frame.size.width, wishlistController.tableView.frame.size.height - self.navigationController.navigationBar.bounds.size.height)];
    NSLog(@"%f", (wishlistController.tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height));
    self.navigationController.navigationBarHidden = YES;
    wishlistController.pullToRefreshEnabled = YES;
    wishlistController.paginationEnabled = YES;
    wishlistController.objectsPerPage = 25;
    /*
    NSArray* wishes = (NSArray*)[[PFUser currentUser] objectForKey: @"wishes"];
    NSMutableArray* indexArray;
    for(int i = 0; i < [wishes count]; i++){
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow: i inSection: 0];
        [indexArray addObject: indexPath];
    }
    [wishlistController.tableView insertRowsAtIndexPaths: indexArray withRowAnimation: UITableViewRowAnimationAutomatic];
    for (int j = 0; j < [wishes count]; j++) {
        [wishlistController.tableView cellForRowAtIndexPath: [indexArray objectAtIndex: j]];
    }*/
}
- (void) viewWillAppear: (BOOL) animated {
    if([FBSession activeSession].isOpen && !populated2){
        //[self populateUserDetails];
        //GHFriendsViewController* friendsController = [self.viewControllers objectAtIndex: 0];
    }
}

- (IBAction) logout: (id) sender {
    [[FBSession activeSession] closeAndClearTokenInformation];
    GHAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate showLoginView];
    
}

- (IBAction) saveWish: (UIStoryboardSegue*) segue {
    NewWish* newWish = (NewWish*) segue.sourceViewController;
    if(newWish.wish.text.length == 0){
        
    }else{
        PFObject* wish = [PFObject objectWithClassName: @"Wish"];
        [wish setObject: [[PFUser currentUser] objectForKey: @"name"] forKey:@"addedBy"];
        NSLog(@"%@", newWish.wish.text);
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [wish setObject: [result objectForKey: @"id"] forKey: @"fbID"];
            }else{
                NSLog(@"saveNote: %@", error.localizedDescription);
            }
        }];
        [wish setObject: [PFUser currentUser].objectId forKey: @"user"] ;
        [wish setObject: newWish.wish.text forKey: @"content"];
        [wish setObject: [NSNumber numberWithBool: NO] forKey: @"granted"];
        [wish save];
        [wish refresh];
        NSArray* wishes;
        if(![[PFUser currentUser] objectForKey: @"wishes"]){
            wishes = [[NSArray alloc] initWithObjects: wish.objectId, nil];
            [[PFUser currentUser] setObject: wishes forKey: @"wishes"];
        }else{
            NSLog(@"objectID: %@", wish.objectId);
            NSMutableArray* array = [[NSMutableArray alloc] initWithArray: (NSArray*)[[PFUser currentUser] objectForKey: @"wishes"]];
            [array addObject: wish.objectId];
            wishes = [[NSArray alloc] initWithArray: array];
            [[PFUser currentUser] setObject: wishes forKey: @"wishes"];
        }
        [[PFUser currentUser] saveInBackground];
        GHWishlistViewController* wishlistViewController = [self.viewControllers objectAtIndex: 1];
        [wishlistViewController.tableView reloadData];
        /*
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow: [wishes count] inSection: 0];
        [wishlistViewController.tableView insertRowsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil] withRowAnimation: UITableViewRowAnimationAutomatic];
        [wishlistViewController.tableView cellForRowAtIndexPath: indexPath];
        */
    }
}

- (IBAction) cancelWish:(UIStoryboardSegue *)segue {
    
}

- (void) populateUserDetails {
    if([FBSession activeSession].isOpen){
        [[FBRequest requestForMe] startWithCompletionHandler:
        ^(FBRequestConnection* connection, NSDictionary<FBGraphUser>* user, NSError* error){
            if(!error){
                
                NSString* stringURL = [[NSString alloc] initWithFormat: @"https://graph.facebook.com/%@/picture?type=normal", user.id];
                NSURL* url = [[NSURL alloc] initWithString: stringURL];
                UIImage* profilePic = [UIImage imageWithData: [NSData dataWithContentsOfURL: url]];
                [[self.viewControllers objectAtIndex: 2] tabBarItem].image = profilePic;
            }else{
                NSLog(@"populateUserDetails: %@", error.localizedDescription);
            }
        }];
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection* connection, id result, NSError* error) {
            if(!error){
                NSArray* friendObjects = [result objectForKey: @"data"];
                NSArray* sortedFriends = [friendObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    //get the key value.
                    NSString *s1 = [obj1 objectForKey: @"birthday"];
                    NSString *s2 = [obj2 objectForKey: @"birthday"];
                    NSLog(@"Birthday: %@", s1);
                    
                    //Convert NSString to NSDate:
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    //Specify only 1 M for month, 1 d for day and 1 h for hour
                    [dateFormatter setDateFormat:@"MM/DD/YYYY"];
                    NSDate *d1 = [dateFormatter dateFromString: s1];
                    NSDate *d2 = [dateFormatter dateFromString: s2];
                    
                    if ([d1 compare:d2] == NSOrderedAscending)
                        return (NSComparisonResult)NSOrderedAscending;
                    if ([d1 compare:d2] == NSOrderedDescending)
                        return (NSComparisonResult)NSOrderedDescending;
                    return (NSComparisonResult)NSOrderedSame;
                }];
                //NSArray* friendObjects = [[result allValues] sortedArrayUsingSelector:@selector(compare:)];
                //NSArray* friendObjects = [[result objectForKey: @"data"] sort];
                
                NSMutableArray* friends = [NSMutableArray arrayWithCapacity: sortedFriends.count];
                //NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey: @"birthday" ascending: YES]
                for (NSDictionary* friendObject in sortedFriends) {
                    [friends addObject: friendObject];
                }
                [[self.viewControllers objectAtIndex: 0] populate: friends];
            }else{
                NSLog(@"populateUserDetails: %@", error.localizedDescription);
            }
        }];
        populated2 = YES;
    }
}

#pragma mark - Segue

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender {
    if([segue.identifier isEqualToString: @"LoginViewSegue"]){
        GHLoginViewController* loginViewController = segue.destinationViewController;
        loginViewController.navigationItem.hidesBackButton = YES;
    }
}

@end
