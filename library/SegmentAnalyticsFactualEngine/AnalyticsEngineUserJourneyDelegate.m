/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2017-2018 Factual Inc. All rights reserved.
 */

#import <AdSupport/ASIdentifierManager.h>
#include "AnalyticsEngine.h"

@implementation AnalyticsEngineUserJourneyDelegate
{
    SEGAnalytics *_analytics;
}

- (id) initForAnalytics:(SEGAnalytics *)analytics {
    if (self = [super init]) {
        _analytics = analytics;
    }
    return self;
}

- (void)userJourneyEventDidOccur:(nonnull UserJourneyEvent *)userJourneyEvent {
    [AnalyticsEngineUtil trackUserJourneyEvent:userJourneyEvent forAnalytics:_analytics];
}

@end
