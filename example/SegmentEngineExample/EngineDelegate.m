/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#import "EngineDelegate.h"
#import "SegmentEngine.h"

@implementation EngineDelegate

FactualEngine *_engine = nil;

+ (FactualEngine *)engine {
  return _engine;
}

- (void)engineDidStartWithInstance:(FactualEngine *)engine {
  NSLog(@"Engine started.");
  [engine syncWithGarage];
  _engine = engine;
}

- (void)engineDidStop{
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

- (void)engineDidLoadConfig:(FactualConfigMetadata *)data {
  NSLog(@"Engine config loaded: %@", [data version]);
}

- (void)engineDidReportDiagnosticMessage:(NSString *)diagnosticMessage {
  NSLog(@"Engine diagnostic message: %@", diagnosticMessage);
}

- (void)circumstancesMet:(nonnull NSArray<CircumstanceResponse *> *)circumstances {
  for (CircumstanceResponse *response in circumstances) {
    NSLog(@"Engine circumstance triggered action: %@", [[response circumstance] actionId]);
    if ([[[response circumstance] actionId] isEqualToString:@"push-to-segment"]) {
      [SegmentEngine pushToSegment:response];
    }
  }
}

@end
