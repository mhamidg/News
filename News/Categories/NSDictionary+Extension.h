//
//  NSDictionary+Extension.h
//  News
//
//  Created by Hamid Farooq on 11/21/18.
//  Copyright © 2018 Hamid Farooq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extension)

- (id)nullableObjectForKey:(id)key;

- (id)nonnullObjectForKey:(id)key;

@end
