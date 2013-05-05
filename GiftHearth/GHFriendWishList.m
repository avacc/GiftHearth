//
//  GHFriendWishList.m
//  GiftHearth
//
//  Created by Alex Vaccarino on 5/5/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "GHFriendWishList.h"

@implementation GHFriendWishList

- (PFQuery*) queryForTable {
    PFQuery* query = [PFQuery queryWithClassName: @"Wish"];
    
    if(self.objects.count == 0){
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    NSLog(@"fbID: %@", self.fbUserID);
    NSLog(@"fbUserName: %@", self.fbUserName);
    [query whereKey: @"fbID" equalTo: self.fbUserID];
    [query orderByDescending: @"createdAt"];
    return query;
}

- (IBAction) saveFriendWish: (UIStoryboardSegue*) segue{
    NewWish* newWish = (NewWish*) segue.sourceViewController;
    if(newWish.wish.text.length == 0){
        
    }else{
        PFObject* wish = [PFObject objectWithClassName: @"Wish"];
        [wish setObject: [[PFUser currentUser] objectForKey: @"name"] forKey:@"addedBy"];
        NSLog(@"%@", newWish.wish.text);
        [wish setObject: self.fbUserID forKey: @"fbID"];
        [wish setObject: newWish.wish.text forKey: @"content"];
        [wish setObject: [NSNumber numberWithBool: NO] forKey: @"granted"];
        [wish save];
        [wish refresh];
    }
}

- (IBAction) cancel: (UIStoryboardSegue*) segue {
    
}
    
- (IBAction) done: (id) sender {
    [self.navigationController popToRootViewControllerAnimated: YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString: @"newFriendWish"]){
        NewWish* newWish = segue.destinationViewController;
        newWish.label.text = [newWish.label.text stringByAppendingFormat: @"%@", self.fbUserName];
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object: (PFObject*) object {
    PFTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier: @"WishCell"];
    if(!cell){
        cell = [[PFTableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:@"WishCell"];
    }
    cell.textLabel.text = [object objectForKey: @"content"];
    return cell;
}
@end
