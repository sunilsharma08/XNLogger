//
//  XNLoader.m
//  XNLogger
//
//  Created by Sunil Sharma on 22/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

#import "XNLogger/XNLogger-Swift.h"

@interface XNLoader : NSObject

@end

@implementation XNLoader

+ (void)load {
    [[XNLogger shared] startLogging];
    (void)[XNUIManager shared];
}


@end
