/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#import "AppDelegate.h"
#import "Configuration.h"
#import "EngineDelegate.h"
#import <Analytics/SEGAnalytics.h>

@interface AppDelegate ()
@property CLLocationManager *manager; // Engine assumes you are managing location permissions
@property EngineDelegate *engineDelegate;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  // for demonstration, we're requesting location permissions here:
  if (_manager == nil) {
    _manager = [[CLLocationManager alloc] init];
  }
  [_manager requestAlwaysAuthorization];
  
  // start the SDK.
  // Note, you don't need to worry about whether or not the necessary
  // authorizations have returned from the user before calling start.
  // Engine will automatically detect for any changes to location
  // authorizations and behave accordingly.
  if (_engineDelegate == nil) {
    _engineDelegate = [[EngineDelegate alloc] init];
  }
  
  [FactualEngine startWithApiKey:[Configuration engineApiKey] delegate:_engineDelegate];
  
  SEGAnalyticsConfiguration *segmentConfig = [SEGAnalyticsConfiguration configurationWithWriteKey:[Configuration segmentWriteKey]];
  segmentConfig.flushAt = 1;
  [SEGAnalytics setupWithConfiguration:segmentConfig];
  
  return YES;
}


@end
