//
//  ViewController.m
//  UWAreaChoose
//
//  Created by SheldonLee on 15/11/26.
//  Copyright © 2015年 Sheldon. All rights reserved.
//

#import "ViewController.h"
#import "UWChooseAreaViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *areaNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *areaIdLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)areaChooseClick:(id)sender {
    
    //  创建城市选择控制器
    UWChooseAreaViewController *chooseVC = [[UWChooseAreaViewController alloc] init];
    //  修改标题
    chooseVC.titleString = @"城市选择";
    //  最大选择级别
    chooseVC.maxRegionLevel = 3;
    //  完成回调：获取城市ID数组
    chooseVC.completionBlockWithCityIdArray = ^(NSArray *areaModelArray) {
        NSLog(@"%@", areaModelArray);
        NSMutableString *mStr = [NSMutableString string];
        for (NSNumber *num in areaModelArray) {
            [mStr appendString:num.description];
            [mStr appendString:@","];
        }
        self.areaIdLabel.text = [mStr substringToIndex:mStr.length-1];
    };
    //  完成回调：获取城市名数组
    chooseVC.completionBlockWithCityNameArray = ^(NSArray *areaModelArray) {
        NSLog(@"%@", areaModelArray);
        NSMutableString *mStr = [NSMutableString string];
        for (NSString *str in areaModelArray) {
            [mStr appendString:str];
            [mStr appendString:@","];
        }
        self.areaNameLabel.text = [mStr substringToIndex:mStr.length-1];
    };
    //  弹出控制器
    [self.navigationController pushViewController:chooseVC animated:YES];
    
}

@end
