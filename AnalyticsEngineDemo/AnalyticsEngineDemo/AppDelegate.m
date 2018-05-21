/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2017-2018 Factual Inc. All rights reserved.
 */

#import <AdSupport/ASIdentifierManager.h>
#import <Analytics/SEGAnalytics.h>
#import "AppDelegate.h"
#import "AnalyticsEngine.h"

@implementation AppDelegate
{
    NSString *SEGMENT_WRITE_KEY;
    NSString *FACTUAL_ENGINE_API_KEY;
}

-(id)init {
    self = [super init];
    if(self) {
        NSDictionary *creds = [self getCredentials];
        SEGMENT_WRITE_KEY = [creds valueForKey:@"segment_write_key"];
        FACTUAL_ENGINE_API_KEY = [creds valueForKey:@"engine_api_key"];
    }
    return self;
}

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
    AnalyticsEngineDelegate *engineDelegate =
        [[AnalyticsEngineDelegate alloc] initForAnalytics:[SEGAnalytics sharedAnalytics]];
    
    AnalyticsEngineUserJourneyDelegate *userJourneyDelegate =
        [[AnalyticsEngineUserJourneyDelegate alloc] initForAnalytics:[SEGAnalytics sharedAnalytics]];
    
    [FactualEngine startWithApiKey:FACTUAL_ENGINE_API_KEY
                          delegate:engineDelegate
               userJourneyDelegate:userJourneyDelegate];
}

- (NSDictionary *) getCredentials {
    NSDictionary *creds = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"creds" ofType:@"plist"]];
    return creds;
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
