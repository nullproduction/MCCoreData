//
//  People.h
//  MCCoreData
//
//  Created by Администратор on 8/2/13.
//  Copyright (c) 2013 Администратор. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Network;

@interface People : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * syncID;
@property (nonatomic, retain) NSSet *networks;
@end

@interface People (CoreDataGeneratedAccessors)

- (void)addNetworksObject:(Network *)value;
- (void)removeNetworksObject:(Network *)value;
- (void)addNetworks:(NSSet *)values;
- (void)removeNetworks:(NSSet *)values;

@end
