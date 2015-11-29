#中国省市地区选择工具

把```AreaChooseTool``` 文件夹拖到工程即可使用。

地区数据依赖于region.db数据库文件，需使用FMDB框架。  
目前兼容到3级以内的地区选择。
目录下有分3层工具架构供选择:
  
- UWDBManager提供一个基于FMDB的数据库处理操作，方便使用操作数据库的方法  
- UWAreaTool提供一个地区的数据的数据读取工具  
- UWChooseAreaViewController提供一个可视化的地区选择的控制器  

    ```//  创建城市选择控制器
    UWChooseAreaViewController *chooseVC = [[UWChooseAreaViewController alloc] init];
    //  修改标题
    chooseVC.titleString = @"城市选择";
    //  最大选择级别
    chooseVC.maxRegionLevel = 3;
    //  完成回调：获取城市ID数组
    chooseVC.completionBlockWithCityIdArray = ^(NSArray *areaModelArray) {
        NSLog(@"%@", areaModelArray);
    };
    //  完成回调：获取城市名数组
    chooseVC.completionBlockWithCityNameArray = ^(NSArray *areaModelArray) {
        NSLog(@"%@", areaModelArray);
    };
    //  弹出控制器
    [self.navigationController pushViewController:chooseVC animated:YES];
```