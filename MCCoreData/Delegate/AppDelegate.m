//
//  AppDelegate.m
//

#import "AppDelegate.h"

@implementation AppDelegate

#define DropboxAppKey @"f5o28idtrkxzb14"
#define DropboxAppSecret @"a7cm88dd6jpesm6"


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // MagicalRecord
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Storage.sqlite"];
    
    // Dropbox
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:DropboxAppKey secret:DropboxAppSecret];
    [DBAccountManager setSharedManager:accountManager];
    
    if ([accountManager linkedAccount]) {
        [self setSyncEnabled:YES];
    }
    
    return YES;
}


/*
 * Set sync enabled
 */
- (void)setSyncEnabled:(BOOL)enabled
{
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    
    if (enabled) {
        if (!self.syncManager) {
            DBAccount *account = [accountManager linkedAccount];
            
            if (account) {
                __weak typeof(self) weakSelf = self;
                [accountManager addObserver:self block:^(DBAccount *account) {
                    typeof(self) strongSelf = weakSelf; if (!strongSelf) return;
                    if (![account isLinked]) {
                        [strongSelf setSyncEnabled:NO];
                        NSLog(@"Unlinked account: %@", account);
                    }
                }];
                
                DBError *dberror = nil;
                DBDatastore *datastore = [DBDatastore openDefaultStoreForAccount:account error:&dberror];
                if (datastore) {
                    //self.syncManager = [[PKSyncManager alloc] initWithManagedObjectContext:self.managedObjectContext datastore:datastore];
                    self.syncManager = [[PKSyncManager alloc] initWithManagedObjectContext:[NSManagedObjectContext MR_rootSavingContext] datastore:datastore];
                    
                    [self.syncManager setTablesForEntityNamesWithDictionary:@{@"People": @"peoples", @"Network": @"networks"}];
                    
                    NSError *error = nil;
                    if (![self addMissingSyncAttributeValueToCoreDataObjects:&error]) {
                        NSLog(@"Error adding missing sync attribute value to Core Data objects: %@", error);
                    } else if ([[datastore getTables:nil] count] == 0) {
                        if (![self updateDropboxFromCoreData:&error]) {
                            NSLog(@"Error updating Dropbox from Core Data: %@", error);
                        }
                    }
    
                } else {
                    NSLog(@"Error opening default datastore: %@", dberror);
                }
            }
        }
        
        [self.syncManager startObserving];
    } else {
        [self.syncManager stopObserving];
        self.syncManager = nil;
        
        [accountManager removeObserver:self];
    }
}



/*
 * Add missing sync attribute value to core data objects
 */
- (BOOL)addMissingSyncAttributeValueToCoreDataObjects:(NSError **)error
{
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [managedObjectContext setUndoManager:nil];
    
    NSString *syncAttributeName = self.syncManager.syncAttributeName;
    NSArray *entityNames = [self.syncManager entityNames];
    for (NSString *entityName in entityNames) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == nil", syncAttributeName]];
        [fetchRequest setFetchBatchSize:25];
        
        NSArray *objects = [managedObjectContext executeFetchRequest:fetchRequest error:error];
        if (objects) {
            for (NSManagedObject *managedObject in objects) {
                if (![managedObject valueForKey:syncAttributeName]) {
                    [managedObject setValue:[PKSyncManager syncID] forKey:syncAttributeName];
                }
            }
        } else {
            return NO;
        }
    }
    
    if ([managedObjectContext hasChanges]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncManagedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        BOOL saved = [managedObjectContext save:error];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        return saved;
    }
    
    return YES;
}


/*
 * Update dropbox from CoreData
 */
- (BOOL)updateDropboxFromCoreData:(NSError **)error
{
    if (![self addMissingSyncAttributeValueToCoreDataObjects:error]) {
        return NO;
    }
    
    __block BOOL result = YES;
    NSManagedObjectContext *managedObjectContext = self.syncManager.managedObjectContext;
    DBDatastore *datastore = self.syncManager.datastore;
    NSString *syncAttributeName = self.syncManager.syncAttributeName;
    
    NSDictionary *tablesByEntityName = [self.syncManager tablesByEntityName];
    [tablesByEntityName enumerateKeysAndObjectsUsingBlock:^(NSString *entityName, NSString *tableId, BOOL *stop) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [fetchRequest setFetchBatchSize:25];
        
        NSArray *managedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:error];
        if (managedObjects) {
            for (NSManagedObject *managedObject in managedObjects) {
                DBTable *table = [datastore getTable:tableId];
                DBError *dberror = nil;
                DBRecord *record = [table getOrInsertRecord:[managedObject valueForKey:syncAttributeName] fields:nil inserted:NULL error:&dberror];
                if (record) {
                    [record pk_setFieldsWithManagedObject:managedObject syncAttributeName:syncAttributeName];
                } else {
                    if (error) {
                        *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
                    }
                    result = NO;
                    *stop = YES;
                }
            }
        } else {
            *stop = YES;
        }
    }];
    
    if (result) {
        DBError *dberror = nil;
        if ([datastore sync:&dberror]) {
            return YES;
        } else {
            if (error) *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
            return NO;
        }
    } else {
        return NO;
    }
}

/*
 * Sync managed object context did save
 */
- (void)syncManagedObjectContextDidSave:(NSNotification *)notification
{
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}


- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    return [NSPersistentStoreCoordinator MR_defaultStoreCoordinator];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        return YES;
    }
    return NO;
}

@end
