//
//  UWAreaTool.h
//  uworks-library
//
//  Created by SheldonLee on 15/10/15.
//  Copyright © 2015年 U-Works. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UWAreaTool : NSObject

+ (instancetype)shareAreaTool;

/**
 *  根据城市ID返回城市名
 *
 *  @param cityId 城市ID
 *
 *  @return 城市名
 */
- (NSString *)cityNameByCityId:(NSUInteger)cityId;


/**
 *  根据城市名字返回城市ID
 *
 *  @param cityName 城市名
 *
 *  @return 城市ID数组
 */
- (NSArray *)cityIdByCityName:(NSString *)cityName;

/**
 *  根据关键字查询城市名列表
 *
 *  @param keyword 关键字
 *
 *  @return 城市列表数组
 */
- (NSArray *)cityNameListByKeyword:(NSString *)keyword;


/**
 *  根据上一级城市ID返回下一级所有城市名
 *
 *  @param parentId 上一级城市ID
 *
 *  @return 下一级的城市数组
 */
- (NSArray *)cityNameListFromParentId:(NSUInteger)parentId;

/**
 *  根据上一级城市ID返回下一级所有城市ID
 *
 *  @param parentId 上一级城市ID
 *
 *  @return 下一级的城市数组
 */
- (NSArray *)cityIdListFromParentId:(NSUInteger)parentId;

/**
 *  返回所有省份的名称
 *
 *  @return 省份数组
 */
- (NSArray *)allProvinceName;

/**
 *  根据上一级返回城市模型数组
 *
 *  @param parentId 上一级的城市ID
 *
 *  @return 城市模型数组
 */
- (NSArray *)areaModelListByParentId:(NSUInteger)parentId;


/**
 *  根据上一级获取城市最大级数
 *
 *  @param regionId 城市ID
 *
 *  @return 城市级数
 */
- (NSUInteger)maxRegionTypeWithRegionId:(NSUInteger)regionId;

@end
