//
//  AppController.h
//  News
//
//  Created by Hamid Farooq on 11/21/18.
//  Copyright © 2018 Hamid Farooq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface AppController : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (void)fetchUpdatedNews;

- (void)saveContext;

@end
