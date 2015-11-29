//
//  UWDBManager.h
//  uworks-library
//
//  Created by SheldonLee on 15/10/10.
//  Copyright © 2015年 U-Works. All rights reserved.
//
//  封装FMDB工具类


#import <Foundation/Foundation.h>
#import <FMDB.h>

@class FMDatabase;


@interface UWDBManager : NSObject

/// 数据库操作对象
@property (nonatomic, readonly) FMDatabase *dataBase;

/**
 *  数据库管理者单例
 */
+ (instancetype)sharedDBManager;

/**
 *  创建数据库对象
 *
 *  @param path 数据库文件路径
 *
 *  @return 数据库对象
 */
- (FMDatabase *)creatDatabaseWithPath:(NSString *)path;

/**
 *  返回数据库查询结果
 *
 *  @param dataBase 数据库对象
 *  @param query    查询语句
 *
 *  @return 返回字典数组
 */
- (NSArray *)resultArrayForDataBase:(FMDatabase *)dataBase executeQuery:(NSString *)query;

@end
