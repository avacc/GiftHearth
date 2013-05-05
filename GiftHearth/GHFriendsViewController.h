//
//  AGVFirstViewController.h
//  GiftHearth
//
//  Created by Alex Vaccarino on 4/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
#import "GHFriendWishList.h"

@interface GHFriendsViewController : FBFriendPickerViewController <FBFriendPickerDelegate>


@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem* done;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSMutableArray* friendsData;

- (void) populate: (NSMutableArray*) friendObjects;
- (IBAction) logout: (id) sender;
- (BOOL) populated;
@end
