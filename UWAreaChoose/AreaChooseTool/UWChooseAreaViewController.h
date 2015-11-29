//
//  UWChooseAreaViewController.h
//  uworks-library
//
//  Created by SheldonLee on 15/10/10.
//  Copyright © 2015年 U-Works. All rights reserved.
//
//  地区选择器：从region.db读取，依赖FMDB框架





#import <UIKit/UIKit.h>

@class UWAreaModel;

typedef void(^completionBlockWithModelArray)(NSArray *areaModelArray);
typedef void(^completionBlockWithCityNameArray)(NSArray *CityNameArray);
typedef void(^completionBlockWithCityIdArray)(NSArray *CityIdArray);

@interface UWChooseAreaViewController : UIViewController

/** 完成回调 */
@property (nonatomic, copy) completionBlockWithModelArray completionBlockWithModelArray;
@property (nonatomic, copy) completionBlockWithCityNameArray completionBlockWithCityNameArray;
@property (nonatomic, copy) completionBlockWithCityIdArray completionBlockWithCityIdArray;

/**
 *  指示器颜色
 */
@property (nonatomic, strong) UIColor *indicatorViewColor;
/**
 *  背景颜色
 */
@property (nonatomic, strong) UIColor *backgroundColor;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *titleString;

/**
 *  最大选择级别
 */
@property (nonatomic, assign) NSUInteger maxRegionLevel;



@end
