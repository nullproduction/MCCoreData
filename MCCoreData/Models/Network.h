//
//  Network.h
//  MCCoreData
//
//  Created by Администратор on 8/1/13.
//  Copyright (c) 2013 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class People;

@interface Network : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) People *people;

@end
