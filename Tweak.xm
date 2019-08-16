//
//  Tweak.m
//  FLEXing
//
//  Created by Tanner Bennett on 2016-07-11
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//


#import "Interfaces.h"

static id manager = nil;
static SEL show = nil;

%ctor {
    NSString *standardPath = @"/Library/MobileSubstrate/DynamicLibraries/libFLEX.dylib";
    NSFileManager *disk = NSFileManager.defaultManager;
    if ([disk fileExistsAtPath:standardPath]) {
        dlopen(standardPath.UTF8String, RTLD_LAZY);
    } else {
        // Load tweak from "alternate" location
        // ...
    }

    manager = FLXGetManager()
    show = FLXRevealSEL();
}

%hook UIWindow
- (BOOL)_shouldCreateContextAsSecure {
    return [self isKindOfClass:FLXWindowClass()] ? YES : %orig;
}

- (id)initWithFrame:(CGRect)frame {
    self = %orig(frame);
    
    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:manager action:show];
    tap.minimumPressDuration = .5;
    tap.numberOfTouchesRequired = 3;
    
    [self addGestureRecognizer:tap];
    
    return self;
}

%end

%hook UIStatusBarWindow
- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:manager action:show]];
    
    return self;
}
%end

%hook NSObject
%new
+ (NSBundle *)__bundle__ {
    return [NSBundle bundleForClass:self];
}
%end
