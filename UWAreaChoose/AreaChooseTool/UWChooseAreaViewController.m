//
//  UWChooseAreaViewController.m
//  uworks-library
//
//  Created by SheldonLee on 15/10/10.
//  Copyright © 2015年 U-Works. All rights reserved.
//

//  checkList:
//  1.数据库文件与UWAreaModel属性命名一致
//  2.暂时兼容3级选择
//  3.依赖UWCityTool进行城市查询，UWDBManager进行数据库的管理
//  TODO:currentBottomLineView没有自动布局，横竖屏切换有问题

#import "UWChooseAreaViewController.h"
#import <FMDB.h>
#import "UWAreaModel.h"
#import "UWDBManager.h"
#import "UWAreaTool.h"

//地区行的高度（省、市、区/县）
static const CGFloat kTitleHeight = 36.f;
// 默认颜色
#define defaultIndicatorLineColor ([UIColor redColor])

#define kViewWidth (self.view.bounds.size.width)
#define kViewHeight (self.view.bounds.size.height)

//指示条动画时间
static const CGFloat kAnimationTime = 0.25f;

static const NSUInteger kButtonBaseTag = 1000;

@interface UWChooseAreaViewController ()<UITableViewDelegate, UITableViewDataSource> {
    FMDatabase *_dataBase;
    NSArray *_regionArray;
}

/** 选择列表 */
@property(nonatomic, strong) UITableView *areaTableView;
/** 地区级别选择按钮栏 */
@property(nonatomic, strong) UIView *titleView;
/** 当前指示条 */
@property(nonatomic, strong) UIView *currentBottomLineView;

/** 当前数据源 */
@property(nonatomic, strong) NSArray *currentArray;

/** 最大地区等级 */
@property(nonatomic, assign) NSUInteger maxRegionType;

//  3个地区级别的按钮数组
@property(nonatomic, strong) NSMutableArray *areaButtons;

//  3个地区选择存储
@property(nonatomic, strong) UWAreaModel *currentProvinceModel;
@property(nonatomic, strong) UWAreaModel *currentCityModel;
@property(nonatomic, strong) UWAreaModel *currentDistrictModel;

@end

@implementation UWChooseAreaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.titleString) {
        self.navigationItem.title = self.titleString;
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"地区选择"];
    }
    if (self.backgroundColor) {
        self.view.backgroundColor = self.backgroundColor;
    } else {
        self.view.backgroundColor = COLOR_BASE_GRAY;
    }

    //  初始化名字
    _regionArray = @[ @"省", @"市", @"区/县" ];
    //获取地区最大等级数
    NSUInteger maxRegionFromDB = [[UWAreaTool shareAreaTool] maxRegionTypeWithRegionId:0];
    if (self.maxRegionLevel) {
        self.maxRegionType = MIN(self.maxRegionLevel, maxRegionFromDB);
    }

    [self setupView];
    // 获取第一级的数据
    [self seletedWithParentId:0];
}

- (void)setupView {
    _titleView = [[UIView alloc] init];
    [self.view addSubview:_titleView];
    _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    id topGuide = self.topLayoutGuide;
    NSArray *constsH =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_titleView]-margin-|"
                                                options:0
                                                metrics:@{
                                                    @"margin" : @0
                                                } views:@{
                                                    @"_titleView" : _titleView
                                                }];
    [self.view addConstraints:constsH];

    NSUInteger buttonCount = MIN(_regionArray.count, _maxRegionType);
    for (int i = 0; i < buttonCount; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        btn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        if (self.indicatorViewColor) {
            [btn setTitleColor:self.indicatorViewColor forState:UIControlStateSelected];
        } else {
            [btn setTitleColor:defaultIndicatorLineColor forState:UIControlStateSelected];
        }

        [btn setTitle:[_regionArray objectAtIndex:i] forState:UIControlStateNormal];

        [btn addTarget:self
                      action:@selector(areaButtonClick:)
            forControlEvents:UIControlEventTouchUpInside];
        btn.tag = kButtonBaseTag + i;

        btn.selected = (i == 0 ? YES : NO);
        btn.enabled = (i == 0 ? YES : NO);
        [self.areaButtons addObject:btn];

        // 默认选中第一个
        [_titleView addSubview:btn];
        if (i == 0) {
            _currentBottomLineView = [[UIView alloc]
                initWithFrame:CGRectMake(0, kTitleHeight - 1, ScreenWidth / buttonCount, 1)];
            // 如果自定义主色，使用自定义，否则用红色
            if (self.indicatorViewColor) {
                _currentBottomLineView.backgroundColor = self.indicatorViewColor;
            } else {
                _currentBottomLineView.backgroundColor = defaultIndicatorLineColor;
            }

            [_titleView addSubview:_currentBottomLineView];
        }
    }

    NSMutableString *buttonConstsHString = [NSMutableString stringWithFormat:@"H:|-margin-"];
    NSMutableDictionary *buttonConstsHViewsDict =
        [NSMutableDictionary dictionaryWithCapacity:buttonCount];
    NSDictionary *buttonConstsHMetricsDict = @{ @"margin" : @0 };
    for (UIButton *btn in self.areaButtons) {
        //  水平约束
        if (btn.tag == kButtonBaseTag) {
            [buttonConstsHString
                appendString:[NSString stringWithFormat:@"[button_%ld(<=1000)]-margin-", btn.tag]];
        } else {
            [buttonConstsHString
                appendString:[NSString stringWithFormat:@"[button_%ld(==button_%ld)]-margin-",
                                                        btn.tag, btn.tag - 1]];
        }

        [buttonConstsHViewsDict setObject:btn
                                   forKey:[NSString stringWithFormat:@"button_%ld", btn.tag]];

        NSArray *buttonConstsV =
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[button(kTitleHeight)]-0-|"
                                                    options:0
                                                    metrics:@{
                                                        @"kTitleHeight" : @(kTitleHeight)
                                                    } views:@{
                                                        @"button" : btn
                                                    }];
        [self.titleView addConstraints:buttonConstsV];
    }
    [buttonConstsHString appendString:@"|"];

    NSArray *titleConstsH = [NSLayoutConstraint constraintsWithVisualFormat:buttonConstsHString
                                                                    options:0
                                                                    metrics:buttonConstsHMetricsDict
                                                                      views:buttonConstsHViewsDict];

    // 添加约束
    [self.titleView addConstraints:titleConstsH];

    _areaTableView = [[UITableView alloc] init];
    [self.view addSubview:_areaTableView];
    _areaTableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *tableConstsH =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_areaTableView]-margin-|"
                                                options:0
                                                metrics:@{
                                                    @"margin" : @0
                                                } views:@{
                                                    @"_areaTableView" : _areaTableView
                                                }];
    NSArray *tableConstsV = [NSLayoutConstraint
        constraintsWithVisualFormat:
            @"V:|-0-[topGuide]-0-[_titleView(kTitleHeight)]-0-[_areaTableView]-0-|"
                            options:0
                            metrics:@{
                                @"kTitleHeight" : @(kTitleHeight)
                            } views:@{
                                @"_areaTableView" : _areaTableView,
                                @"_titleView" : _titleView,
                                @"topGuide" : topGuide
                            }];
    // 添加约束
    [self.view addConstraints:tableConstsH];
    [self.view addConstraints:tableConstsV];

    _areaTableView.delegate = self;
    _areaTableView.dataSource = self;
    // 隐藏多余线条
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_areaTableView setTableFooterView:view];
}

#pragma mark - talbleView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }

    UWAreaModel *area = self.currentArray[indexPath.row];
    cell.textLabel.text = area.regionName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UWAreaModel *area = self.currentArray[indexPath.row];
    [self seletedWithParentId:area.regionId];
    NSUInteger maxRegion =
        MIN(_maxRegionType, [[UWAreaTool shareAreaTool] maxRegionTypeWithRegionId:area.regionId]);

    if (!(self.areaButtons && self.areaButtons.count > 0)) {
        return;
    }
    UIButton *provinceButton =
        self.areaButtons.count > 0 ? [self.areaButtons objectAtIndex:0] : nil;
    UIButton *cityButton = self.areaButtons.count > 1 ? [self.areaButtons objectAtIndex:1] : nil;
    UIButton *districtButton =
        self.areaButtons.count > 2 ? [self.areaButtons objectAtIndex:2] : nil;

    if (area.regionType == 1) {
        [provinceButton setTitle:area.regionName forState:UIControlStateNormal];
        [cityButton setTitle:[_regionArray objectAtIndex:1] forState:UIControlStateNormal];
        [districtButton setTitle:[_regionArray objectAtIndex:2] forState:UIControlStateNormal];

        provinceButton.selected = NO;
        cityButton.selected = YES;
        cityButton.enabled = YES;
        districtButton.enabled = NO;

        self.currentProvinceModel = area;

        [UIView animateWithDuration:kAnimationTime
                         animations:^{
                             self.currentBottomLineView.frame =
                                 CGRectMake(kViewWidth / _maxRegionType, kTitleHeight - 1,
                                            kViewWidth / _maxRegionType, 1);
                         }];

    } else if (area.regionType == 2) {
        [cityButton setTitle:area.regionName forState:UIControlStateNormal];
        [districtButton setTitle:[_regionArray objectAtIndex:2] forState:UIControlStateNormal];

        cityButton.selected = NO;
        districtButton.selected = YES;
        districtButton.enabled = YES;

        self.currentCityModel = area;

        [UIView animateWithDuration:kAnimationTime
                         animations:^{
                             self.currentBottomLineView.frame =
                                 CGRectMake(kViewWidth / _maxRegionType * 2, kTitleHeight - 1,
                                            kViewWidth / _maxRegionType, 1);
                         }];

    } else if (area.regionType == 3) {
        [districtButton setTitle:area.regionName forState:UIControlStateNormal];
        self.currentDistrictModel = area;
    }

    // 自动弹出处理
    if (area.regionType == maxRegion) {
        NSMutableArray *areaModelArray = [NSMutableArray arrayWithCapacity:maxRegion];

        if (self.currentProvinceModel.regionId) {
            [areaModelArray addObject:self.currentProvinceModel];
        }
        if (self.currentCityModel.regionId) {
            [areaModelArray addObject:self.currentCityModel];
        }
        if (self.currentDistrictModel.regionId) {
            [areaModelArray addObject:self.currentDistrictModel];
        }

        NSMutableArray *cityIdArray = [NSMutableArray arrayWithCapacity:maxRegion];
        NSMutableArray *cityNameArray = [NSMutableArray arrayWithCapacity:maxRegion];
        for (UWAreaModel *model in areaModelArray) {
            [cityNameArray addObject:model.regionName];
            [cityIdArray addObject:@(model.regionId)];
        }

        if (self.completionBlockWithModelArray) {
            self.completionBlockWithModelArray([NSArray arrayWithArray:areaModelArray]);
        }
        if (self.completionBlockWithCityIdArray) {
            self.completionBlockWithCityIdArray([NSArray arrayWithArray:cityIdArray]);
        }
        if (self.completionBlockWithCityNameArray) {
            self.completionBlockWithCityNameArray([NSArray arrayWithArray:cityNameArray]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark titleButtonClick
- (void)areaButtonClick:(UIButton *)btn {
    [UIView animateWithDuration:kAnimationTime
                     animations:^{
                         self.currentBottomLineView.frame =
                             CGRectMake(kViewWidth / _maxRegionType * (btn.tag - kButtonBaseTag),
                                        kTitleHeight - 1, kViewWidth / _maxRegionType, 1);
                     }];

    UIButton *provinceButton =
        self.areaButtons.count > 0 ? [self.areaButtons objectAtIndex:0] : nil;
    UIButton *cityButton = self.areaButtons.count > 1 ? [self.areaButtons objectAtIndex:1] : nil;
    UIButton *districtButton =
        self.areaButtons.count > 2 ? [self.areaButtons objectAtIndex:2] : nil;

    if (btn.tag == provinceButton.tag) {
        provinceButton.selected = YES;
        cityButton.selected = NO;
        districtButton.selected = NO;
        [self seletedWithParentId:0];

    } else if (btn.tag == cityButton.tag) {
        provinceButton.selected = NO;
        cityButton.selected = YES;
        districtButton.selected = NO;
        [self seletedWithParentId:self.currentProvinceModel.regionId];

    } else if (btn.tag == districtButton.tag) {
        provinceButton.selected = NO;
        cityButton.selected = NO;
        districtButton.selected = YES;
        [self seletedWithParentId:self.currentCityModel.regionId];
    }
}

- (void)seletedWithParentId:(NSUInteger)parentId {
    self.currentArray = [[UWAreaTool shareAreaTool] areaModelListByParentId:parentId];
    [self.areaTableView reloadData];
}

#pragma mark - lazy load
- (NSArray *)currentArray {
    if (!_currentArray) {
        _currentArray = [[NSArray alloc] init];
    }
    return _currentArray;
}

- (NSMutableArray *)areaButtons {
    if (!_areaButtons) {
        _areaButtons = [NSMutableArray arrayWithCapacity:_maxRegionType];
    }
    return _areaButtons;
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
