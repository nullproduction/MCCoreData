//
//  MCCoreDataManager.h
//  
//

#import <UIKit/UIKit.h>

#define kStoreURL @"Storage.sqlite"
#define kModelURL @"Model"

@interface MCCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedManager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
