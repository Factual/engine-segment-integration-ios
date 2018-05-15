# Description

This repository contains the code for an integration between Segment Analytics [Track API](https://segment.com/docs/sources/mobile/ios/#track)
and Factual [Engine iOS SDK](http://developer.factual.com/engine/ios).

While this is not a Segment [packaged integration](https://segment.com/docs/guides/partners/packaged-integration.md), it's just as simple to use
and it follows Segment's guidelines for tracking location events.

# Requirements

* an Engine API key
  * please log in to Factual.com or contact Factual for your key
* an implementation of a `FactualDelegate`
  * see our [example](http://developer.factual.com/engine/ios/#implementation) for reference
* an implementation of `UserJourneyDelegate`
  * optional per the Engine interface, but required if you wish to use this library to track the entire user journey
  * see our [example](http://developer.factual.com/engine/ios/#implementation) for reference
* a Segment write key
  * see [here](https://segment.com/docs/guides/setup/how-do-i-find-my-write-key/)
* a configured `SEGAnalytics` instance
  * as described [here](https://segment.com/docs/sources/mobile/ios/#install-the-sdk)

# Installation

## Cocoapods

```
source 'https://github.com/Factual/cocoapods.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.3'

target 'YourApp' do
  pod 'Analytics', '~> 3.6.0'
  pod 'FactualEngineSDK", '7.0.0'
  pod 'SegmentAnalyticsFactualEngine', '3.0.0'
end
```

## Manual installation

Download the library from [Bintray](https://factual.bintray.com/files) and add it to your Xcode project.

**Note**: You must have Engine SDK already added to your Xcode project in order to use the library.

# Quickstart

Include the header file `AnalyticsEngine.h` to your instance of `UserJourneyDelegate` and inside of the `userJourneyEventDidOccur` method, add the following line of code:

```
[AnalyticsEngineUtil trackUserJourneyEvent:userJourneyEvent forAnalytics:[SEGAnalytics sharedAnalytics]];
```

**That's it!**

Engine will invoke Segment's Track API for every "Place Entered". You can verify that the app is calling the Track API by using the Segment source debugger.

# How to use

We bundle classes that make it easy to call the Track API through user journey events and/or upon Circumstance detection.

Include the following header file to use them:

```
#import "AnalyticsEngine.h"
```

## Full user journey tracking

If you have an implemenation of `UserJourneyDelegate` (see [Requirements](#requirements)), simply add the following line of code to the `userJourneyEventDidOccur` method.

```
[AnalyticsEngineUtil trackUserJourneyEvent:userJourneyEvent forAnalytics:[SEGAnalytics sharedAnalytics]];
```

This function will call Segment's Track API whenever you are **at** any one of the 100+ millon places in Factual's [Global Places](http://www.factual.com/products/global) dataset, at any time.

## Selective user journey tracking via Circumstance

In your implementation of `FactualEngineDelegate` (see [Requirements](#requirements)), simply add a few lines of code to the `engineDidStartWithInstance` method.

First register the track action handler with Engine:

```
[AnalyticsEngineUtil addTrackActionTo:engine forAnalytics:[SEGAnalytics sharedAnalytics]];
```

* when creating programmatic Circumstances
  * use `[AnalyticsEngineTrackAction actionId]` as the action id to map your Circumstance to
* when creating Circumstances in the [Engine Garage](https://engine.factual.com/garage)
  * map them to [this](blob/master/library/SegmentAnalyticsFactualEngine/AnalyticsEngineTrackAction.m#L17) action

### Caveats

* If you implement both full and selective user journey tracking, there is potential to track the same place visit twice
* Place visits recorded by selective tracking include the Circumstance id and name, and the rest of the information is the same
* Unless you okay with duplicate place visits, we recommend using the library to track either full or selective user journey but not both

## Roll your own location tracking strategy

The bundled utility class [AnalyticsEngineUtil](blob/master/library/SegmentAnalyticsFactualEngine/AnalyticsEngine.h)
provides other methods you can invoke from your own delegates and action handler(s) to fine tune which location events you wish to track and when.

## Reference implementations of delegates

Easily test this library by starting Engine with the bundled [AnalyticsEngineUserJourneyDelegate](blob/master/library/SegmentAnalyticsFactualEngine/AnalyticsEngineUserJourneyDelegate.m),
which is a reference implemenation of `UserJourneyDelegate`, and the bundled [AnalyticsEngineDelegate](blob/master/library/SegmentAnalyticsFactualEngine/AnalyticsEngineDelegate.m) which is a reference implementation of `FactualEngineDelegate`.

**Note**: We strongly encourage you to use your own implementations of `UserJourneyDelegate` and `FactualEngineDelegate` in Production to have full control over Engine behavior in addition to invoking Segment's Track API.

Example:
```
// registers a tracking action with Engine (for use with Circumstances)
// the tracking action invokes the Segment Track API for any mapped Circumstances
AnalyticsEngineDelegate *engineDelegate =
  [[AnalyticsEngineDelegate alloc] initForAnalytics:[SEGAnalytics sharedAnalytics]];

// invokes the Segment Track API for every place visit
AnalyticsEngineUserJourneyDelegate *userJourneyDelegate =
  [[AnalyticsEngineUserJourneyDelegate alloc] initForAnalytics:[SEGAnalytics sharedAnalytics]];

[FactualEngine startWithApiKey:@"YOUR ENGINE API KEY"
                      delegate:engineDelegate
           userJourneyDelegate:userJourneyDelegate];
```

# License

```
WWWWWW||WWWWWW
 W W W||W W W
      ||
    ( OO )__________
     /  |           \
    /o o|    MIT     \
    \___/||_||__||_|| *
         || ||  || ||
        _||_|| _||_||
       (__|__|(__|__|

The MIT License (MIT)

Copyright (c) 2018 Factual, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
