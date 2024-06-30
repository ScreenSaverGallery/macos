//
//  SSGViewPrivate.m
//  ScreenSaverGallery
//
//  Created by tomasjavurek on 28.05.2024.
//  Copyright © 2024 metazoa.org. All rights reserved.
//  Derived from the project WebViewScreenSaver by Alexandru Gologan (see: https://github.com/liquidx/webviewscreensaver)



#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WKWebView (Compat)

- (void)hack_disableWindowOcclusionDetection;
- (void)_setWindowOcclusionDetectionEnabled:(BOOL)enabled;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation WKWebView (Compat)

- (void)hack_disableWindowOcclusionDetection {
  if ([self respondsToSelector:@selector(_setWindowOcclusionDetectionEnabled:)]) {
    [self _setWindowOcclusionDetectionEnabled:NO];
  }
}
#pragma clang diagnostic pop

@end
