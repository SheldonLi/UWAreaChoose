//
//  UWAreaPickerView.m
//  uworks-library
//
//  Created by SheldonLee on 15/10/19.
//  Copyright © 2015年 U-Works. All rights reserved.
//

#import "UWAreaPickerView.h"
#import "UWAreaModel.h"
#import "UWAreaTool.h"

#define PROVINCE_COMPONENT 0
#define CITY_COMPONENT 1
#define AREA_COMPONENT 2

@interface UWAreaPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate> {
    int _provinceIndex;
    int _cityIndex;
}

@property(nonatomic, strong) NSMutableArray *provinceArray;

@property(nonatomic, strong) NSMutableArray *cityArray;

@property(nonatomic, strong) NSMutableArray *districtArray;

/** 最大地区等级 */
@property(nonatomic, assign) NSUInteger maxRegionType;

//  3个地区选择存储
@property(nonatomic, strong) UWAreaModel *currentProvinceModel;
@property(nonatomic, strong) UWAreaModel *currentCityModel;
@property(nonatomic, strong) UWAreaModel *currentDistrictModel;

@end

@implementation UWAreaPickerView

+ (instancetype)areaPickerView {
    UWAreaPickerView *pickerView =
        [[UWAreaPickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 216)];
    
    
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:pickerView.bounds];
    picker.delegate = pickerView;
    [pickerView addSubview:picker];

    [pickerView initData];

    return pickerView;
}

- (void)initData {
    self.provinceArray =
        [NSMutableArray arrayWithArray:[[UWAreaTool shareAreaTool] areaModelListByParentId:0]];
}

#pragma mark - Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [[UWAreaTool shareAreaTool] maxRegionTypeWithRegionId:0];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case PROVINCE_COMPONENT: {
            return [self.provinceArray count];
        } break;
        case CITY_COMPONENT: {
            return [self.cityArray count];
        } break;
        case AREA_COMPONENT: {
            return [self.districtArray count];
        } break;
        default:
            return 0;
            break;
    }
}

#pragma mark - Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    switch (component) {
        case PROVINCE_COMPONENT: {
            UWAreaModel *model = [self.provinceArray objectAtIndex:row];
            return model.regionName;
        } break;
        case CITY_COMPONENT: {
            UWAreaModel *model = [self.cityArray objectAtIndex:row];
            return model.regionName;
        } break;
        case AREA_COMPONENT: {
            UWAreaModel *model = [self.districtArray objectAtIndex:row];
            return model.regionName;
        } break;
        default:
            return @"";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    switch (component) {
        case PROVINCE_COMPONENT: {
            _provinceIndex = (int)row;
            self.currentProvinceModel = self.provinceArray[_provinceIndex];
            [self.cityArray removeAllObjects];
            [self.districtArray removeAllObjects];
            self.cityArray = [NSMutableArray
                arrayWithArray:[[UWAreaTool shareAreaTool]
                                   areaModelListByParentId:self.currentProvinceModel.regionId]];

            [pickerView selectRow:0 inComponent:CITY_COMPONENT animated:YES];
            [pickerView selectRow:0 inComponent:AREA_COMPONENT animated:YES];
            [pickerView reloadComponent:CITY_COMPONENT];
            [pickerView reloadComponent:AREA_COMPONENT];

        } break;
        case CITY_COMPONENT: {
            _cityIndex = (int)row;
            self.currentCityModel = self.cityArray[_cityIndex];

            [self.districtArray removeAllObjects];
            self.districtArray = [NSMutableArray
                arrayWithArray:[[UWAreaTool shareAreaTool]
                                   areaModelListByParentId:self.currentCityModel.regionId]];

            [pickerView selectRow:0 inComponent:AREA_COMPONENT animated:YES];
            [pickerView reloadComponent:AREA_COMPONENT];

            if ([_delegate respondsToSelector:@selector(AreaPickerView:didSelectAreaArray:)]) {
                [_delegate AreaPickerView:self
                       didSelectAreaArray:@[
                           self.currentProvinceModel,
                           self.currentCityModel,
                           self.currentDistrictModel
                       ]];
            }
        } break;
        case AREA_COMPONENT: {
            self.currentDistrictModel = [self.districtArray objectAtIndex:row];

            if ([_delegate respondsToSelector:@selector(AreaPickerView:didSelectAreaArray:)]) {
                [_delegate AreaPickerView:self
                       didSelectAreaArray:@[
                           self.currentProvinceModel,
                           self.currentCityModel,
                           self.currentDistrictModel
                       ]];
            }
        } break;
        default:
            break;
    }
}

- (NSMutableArray *)provinceArray {
    if (!_provinceArray) {
        _provinceArray = [NSMutableArray array];
    }
    return _provinceArray;
}

- (NSMutableArray *)cityArray {
    if (!_cityArray) {
        _cityArray = [NSMutableArray array];
    }
    return _cityArray;
}

- (NSMutableArray *)districtArray {
    if (!_districtArray) {
        _districtArray = [NSMutableArray array];
    }
    return _districtArray;
}

- (UWAreaModel *)currentProvinceModel {
    if (!_currentProvinceModel) {
        _currentProvinceModel = [[UWAreaModel alloc] init];
    }
    return _currentProvinceModel;
}

- (UWAreaModel *)currentCityModel {
    if (!_currentCityModel) {
        _currentCityModel = [[UWAreaModel alloc] init];
    }
    return _currentCityModel;
}

- (UWAreaModel *)currentDistrictModel {
    if (!_currentDistrictModel) {
        _currentDistrictModel = [[UWAreaModel alloc] init];
    }
    return _currentDistrictModel;
}

@end
