//
//  DataStore.h
//  sample_db
//
//  Created by Krishna Prabha S on 7/21/15.
//  Copyright (c) 2015 KaryaTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DataStore : NSObject

@property (nonatomic, assign) sqlite3 *sqliteDB;
@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic, assign) BOOL encryption;

-(BOOL) DBOperation:(NSMutableArray*) data :(NSString*) tableName;

+ (DataStore *)getSharedInstance;
- (void)setupDatabase:(NSString *)databaseName encryption:(BOOL) cipher;

- (BOOL)performDataUpdateOperationWithQuery:(NSString *)queryString andOperationString:(NSString *)operation;
- (NSArray *)performDataSelectionWithQuery:(NSString *)queryString andOperationString:(NSString *)operation;
@end


