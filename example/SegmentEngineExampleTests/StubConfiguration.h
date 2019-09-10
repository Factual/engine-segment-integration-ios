/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#ifndef StubConfiguration_h
#define StubConfiguration_h

#import <Foundation/Foundation.h>

@interface StubConfiguration : NSObject
+ (NSString *)engineApiKey;
+ (NSString *)segmentWriteKey;
+ (NSString *)brazeEndpoint;
+ (NSString *)brazeRestApiKey;
+ (NSString *)brazeRestEndpoint;

+ (NSString *)testUserId;
+ (NSString *)testEmail;
+ (NSString *)circumstanceName;
+ (double)testLatitude;
+ (double)testLongitude;
@end


#endif /* StubConfiguration_h */
