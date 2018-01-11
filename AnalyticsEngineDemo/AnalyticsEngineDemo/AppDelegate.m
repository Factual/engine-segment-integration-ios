/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2017 Factual Inc. All rights reserved.
 */

#import <AdSupport/ASIdentifierManager.h>
#import <Analytics/SEGAnalytics.h>
#import "AppDelegate.h"
#import "AnalyticsEngine.h"

NSString *const SEGMENT_WRITE_KEY = @"WRITE KEY GOES HERE";
NSString *const FACTUAL_ENGINE_API_KEY = @"ENGINE KEY GOES HERE";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self requestLocationPermissions];
    [self configureAnalytics];
    [self startEngine];

    [[SEGAnalytics sharedAnalytics] track:@"Analytics-Engine Demo App Launched"];
    [[SEGAnalytics sharedAnalytics] flush];
    
    return YES;
}

- (void)requestLocationPermissions {
    // for demonstration, we're requesting location permissions here:
    if (_manager == nil) {
        _manager = [[CLLocationManager alloc] init];
    }
    [_manager requestAlwaysAuthorization];
}

- (void) configureAnalytics {
    [SEGAnalytics debug:YES];
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:SEGMENT_WRITE_KEY];
    configuration.trackApplicationLifecycleEvents = YES;
    configuration.trackAttributionData = YES;
    configuration.flushAt = 1;
    [SEGAnalytics setupWithConfiguration:configuration];
}

- (void) startEngine {
    [FactualEngine startWithApiKey:FACTUAL_ENGINE_API_KEY
                          delegate:[[AnalyticsEngineDelegate alloc] initForAnalytics:[SEGAnalytics sharedAnalytics]
                                                                       withAutoTrack:true]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
