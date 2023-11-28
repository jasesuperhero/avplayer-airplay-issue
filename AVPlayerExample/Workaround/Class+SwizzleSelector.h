//
//  SCFoundation
//
//  Created by Daniel Kalintsev on 29.11.23.
//

#import "Foundation/Foundation.h"

#import <objc/runtime.h>
#import <objc/message.h>

IMP sc_class_swizzleSelector(Class clazz, SEL selector, IMP newImplementation);

NS_ASSUME_NONNULL_BEGIN
NS_ASSUME_NONNULL_END
