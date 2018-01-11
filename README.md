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
  pod 'FactualEngineSDK", '5.3.0'
  pod 'SegmentAnalyticsFactualEngine', '1.0.0'
end
```

## Manual installation

Download the library from [Bintray](https://factual.bintray.com/files) and add it to your Xcode project.

**Note**: You must have Engine SDK already added to your Xcode project in order to use the library.

# Quickstart

Include the header file `AnalyticsEngine.h` to your instance of `FactualEngineDelegate` and inside of the `engineDidStartWithInstance` method, add the following line of code:

```
[AnalyticsEngineUtil trackAllPlaceVisitsWithEngine:engine forAnalytics:[SEGAnalytics sharedAnalytics]];
```

**That's it!**

Engine will invoke Segment's Track API for every "Place Entered". You can verify that the app is calling the Track API by using the Segment source debugger.

# How to use

We bundle classes that make it easy to call the Track API upon Circumstance detection.

Include the following header file to use them:

```
#import "AnalyticsEngine.h"
```

## Use within your own custom Engine delegate

In your implementation of `FactualEngineDelegate` (see [Requirements](#requirements)), simply add a few lines of code to the `engineDidStartWithInstance` method.

### To track the entire user journey

```
[AnalyticsEngineUtil trackAllPlaceVisitsWithEngine:engine forAnalytics:[SEGAnalytics sharedAnalytics]];
```

This function configures Engine in two ways:

* it registers an action with Engine that calls Segment's Track API
* it registers a Circumstance mapped to this action that detects whenever you are **at** any one
  of the 100+ millon places in Factual's [Global Places](http://www.factual.com/products/global) dataset, at any time


### To track user defined Circumstances only

First register the bundled tracking action handler with Engine:

```
[AnalyticsEngineUtil addDefaultActionHandlerTo:engine forAnalytics:[SEGAnalytics sharedAnalytics]];
```

Then for programmatically created Circumstances, use `[AnalyticsEngineDefaultActionHandler actionId]` as the action id to map your Circumstance to. For
user defined Circumstances created in the Engine Garage, map them to a new action id called `factual-segment-default-action-id`.

## Roll your own location tracking strategy

The bundled utility class [AnalyticsEngineUtil](https://github.com/Factual/segment-analytics-factual-engine-ios/blob/master/library/SegmentAnalyticsFactualEngine/AnalyticsEngine.h)
provides other methods  you can invoke from your own custom action handler(s) to fine tune which location events you wish to track.

## Reference implementation of FactualEngineDelegate

Easily test this library by starting Engine with the bundled [AnalyticsEngineDelegate](https://github.com/Factual/segment-analytics-factual-engine-ios/blob/master/library/SegmentAnalyticsFactualEngine/AnalyticsEngineDelegate.m),
which is a reference implemenation of `FactualEngineDelegate`.

**Note**: We strongly encourage you to use your own implementation of `FactualEngineDelegate` in Production to have full control over Engine behavior in addition to invoking Segment's Track API.

## Basic tracking

```
[FactualEngine startWithApiKey:@"YOUR ENGINE API KEY"
                      delegate:[[AnalyticsEngineDelegate alloc] initForAnalytics:[SEGAnalytics sharedAnalytics]
                                                                   withAutoTrack:true]];
```

By setting `withAutoTrack` to `true`, Engine is configured as described [here](#to-track-the-entire-user-journey).

## Basic tracking, but only user defined Circumstances

```
[FactualEngine startWithApiKey:@"YOUR ENGINE API KEY"
                      delegate:[[AnalyticsEngineDelegate alloc] initForAnalytics:[SEGAnalytics sharedAnalytics]
                                                                   withAutoTrack:false]];
```

By setting `withAutoTrack` to `false`, Engine is configured as described [here](#to-track-user-defined-circumstances-only).
