//
//  UWDBManager.m
//  uworks-library
//
//  Created by SheldonLee on 15/10/10.
//  Copyright © 2015年 U-Works. All rights reserved.
//

#import "UWDBManager.h"

@implementation UWDBManager

+ (instancetype)sharedDBManager {
    static UWDBManager *_sharedDBmanager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDBmanager = [[UWDBManager alloc] init];
    });
    
    return _sharedDBmanager;
}


- (FMDatabase *)creatDatabaseWithPath:(NSString *)path {

    _dataBase = [FMDatabase databaseWithPath:path];
    [_dataBase setShouldCacheStatements:YES];
    if (![_dataBase open]) {
        NSLog(@"Could not open db.");
        return nil;
    }
    return _dataBase;
}

#pragma mark - Query
- (NSArray *)resultArrayForDataBase:(FMDatabase *)dataBase executeQuery:(NSString *)query {
    NSMutableArray *resultArray = [NSMutableArray array];
    FMResultSet *resultSet;
    if ([dataBase open]) {
        resultSet = [dataBase executeQuery:query];
        // column包括主键
        int columnNum = resultSet.columnCount;
        while (resultSet.next) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:columnNum];
            for (int i = 0; i < columnNum; i++) {
                //null 会设置为<null>
//                if (![resultSet columnIndexIsNull:i]) {}
                NSString *columnName = [resultSet columnNameForIndex:i];
                id columnValue = [resultSet objectForColumnIndex:i];
                [dict setObject:columnValue forKey:columnName];
                
            }
            if (dict) {
                [resultArray addObject:dict];
            }
        }
    }
    [dataBase close];
    return (NSArray *)resultArray;
}


@end
