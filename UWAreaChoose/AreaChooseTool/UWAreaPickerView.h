//
//  UWAreaPickerView.h
//  uworks-library
//
//  Created by SheldonLee on 15/10/19.
//  Copyright © 2015年 U-Works. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UWAreaPickerView,UWAreaModel;

@protocol UWAreaPickerViewDelegate <NSObject>

@optional
- (void)AreaPickerView:(UWAreaPickerView *)areaPickerView didSelectAreaArray:(NSArray *)areaModelArray;

@end

@interface UWAreaPickerView : UIView

@property (nonatomic, weak) id<UWAreaPickerViewDelegate> delegate;

+ (instancetype)areaPickerView;

@end
