//
//  UWAreaTool.m
//  uworks-library
//
//  Created by SheldonLee on 15/10/15.
//  Copyright © 2015年 U-Works. All rights reserved.
//

#import "UWAreaTool.h"
#import "UWDBManager.h"
#import "UWAreaModel.h"

#define DBPATH_REGION [[NSBundle mainBundle] pathForResource:@"region" ofType:@"db"]

#define ARRAY_IS_EMPTY(array) ((!array ||[array count] == 0)? YES: NO)

@interface UWAreaTool ()

@property(nonatomic, strong) FMDatabase *dataBase;

@end

@implementation UWAreaTool

+ (instancetype)shareAreaTool {
    static UWAreaTool *_sharedAreaTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAreaTool = [[UWAreaTool alloc] init];
        _sharedAreaTool.dataBase =
            [[UWDBManager sharedDBManager] creatDatabaseWithPath:DBPATH_REGION];
    });
    return _sharedAreaTool;
}

#pragma mark - Extend Function
- (NSString *)cityNameByCityId:(NSUInteger)cityId {
    NSString *sqlString =
        [NSString stringWithFormat:@"SELECT regionName FROM t_region where regionId=%ld", cityId];
//FIXME: 查询的数据不具有唯一性
    return [[UWDBManager sharedDBManager] resultArrayForDataBase:self.dataBase
                                                    executeQuery:sqlString][0];
}

- (NSArray *)cityIdByCityName:(NSString *)cityName {
    NSString *sqlString = [NSString
        stringWithFormat:@"SELECT regionId FROM t_region where regionName='%@'", cityName];
    return
        [[UWDBManager sharedDBManager] resultArrayForDataBase:self.dataBase executeQuery:sqlString];
}

- (NSArray *)cityNameListByKeyword:(NSString *)keyword {
    NSString *sqlString = [NSString
        stringWithFormat:@"SELECT regionName FROM t_region where regionName like '%%%@%%'",
                         keyword];
    return
        [[UWDBManager sharedDBManager] resultArrayForDataBase:self.dataBase executeQuery:sqlString];
}

- (NSArray *)cityNameListFromParentId:(NSUInteger)parentId {
    NSString *sqlString = [NSString
        stringWithFormat:
            @"SELECT regionName FROM t_region where parentId=%ld ORDER BY regionId ASC", parentId];
    return
        [[UWDBManager sharedDBManager] resultArrayForDataBase:self.dataBase executeQuery:sqlString];
}

- (NSArray *)cityIdListFromParentId:(NSUInteger)parentId {
    NSString *sqlString = [NSString
        stringWithFormat:@"SELECT regionId FROM t_region where parentId=%ld ORDER BY regionId ASC",
                         parentId];
    return
        [[UWDBManager sharedDBManager] resultArrayForDataBase:self.dataBase executeQuery:sqlString];
}

- (NSArray *)allProvinceName {
    // 省份的parnerId = 0
    return [self cityNameListFromParentId:0];
}

#pragma mark - UWAreaModel
- (NSArray *)areaModelListByParentId:(NSUInteger)parentId {
    NSMutableArray *mArray = [NSMutableArray array];
    NSString *sqlString = [NSString
        stringWithFormat:@"SELECT * FROM t_region where parentId=%ld ORDER BY regionId ASC",
                         parentId];
    // 数组里存放的还是字典，需转成AreaModel
    NSArray *array =
        [[UWDBManager sharedDBManager] resultArrayForDataBase:self.dataBase executeQuery:sqlString];

    for (NSDictionary *dict in array) {
        UWAreaModel *model = [[UWAreaModel alloc] init];
        model.regionName = [dict objectForKey:@"regionName"];
        model.regionId = [[dict objectForKey:@"regionId"] integerValue];
        model.regionType = [[dict objectForKey:@"regionType"] integerValue];
        model.parentId = [[dict objectForKey:@"parentId"] integerValue];
        [mArray addObject:model];
    }
    return mArray;
}

- (NSUInteger)maxRegionTypeWithRegionId:(NSUInteger)regionId {
    NSUInteger maxRegionType = 0;

    //  通过regionId的前2位确定省
    NSString *dbString;
    if (regionId == 0) {
        dbString = [NSString stringWithFormat:@"SELECT max(regionType) FROM t_region"];
    } else {
        dbString = [NSString
            stringWithFormat:@"SELECT max(regionType) FROM t_region WHERE regionId LIKE '%ld%%'",
                             regionId / 10000];
    }
    //  通过省获取地区最大等级数
    NSArray *array =
        [[UWDBManager sharedDBManager] resultArrayForDataBase:self.dataBase executeQuery:dbString];
    if (!ARRAY_IS_EMPTY(array)) {
        maxRegionType = [[[array objectAtIndex:0] objectForKey:@"max(regionType)"] integerValue];
    }

    return maxRegionType;
}

@end
