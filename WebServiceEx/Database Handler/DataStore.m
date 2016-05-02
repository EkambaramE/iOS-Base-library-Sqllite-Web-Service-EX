//
//  NSObject+DataStore.m
//  sample_db
//
//  Created by Krishna Prabha S on 7/21/15.
//  Copyright (c) 2015 KaryaTechnologies. All rights reserved.
//

#import "DataStore.h"

static DataStore *sharedInstance;

@implementation DataStore

@synthesize sqliteDB, databasePath, encryption;

 +(DataStore *)getSharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[self alloc]init];
        }
    });
    
    return sharedInstance;
}

- (void)setupDatabase:(NSString *)databaseName encryption:(BOOL)cipher {
    
    if ([self initDataStore:databaseName encryption:cipher]) {
        NSLog(@"Database Created Succesfully ");
    }
}

- (BOOL)performDataUpdateOperationWithQuery:(NSString *)queryString andOperationString:(NSString *)operation
{
    if (queryString)
    {
       return [self CIDUOperation:queryString operation:operation];
    }
    return NO;
}

- (NSArray *)performDataSelectionWithQuery:(NSString *)queryString andOperationString:(NSString *)operation
{
    if (queryString) {
        NSArray *resultData = [self SCOperation:queryString operation:operation];
        return resultData;
    }
    return nil;
}

- (BOOL) initDataStore:(NSString*) databaseName encryption:(BOOL) cipher {
    NSArray *directoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = directoryPath[0];
    encryption = cipher;
    databasePath = [[NSString alloc] initWithString:[documentDirectory stringByAppendingPathComponent:databaseName]];
    NSLog(@"database File Path %@",databasePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:databasePath] == NO) {
        const char *dbPath = [databasePath UTF8String];
        if (sqlite3_open(dbPath, &sqliteDB) == SQLITE_OK) {
            NSLog(@"Database Created Succesfully...!");
        } else {
            NSLog(@"Database Creation Failed...!");
        }
    } else {
        NSLog(@"Database already Created...!");
    }
    return YES;
}

-(BOOL) DBOperation:(NSMutableArray*) data :(NSString*) tableName {
    const char *dbPath = [databasePath UTF8String];
    NSString *query, *columnNames, *values;
    sqlite3_stmt *sqlite_stmt;
    NSMutableArray *err = [[NSMutableArray alloc] init];
    const char *sql_statement;
    NSArray *keys = [data[0] allKeys];
    if (sqlite3_open(dbPath, &sqliteDB) == SQLITE_OK) {
        for (int i = 0; i < data.count; i++) {
            for (int j = 0; j < keys.count; j++) {
                if (j == (keys.count - 1)) {
                    columnNames = [columnNames stringByAppendingString:@"%@"];
                    columnNames = [NSString stringWithFormat:columnNames, keys[j]];
                    if ([[data[i] valueForKey:keys[j]] isKindOfClass:[NSString class]]) {
                        values = [values stringByAppendingString:@"'%@'"];
                        values = [NSString stringWithFormat:values, [data[i] valueForKey:keys[j] ]];
                    } else {
                        values = [values stringByAppendingString:@"%@"];
                        values = [NSString stringWithFormat:values, [data[i] valueForKey:keys[j] ]];
                    }
                } else {
                    columnNames = [self columnNameGenerator:columnNames :keys[j]];
                    if ([[data[i] valueForKey:keys[j]] isKindOfClass:[NSString class]]) {
                        values = [self valuesGenerator:values :[data[i] valueForKey:keys[j]]];
                    } else {
                        values = [self columnNameGenerator:values :[data[i] valueForKey:keys[j]]];
                    }
                }
            }
            query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName, columnNames, values];
            sql_statement = [query UTF8String];
 //           const char* key = [@"StrongPassword" UTF8String];
//            if (encryption) {
//                sqlite3_key(sqliteDB, key, (int)strlen(key));
//            }
            if (sqlite3_prepare_v2(sqliteDB, sql_statement, -1, &sqlite_stmt, NULL) == SQLITE_OK) {
                if (sqlite3_step(sqlite_stmt) != SQLITE_DONE) {
                    [err addObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(sqliteDB)]];
                    NSLog(@"ERROR->%s", sqlite3_errmsg(sqliteDB));
                }
            }
        }
    } else {
       [err addObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(sqliteDB)]];
        NSLog(@"ERROR->%s", sqlite3_errmsg(sqliteDB));
    }
    if (err.count > 0) {
        return false;
    }
    return true;
}

-(NSString*) valuesGenerator:(NSString*) columnName :(NSString*) value {
    return [self characterAppending:@"'%@', " :value];
}

-(NSString*)columnNameGenerator:(NSString*) columnName :(NSString*) value {
    return [self characterAppending:@"%@, " :value];
}

-(NSString*) characterAppending:(NSString*) character :(NSString*) value {
    return [NSString stringWithFormat:character, value];
}

-(BOOL) CIDUOperation:(NSString*) query operation:(NSString*) operation {
    const char *dbPath = [databasePath UTF8String];
    const char *sql_statement = [query UTF8String];
    sqlite3_stmt *sqlite_stmt;
    BOOL result = false;
    
    if (sqlite3_open(dbPath, &sqliteDB) == SQLITE_OK) {
//        const char* key = [@"StrongPassword" UTF8String];
//        if (encryption) {
//            sqlite3_key(sqliteDB, key, (int)strlen(key));
//        }
        if (sqlite3_prepare_v2(sqliteDB, sql_statement, -1, &sqlite_stmt, NULL) == SQLITE_OK) {
            if (sqlite3_step(sqlite_stmt) == SQLITE_DONE) {
                result = true;
                NSLog(@"%@ is Success...!", operation);
            } else {
                NSLog(@"%@ is Failed...!", operation);
            }
            sqlite3_finalize(sqlite_stmt);
        } else {
            NSLog(@"Database Error-> %s", sqlite3_errmsg(sqliteDB));
        }
        sqlite3_close(sqliteDB);
    } else {
        NSLog(@"Database is not opened...!");
    }
    return result;
}

-(NSMutableArray*)SCOperation:(NSString*) query operation:(NSString*) operation {
    
    const char *dbPath = [databasePath UTF8String];
    const char *sql_statement = [query UTF8String];
    sqlite3_stmt *sqlite_stmt;
    NSMutableArray *result = [NSMutableArray array];
    //NSNumber *count;
    
    if (sqlite3_open(dbPath, &sqliteDB) == SQLITE_OK) {
        
//        const char* key = [@"StrongPassword" UTF8String];
        
//        if (encryption) {
//            
//            sqlite3_key(sqliteDB, key, (int)strlen(key));
//            
//        }
        
        if (sqlite3_prepare_v2(sqliteDB, sql_statement, -1, &sqlite_stmt, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(sqlite_stmt) == SQLITE_ROW) {
                
                //if ([operation isEqualToString:@"Selection"]) {
                    
                    NSMutableDictionary *dictionaryValues = [[NSMutableDictionary alloc] init];
                    
                    for (int i = 0; i < sqlite3_data_count(sqlite_stmt); i++) {
                        
                        if (sqlite3_column_text(sqlite_stmt, i)) {
                            
                            [dictionaryValues setValue:[NSString stringWithUTF8String:(char *) sqlite3_column_text(sqlite_stmt, i)] forKey:[NSString stringWithUTF8String:(char *) sqlite3_column_name(sqlite_stmt, i)]];
                            
                        }
                        
                    }
                    
                    [result addObject:dictionaryValues];
                    
                    NSLog(@"%@ Selection Successful...!", operation);
                    
//                } else {
//                    
//                    count = [NSNumber numberWithInt:sqlite3_column_int(sqlite_stmt, 0)];
//                    
//                }
            }
//            if ([operation isEqualToString:@"Counting"]) {
//                
//                [result addObject:count];
//            }
            
        } else {
            
            NSLog(@"Database Error-> %s", sqlite3_errmsg(sqliteDB));
            
        }
        
        sqlite3_finalize(sqlite_stmt);
        
    } else {
        
        NSLog(@"Database is not opened...!");
        
    }
    sqlite3_close(sqliteDB);
    
    return result;
}



@end

