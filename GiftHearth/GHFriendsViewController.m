//
//  AGVFirstViewController.m
//  GiftHearth
//
//  Created by Alex Vaccarino on 4/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "GHFriendsViewController.h"
#import "GHAppDelegate.h"

@interface GHFriendsViewController ()
    
@end

@implementation GHFriendsViewController

int count = 0;
BOOL populated = NO;

- (id) init {
    self = [super init];
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.collectionView registerClass: [GHFriendViewCell class] forCellWithReuseIdentifier: @"Collection Cell Identifier"];
    self.friendsData = [[NSMutableArray alloc] init];
    self.allowsMultipleSelection = NO;
    self.cancelButton = nil;
    self.doneButton = self.done;
    self.sortOrdering = FBFriendDisplayByLastName;
    self.displayOrdering = FBFriendDisplayByFirstName;
    [self loadData];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (IBAction) logout: (id) sender {
    [[FBSession activeSession] closeAndClearTokenInformation];
    GHAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate showLoginView];
    
}

- (void) viewWillDisappear:(BOOL)animated {
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) facebookViewControllerDoneWasPressed:(id)sender {
    if(self.selection.count == 0){
        NSString* alertMessage = @"Please select a friend to view their wishlist";
        NSString* alertTitle = @"No friend selected";
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                    delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
    }else{
        [self performSegueWithIdentifier: @"friendWishlistSegue" sender: self];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString: @"friendWishlistSegue"]){
        GHFriendWishList* friendWishlistController = segue.destinationViewController;
        /*
        FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection* connection, id result, NSError* error) {
            if(!error){
                NSArray* friendObjects = [result objectForKey: @"data"];
                
            }
        }];*/
        NSDictionary<FBGraphUser>* friend = [self.selection objectAtIndex: 0];
        friendWishlistController.fbUserID = [friend objectForKey: @"id"];
        friendWishlistController.fbUserName = [friend objectForKey: @"name"];
    }

}

/*
- (void) populate: (NSMutableArray*) friendObjects{
    if(populated){
        
    }else{
        NSLog(@"populate: array size: %d", friendObjects.count);
        NSIndexPath* indexPath;
        //for(int i = 0; i < 20; i++){
            indexPath = [NSIndexPath indexPathForRow: 0 inSection: 0];
            [self.friendsData addObject: [friendObjects objectAtIndex: 0]];
            NSDictionary<FBGraphUser>* friend = [friendObjects objectAtIndex: 0];
            [self.collectionView insertItemsAtIndexPaths: [NSArray arrayWithObjects: indexPath, nil]];
            [self.collectionView reloadData];
            GHFriendViewCell* cell = (GHFriendViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            if(!cell){
                NSLog(@"cell not instantiated");
            }
            cell.name = friend.name;
            [cell setHidden: NO];
            NSLog(@"populate: cell: %@", cell);
        
            NSLog(@"populate: cell.name.text: %@", cell.name);
            /*cell.name.text = [friendObject objectForKey: @"name"];
             NSLog(@"%@", cell.name.text);
             cell.birthday.text = [friendObject objectForKey: @"birthday"];
             NSString* stringURL = [[NSString alloc] initWithFormat: @"https://graph.facebook.com/%@/       picture?type=normal", [friendObject objectForKey: @"name"]];
             NSURL* url = [[NSURL alloc] initWithString: stringURL];
             UIImage* profilePic = [UIImage imageWithData: [NSData dataWithContentsOfURL: url]];
             cell.image.image = profilePic;
        //}
        populated = YES;
    }
}

- (BOOL) populated{
    return populated;
}*/


#pragma mark - NSFetchedResultsController methods

- (NSFetchedResultsController*) fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        NSLog(@"_fetchedResultsController is already instantiated");
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Friend" inManagedObjectContext: _managedObjectContext];
    [fetchRequest setEntity: entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey: @"birthday" ascending: NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject: sort]];
    
    [fetchRequest setFetchBatchSize: 20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath: nil cacheName: @"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    NSLog(@"_fetchedResultsController instantiated");
    return _fetchedResultsController;
    
}
/*
#pragma mark - UICollectionViewDataSource methods

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.friendsData count];
}

- (GHFriendViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"*******Cell for row******");
    
    GHFriendViewCell* cell = (GHFriendViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier: @"FriendViewCell" forIndexPath: indexPath];
    [self configureCell: cell atIndexPath: indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView* header = nil;
    
    if ([kind isEqual:UICollectionElementKindSectionHeader])
    {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:@"Header"
                                                           forIndexPath:indexPath];
        
    }
    return header;
}

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

- (void) configureCell: (GHFriendViewCell*) cell atIndexPath: (NSIndexPath*) indexPath{
    NSDictionary<FBGraphUser>* friend = [self.friendsData objectAtIndex: indexPath.row];
    cell.name = friend.name;
    cell.birthday = friend.birthday;
    NSString* stringURL = [[NSString alloc] initWithFormat: @"https://graph.facebook.com/%@/picture?type=normal", friend.id];
    NSURL* url = [[NSURL alloc] initWithString: stringURL];
    UIImage* profilePic = [UIImage imageWithData: [NSData dataWithContentsOfURL: url]];
    cell.image = profilePic;
}*/
@end
