//
//  DataOperation.m
//  sample_db
//
//  Created by Muthuraj M on 24/08/15.
//  Copyright (c) 2015 KaryaTechnologies. All rights reserved.
//

#import "DataOperation.h"
#import "DataStore.h"

@interface DataOperation ()

@property (nonatomic,strong) NSString *query;
@property (nonatomic,assign) DatabaseOperation databaseOperation;

@end

@implementation DataOperation

- (instancetype)initWithQuery:(NSString *)query andOperation:(DatabaseOperation)databaseOpeartion
{
    self = [super init];
    if (self) {
        self.query = query;
        self.databaseOperation = databaseOpeartion;
    }
    return self;
}

- (void)main
{
    [self performDatabaseOperation];
}

- (void)performDatabaseOperation
{
    [[DataStore getSharedInstance] setupDatabase:@"sample_DB.db" encryption:NO];
    BOOL status = NO;
    NSArray *resultDataArray = [NSArray array];
    
    switch (self.databaseOperation) {
        case CREATE:
          status= [[DataStore getSharedInstance] performDataUpdateOperationWithQuery:self.query andOperationString:@"Creation"];
            [self.delegate dataOperation:self OperationStatus:status resultDataArray:nil andItsCount:0];
            break;
       case INSERT:
            status= [[DataStore getSharedInstance] performDataUpdateOperationWithQuery:self.query andOperationString:@"Insertion"];
            [self.delegate dataOperation:self OperationStatus:status resultDataArray:nil andItsCount:0];
            break;
       case SELECT:
            resultDataArray = [[DataStore getSharedInstance] performDataSelectionWithQuery:self.query andOperationString:@"Selection"];
            int countValue = 0;
            if (resultDataArray) {
                countValue = (int)resultDataArray.count;
                status = YES;
            }
            [self.delegate dataOperation:self OperationStatus:status resultDataArray:resultDataArray andItsCount:countValue];
            break;
            
     case UPDATE:
            status= [[DataStore getSharedInstance] performDataUpdateOperationWithQuery:self.query andOperationString:@"Updation"];
            [self.delegate dataOperation:self OperationStatus:status resultDataArray:nil andItsCount:0];
            break;
            
    case DELETE:
            status= [[DataStore getSharedInstance] performDataUpdateOperationWithQuery:self.query andOperationString:@"Delete"];
            [self.delegate dataOperation:self OperationStatus:status resultDataArray:nil andItsCount:0];
            break;
      
    case COUNT:
            resultDataArray = [[DataStore getSharedInstance] performDataSelectionWithQuery:self.query andOperationString:@"Count"];
            int count = 0;
            if (resultDataArray) {
                count = (int)resultDataArray.count;
                status = YES;
            }
            [self.delegate dataOperation:self OperationStatus:status resultDataArray:resultDataArray andItsCount:count];
            break;
        default:
            break;
    }
}

@end
