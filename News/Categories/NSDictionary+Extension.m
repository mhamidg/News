//
//  NSDictionary+Extension.m
//  News
//
//  Created by Hamid Farooq on 11/21/18.
//  Copyright © 2018 Hamid Farooq. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

- (id)nullableObjectForKey:(id)key {
    if ((NSNull *)self[key] == [NSNull null])
        return nil;
    else
        return self[key];
}

- (id)nonnullObjectForKey:(id)key {
    if (self[key] == nil)
        return @"";
    else if ((NSNull *)self[key] == [NSNull null])
        return @"";
    else
        return self[key];
}

@end
