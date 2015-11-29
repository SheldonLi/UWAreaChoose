//
//  UWAreaModel.h
//  uworks-library
//
//  Created by SheldonLee on 15/10/10.
//  Copyright © 2015年 U-Works. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UWAreaModel : NSObject

/**
 *  城市名
 */
@property (nonatomic, copy) NSString *regionName;

/**
 *  城市等级（1，2，3，4）
 */
@property (nonatomic, assign) NSUInteger regionType;

/**
 *  城市编号
 */
@property (nonatomic, assign) NSUInteger regionId;

/**
 *  上级城市编号
 */
@property (nonatomic, assign) NSUInteger parentId;


@end
