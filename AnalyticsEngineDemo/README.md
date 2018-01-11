# Description

In this demo app, we use the Segment Analytics/Factual Engine library to send location data to Segment's Analytics Track API.

# Requirements

* CocoaPods
* an Engine API Key
* a Segment [write key](https://segment.com/docs/guides/setup/how-do-i-find-my-write-key)

# Setup

This app leverages [CocoaPods](https://cocoapods.org) to install both Analytics and Engine as dependencies.

## Install the pod dependencies

### For local development of the integration code

```
make clean install-dev
open AnalyticsEngineDemo.xcworkspace
```

You must add the source code from `../library/SegmentAnalyticsFactualEngine`
to the Xcode project under the group `FactualSegmentIntegrationDev`, as well as
	manually add the Engine binary and header to the group.

### To test the published integration pod

```
make clean install-test
open AnalyticsEngineDemo.xcworkspace
```

**Note**: If you had previously set the project up for development but then wish to test a published integration pod, you must first remove
the library source code as well as the manually added Engine SDK from your Xcode project.

## Set up your keys

Before starting the app, edit `AppDelegate.m` and add your Segment write key and Engine API key to the top:

```
NSString *const SEGMENT_WRITE_KEY = @"WRITE KEY GOES HERE";
NSString *const FACTUAL_ENGINE_API_KEY = @"ENGINE KEY GOES HERE";
```

## Sanity check

Double check that the [build settings](http://developer.factual.com/engine/ios/#disable-bitcode) are set up properly.

# Test

Run the app in a simulator or on a real device!

If you don't want to wait for Engine take action, you may press the button in the middle of the screen to force Engine to detect your location.

## Verify

You can verify that the app is calling the Track API by using the Segment source debugger.

