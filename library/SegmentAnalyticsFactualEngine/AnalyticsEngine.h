/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2017 Factual Inc. All rights reserved.
 */

#import <Analytics/SEGAnalytics.h>
#import "FactualEngine.h"

@interface AnalyticsEngineUtil: NSObject
+ (void) trackAllPlaceVisitsWithEngine:(FactualEngine *)engine forAnalytics:(SEGAnalytics *)analytics;
+ (void) addDefaultActionHandlerTo:(FactualEngine *)engine forAnalytics:(SEGAnalytics *)analytics;
+ (void) logPlaceEntered:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics;
+ (void) logPlaceNear:(FactualPlace *)factualPlace incidentId:(NSString *)incidentId forAnalytics:(SEGAnalytics *)analytics;
@end

@interface AnalyticsEngineDefaultActionHandler: NSObject<FactualActionDelegate>
+ (NSString *) actionId;
- (id) initForAnalytics:(SEGAnalytics *)analytics;
@end

@interface AnalyticsEngineDelegate: NSObject<FactualEngineDelegate>
@property FactualEngine *engine;
+ (instancetype) sharedInstance;
- (id) initForAnalytics:(SEGAnalytics *)analytics withAutoTrack:(BOOL)autoTrack;
@end
