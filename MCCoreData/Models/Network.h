//
//  Network.h
//  MCCoreData
//
//  Created by Администратор on 8/2/13.
//  Copyright (c) 2013 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class People;

@interface Network : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) People *people;

@end
