/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2017-2018 Factual Inc. All rights reserved.
 */

#import <AdSupport/ASIdentifierManager.h>
#include "AnalyticsEngine.h"

@implementation AnalyticsEngineDelegate
{
    SEGAnalytics *_analytics;
}

static AnalyticsEngineDelegate *sharedInstance;

+ (id) sharedInstance {
    return sharedInstance;
}

- (id) initForAnalytics:(SEGAnalytics *)analytics {
    if (self = [super init]) {
        _analytics = analytics;
        sharedInstance = self;
    }
    return self;
}

- (void)engineDidLoadConfig:(FactualConfigMetadata *)data {
    NSLog(@"Engine config loaded: %@", [data version]);
}

- (void)engineDidStartWithInstance:(FactualEngine *)engine {
    NSLog(@"Engine started.");
    [AnalyticsEngineUtil addTrackActionTo:engine forAnalytics:_analytics];
    _engine = engine;
}

- (void)engineDidStop {
    NSLog(@"Engine stopped.");
}

- (void)engineDidFailWithError:(FactualError *)error {
    NSLog(@"Engine error: %@", [error message]);
}

- (void)engineDidReportInfo:(NSString *)infoMessage {
    NSLog(@"Engine debug info: %@", infoMessage);
}

- (void)engineDidSyncWithGarage {
    NSLog(@"Engine updated configuration.");
}

- (void)engineDidReportDiagnosticMessage:(nonnull NSString *)diagnosticMessage {
    NSLog(@"Engine diagnostic message: %@", diagnosticMessage);
}

@end
