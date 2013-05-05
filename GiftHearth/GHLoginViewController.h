//
//  GHLoginViewController.h
//  GiftHearth
//
//  Created by Alex Vaccarino on 4/30/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface GHLoginViewController: UIViewController <FBLoginViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView* loginView;

- (IBAction) performLogin: (id) sender;
- (void) loginFailed;

@end
