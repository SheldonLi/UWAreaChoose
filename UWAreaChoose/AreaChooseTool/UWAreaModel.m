//
//  UWAreaModel.m
//  uworks-library
//
//  Created by SheldonLee on 15/10/10.
//  Copyright © 2015年 U-Works. All rights reserved.
//

#import "UWAreaModel.h"

@implementation UWAreaModel

- (NSString *)description {
    return [NSString stringWithFormat:@"regionName:%@  regionType:%ld  parentId:%ld  regionId:%ld",
                                      _regionName, _regionType, _parentId, _regionId];
}


@end
