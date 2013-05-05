//
//  GHWishlistViewController.m
//  GiftHearth
//
//  Created by Alex Vaccarino on 4/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "GHWishlistViewController.h"
#import "GHAppDelegate.h"
#import <objc/runtime.h>

@implementation GHWishlistViewController

- (void) viewWillAppear: (BOOL)animated {
    
}

/*
#pragma mark - UITableViewDataSource methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(![[PFUser currentUser] objectForKey: @"wishes"]){
        return 0;
    }else{
        
        NSMutableArray* wishes = (NSMutableArray*)[[PFUser currentUser] objectForKey: @"wishes"];
        return wishes.count;
    }
}*/

- (PFQuery*) queryForTable {
    PFQuery* query = [PFQuery queryWithClassName: @"Wish"];
    
    if(self.objects.count == 0){
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    //[query whereKey: @"fbID" equalTo: [[PFUser currentUser] objectForKey: @"fbID"]];
    [query orderByDescending: @"createdAt"];
    return query;
}

- (IBAction) logout: (id) sender {
    [[FBSession activeSession] closeAndClearTokenInformation];
    GHAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate showLoginView];
    
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object: (PFObject*) object {
    PFTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier: @"WishCell"];
    if(!cell){
        cell = [[PFTableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:@"WishCell"];
    }
    cell.textLabel.text = [object objectForKey: @"content"];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"Added by: %@", [object objectForKey: @"addedBy"]];
    if([[object objectForKey: @"granted"] isEqualToNumber: [NSNumber numberWithBool: YES]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSMutableArray* wishes = [NSMutableArray arrayWithArray: [[PFUser currentUser] objectForKey: @"wishes"]];
        if([wishes count] > 0){
            NSString* objID = [wishes objectAtIndex: indexPath.row];
            PFQuery* query = [PFQuery queryWithClassName: @"Wish"];
            PFObject* wish = [query getObjectWithId:objID];
            [wishes removeObject: objID];
            NSArray* wishs = [NSArray arrayWithArray: wishes];
            [[PFUser currentUser] setObject: wishs forKey: @"wishes"];
            [[PFUser currentUser] saveInBackground];
            [wish deleteInBackground];
            [self.tableView reloadData];
        }
    }
}

- (void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    PFTableViewCell* cell = [self.tableView cellForRowAtIndexPath: indexPath];
    cell.highlighted = NO;
    NSArray* wishes = [[PFUser currentUser] objectForKey: @"wishes"];
    PFQuery* query = [PFQuery queryWithClassName: @"Wish"];
    PFObject* wish = [query getObjectWithId: [wishes objectAtIndex: indexPath.row]];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [wish setObject: [NSNumber numberWithBool: NO] forKey: @"granted"];
    }else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [wish setObject: [NSNumber numberWithBool: YES] forKey: @"granted"];
    }
    [wish saveInBackground];
    [self.tableView deselectRowAtIndexPath: indexPath animated: YES];
    [self.tableView reloadData];
}
@end
