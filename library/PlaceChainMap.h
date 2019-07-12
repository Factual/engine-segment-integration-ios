/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#import "FactualEngine.h"

#ifndef PlaceChainMap_h
#define PlaceChainMap_h
@interface PlaceChainMap : NSObject
+ (NSString*)getChainFromPlace:(FactualPlace*)place;
@end
#endif /* PlaceChainMap_h */
