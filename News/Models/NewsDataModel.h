//
//  NewsDataModel.h
//  News
//
//  Created by Hamid Farooq on 11/21/18.
//  Copyright © 2018 Hamid Farooq. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NewsDataModel : NSManagedObject

@property (nonatomic) NSString *sourceId;
@property (nonatomic) NSString *sourceName;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *auther;
@property (nonatomic) NSString *content;
@property (nonatomic) NSString *descriptions;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *urlToImage;
@property (nonatomic) NSDate *publishedAt;

@end
