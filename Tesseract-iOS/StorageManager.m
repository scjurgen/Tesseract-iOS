//
//  StorageManager.m
//  Tesseract-iOS
//
//  Created by jay on 2/11/13.
//  Copyright (c) 2013 Jurgen Schwietering. All rights reserved.
//

#import "StorageManager.h"
#import <sqlite3.h>

// update this number to force copy of database in case of changes during development iteration
// this number is the user_version field in the sqlite.main
#define cCurrentDatabaseVersion 10101  // MSSBB  (main, sub, build)


@implementation StorageManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


#pragma mark - One store to manage them all

+ (id)handler {
    static StorageManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // launch once, make sure of correct singleton
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tesseract_iOS" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/** could this be done with core data????
 the problem is, if we change the storage type it is useless
 */
- (BOOL)invalidUserVersion:(NSString *)dbPath {
    // get current database user_version of schema
	sqlite3 *dbHandler;
    
    int nRet=sqlite3_open([dbPath UTF8String], &dbHandler);
    if (nRet != SQLITE_OK) {
        NSLog(@"WARNING: Can't open DB %s", sqlite3_errmsg(dbHandler));
    }
    static sqlite3_stmt *stmt_version;
    int databaseVersion=-1;
    
    if(sqlite3_prepare_v2(dbHandler, "PRAGMA user_version;", -1, &stmt_version, NULL) == SQLITE_OK) {
        while(sqlite3_step(stmt_version) == SQLITE_ROW) {
            databaseVersion = sqlite3_column_int(stmt_version, 0);
        }
        NSLog(@"%s: DatabaseVersion is: %d expected: %d (%@)", __FUNCTION__, databaseVersion,cCurrentDatabaseVersion,databaseVersion!=cCurrentDatabaseVersion?@"Copy needed":@"leaving as is");
    } else {
        NSLog(@"PRAGMA user_version %s: ERROR Preparing: , %s", __FUNCTION__, sqlite3_errmsg(dbHandler) );
    }
    sqlite3_finalize(stmt_version);
    
    return databaseVersion!=cCurrentDatabaseVersion;
}

/**
 if there is a fatal problem the store will be deleted and recopied from the bundle,
 it will also be deleted and copied when the version does not match  (cCurrentDatabaseVersion)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) { // don't use self here ;-)
        return _persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    NSString *storePath = [[self applicationDocumentsDirectoryAsString]
                           stringByAppendingPathComponent: @"Tesseract_iOS.sqlite"];
    
	BOOL oldVersion=[self invalidUserVersion:storePath];
    
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    // copy default db if it doesn't already exist
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (oldVersion | (![fileManager fileExistsAtPath:storePath])) {
        NSString *defaultStorePath = [[NSBundle mainBundle]
                                      pathForResource:@"Tesseract_iOS" ofType:@"sqlite"];
        if (defaultStorePath) {
            [fileManager removeItemAtPath:storePath error:&error];
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:&error];
            
        }
    }
    
    NSLog(@"DBURL=%@",storeUrl);
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[NSFileManager defaultManager] removeItemAtURL:storeUrl error:nil];
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"database error"
                                                          message:[NSString stringWithFormat:@"Fatal error!\n%@\nI will try restart the app but the whole thing could go down the drain!",[error userInfo]]
                                                         delegate:self
                                                cancelButtonTitle:@"darn!"
                                                otherButtonTitles:nil,
                                nil];
        [alertView show];
        if ([fileManager fileExistsAtPath:storePath]) // remove store and recopy from bundle
        {
            [fileManager removeItemAtPath:storePath error:nil];
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
                
                NSAssert(0,@"Hopeless situation on database...");
            }
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)applicationDocumentsDirectoryAsString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return documentsDir;
}


- (void)saveContext
{
    NSError *error = nil;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges])
        {
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}


@end
