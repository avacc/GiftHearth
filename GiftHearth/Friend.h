//
//  Friend.h
//  GiftHearth
//
//  Created by Alex Vaccarino on 5/3/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Friend : NSManagedObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* id;
@property (strong, nonatomic) NSDate* birthday;


@end
