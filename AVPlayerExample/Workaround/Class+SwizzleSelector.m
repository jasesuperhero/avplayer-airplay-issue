//
//  SCFoundation
//
//  Created by Daniel Kalintsev on 29.11.23.
//

#import "Class+SwizzleSelector.h"

#import <objc/runtime.h>
#import <objc/message.h>

// We reimplemented classic way of swizzling due to safety issues.
// You can find details in this great artcile:
// https://defagos.github.io/yet_another_article_about_method_swizzling
IMP sc_class_swizzleSelector(Class clazz, SEL selector, IMP newImplementation)
{
    // If the method does not exist for this class, do nothing
    Method method = class_getInstanceMethod(clazz, selector);
    if (! method) {
        // Cannot swizzle methods which are not implemented
        // by the class or one of its parents
        return NULL;
    }

    // Make sure the class implements the method.
    // If this is not the case, inject an implementation, only calling 'super'
    const char *types = method_getTypeEncoding(method);

    id (^swizzled_impl)(__unsafe_unretained id self, va_list argp) = ^id(__unsafe_unretained id self, va_list argp) {
        struct objc_super super = {
            .receiver = self,
            .super_class = class_getSuperclass(clazz)
        };

        // Cast the call to objc_msgSendSuper appropriately
        id (*objc_msgSendSuper_typed)(struct objc_super *, SEL, va_list) = (void *)&objc_msgSendSuper;
        return objc_msgSendSuper_typed(&super, selector, argp);
    };

    class_addMethod(clazz,
                    selector,
                    imp_implementationWithBlock(swizzled_impl),
                    types);

    // Swizzling
    return class_replaceMethod(clazz,
                               selector,
                               newImplementation,
                               types
                               );
}
