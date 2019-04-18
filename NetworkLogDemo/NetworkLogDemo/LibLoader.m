//
//  LibLoader.m
//  NetworkLogger
//
//  Created by Sunil Sharma on 16/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkLogDemo-Swift.h"

@interface CodeInjection: NSObject
@end

@implementation CodeInjection

static void __attribute__((constructor)) initialize(void){
    NSLog(@"Started loading...");
//    [[NetworkLogManager shared] logNetworkRequests];
}

@end
