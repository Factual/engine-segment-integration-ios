/*
 * Use of this software is subject to the terms and
 * conditions of the license agreement between you
 * and Factual Inc
 *
 * Copyright © 2019 Factual Inc. All rights reserved.
 */

#import "FactualEngine.h"

#ifndef PlaceCategoryMap_h
#define PlaceCategoryMap_h
@interface PlaceCategoryMap : NSObject
+ (NSArray<NSString*>*)getCategoriesFromPlace:(FactualPlace*)place;
@end
#endif /* PlaceCategoryMap_h */
