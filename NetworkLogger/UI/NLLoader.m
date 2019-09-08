//
//  NLLoader.m
//  NetworkLogger
//
//  Created by Sunil Sharma on 22/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

#import "NetworkLogger/NetworkLogger-Swift.h"

@interface NLLoader : NSObject

@end

@implementation NLLoader

+ (void)load {
    [[NetworkLogger shared] startLogging];
    (void)[NLUIManager shared];
}


@end
