/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#import "StubConfiguration.h"

@implementation StubConfiguration

+ (NSString *)engineApiKey {
  return @"Your Engine API Key here";
}

+ (NSString *)segmentWriteKey {
  return @"Your Segment Write Key here";
}

+ (NSString *)brazeEndpoint {
  return @"Your Braze Endpoint here";
}

+ (NSString *)brazeRestApiKey {
  return @"Your Braze Rest API Key here";
}

+ (NSString *)brazeRestEndpoint {
  return @"Your Braze Rest Endpoint here";
}

+ (NSString *)testUserId {
  return @"Your Test User Id here";
}

+ (NSString *)testEmail {
  return @"Your Test Email here";
}

+ (NSString *)circumstanceName {
  return @"Your Circumstance Name here";
}

// Change testLatitude and testLongitude to a location that will trigger your circumstance
+ (double)testLatitude {
  return 34.0141;
}

+ (double)testLongitude {
  return -118.2879;
}

@end
