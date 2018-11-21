//
//  AppController.m
//  News
//
//  Created by Hamid Farooq on 11/21/18.
//  Copyright © 2018 Hamid Farooq. All rights reserved.
//

#import "AppController.h"
#import <CoreData/CoreData.h>
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSDictionary+Extension.h"
#import "NewsDataModel.h"
#import "Constants.h"

@interface AppController ()
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@end

@implementation AppController

@synthesize persistentContainer=_persistentContainer;

+ (instancetype)sharedInstance {
    static id _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    return _sharedInstance;
}

- (NSManagedObjectContext *)managedObjectContext {
    return self.persistentContainer.viewContext;
}

#pragma mark - AFNetworking API Calls

- (void)fetchUpdatedNews {
    [SVProgressHUD showWithStatus:@"Loading news..."];
    
    // Generate the from date to get News
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *fromDate = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-(kDayIntervals * kNewsForDays)]];
    
    // Create URL with Query params
    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray array];
    [items addObject:[NSURLQueryItem queryItemWithName:@"q" value:@"bitcoin"]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"from" value:fromDate]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"sortBy" value:@"publishedAt"]];
    [items addObject:[NSURLQueryItem queryItemWithName:@"apiKey" value:kAPI_KEY]];
    
    NSURLComponents *components = [NSURLComponents componentsWithString:kAPI_URL];
    components.path = @"/v2/everything";
    components.queryItems = items;

    // Create API Request
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:components.URL];
    
    // Create AFNetworking Sessions to send request
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    // Send request to get data
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:NULL downloadProgress:NULL completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error == nil) {
            if ([responseObject isKindOfClass:NSDictionary.class]) {
                NSArray *articles = [responseObject objectForKey:@"articles"];
                
                for (NSDictionary *dictionary in articles) {
                    NewsDataModel *news = [self newsWithTitle:[dictionary nonnullObjectForKey:@"title"]];
                    if (news == nil) {
                        news = [NSEntityDescription insertNewObjectForEntityForName:@"News" inManagedObjectContext:self.managedObjectContext];
                    }
                    news.sourceId = [[dictionary nullableObjectForKey:@"source"] nonnullObjectForKey:@"id"];
                    news.sourceName = [[dictionary nullableObjectForKey:@"source"] nonnullObjectForKey:@"name"];
                    news.title = [dictionary nonnullObjectForKey:@"title"];
                    news.auther = [dictionary nonnullObjectForKey:@"auther"];
                    news.content = [dictionary nonnullObjectForKey:@"content"];
                    news.descriptions = [dictionary nonnullObjectForKey:@"description"];
                    news.url = [dictionary nonnullObjectForKey:@"url"];
                    news.urlToImage = [dictionary nonnullObjectForKey:@"urlToImage"];
                    
                    NSString *dateString = [dictionary nullableObjectForKey:@"publishedAt"];
                    if (dateString != nil) {
                        NSDateFormatter *formatter = [NSDateFormatter new];
                        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
                        news.publishedAt = [formatter dateFromString:dateString];
                    }
                }
                
                [self.managedObjectContext performBlockAndWait:^{
                    NSError *error = nil;
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"Unable to save context %@", error);
                    }
                }];
            }
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
            [alert addAction:actionButton];
            
            [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
        
        [SVProgressHUD dismiss];
    }];
    
    [dataTask resume];
}

#pragma mark - Core Data stack

- (NewsDataModel *)newsWithTitle:(NSString *)title {
    __block NSArray *results = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"News"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@", title];
    [fetchRequest setPredicate:predicate];
    
//    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"visitId" ascending:YES]]];
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results.firstObject;
}
                        
- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"News"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
