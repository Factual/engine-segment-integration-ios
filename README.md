# Factual / Segment SDK for iOS ![Build Status](https://app.bitrise.io/app/f286946ae820c35a/status.svg?token=thRmP11tvTwxO1xG1NKL6g)

This repository contains the code for an integration between [Factual's Engine SDK](https://www.factual.com/products/engine/) and [Segments's Track API](https://segment.com/docs/sources/mobile/ios/#track). Using this library you can configure Factual's Location Engine SDK to send custom events to Segment to better understand users in the physical world and build personalized experiences to drive user engagement and revenue.

### Integration with Segment UI

see: [engine-segment-integration](https://github.com/Factual/engine-segment-integration)

# Installation

### Cocoapods

```ruby
source 'https://github.com/Factual/cocoapods.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

target 'YourApp' do
  pod 'SegmentEngine'
end
```

### Manual installation
Download the library from [Bintray](https://factual.bintray.com/files/) and add it to your Xcode project. Note that the Engine SDK and Segment SDK must be added to your Xcode project in order to use the library. Please refer to the [Factual Developer Docs](http://developer.factual.com)

# Usage

### Requirements

* Configured and started `Engine` client. [see here](http://developer.factual.com/engine/ios/)
* Configured `Segment` client. [see here](https://segment.com/docs/sources/mobile/ios/quickstart/)

### Tracking Factual Engine Circumstances

Call the SegmentEngine method for sending a circumstance response to Segment in the `circumstancesMet:` callback in `FactualEngineDelegate`.

```objective-c
- (void)circumstancesMet:(nonnull NSArray<CircumstanceResponse *> *)circumstances {
  // Max number of "engine_at_" + CIRCUMSTANCE_NAME events that should
  // be sent per "engine_" + CIRCUMSTANCE_NAME event. Default is set to 10.
  int maxAtPlaceEvents = 3;

  // Max number of "engine_near_" + CIRCUMSTANCE_NAME events that should
  // be sent per "engine_" + CIRCUMSTANCE_NAME event. Default is set to 20.
  int maxNearPlaceEvents = 5;

  for (CircumstanceResponse *response in circumstances) {
    [SegmentEngine pushToSegment:response
        withMaxAtPlaceEvents:maxAtPlaceEvents
      withMaxNearPlaceEvents:maxNearPlaceEvents];
  }
}
```

### Tracking Factual Engine User Journey Spans

Start tracking User Journey Spans by first adding the `SegmentEngineUserJourneyHandler` delegate on
`[FactualEngine startWithApiKey:delegate:userJourneyDelegate:]`

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  ...

  // Max number of "engine_span_attached_place" events that should be sent per "engine_span_occurred"
  // default is 20.
  int maxAttachedPlaceEvents = 10;
  [FactualEngine startWithApiKey:[Configuration engineApiKey]
                        delegate:[self engineDelegate]
             userJourneyDelegate:[[SegmentEngineUserJourneyHandler alloc]
                                   initWithMaxAttachedPlaceEventsPerEvent:maxAttachedPlaceEvents]];

  return YES;
}
```

Then in the Engine started callback within the FactualEngineDelegate add the line `[SegmentEngine trackUserJourneySpans];`

```objective-c
- (void)engineDidStartWithInstance:(FactualEngine *)engine {
  NSLog(@"Engine started.");
  [SegmentEngine trackUserJourneySpans];
}
```

Please refer to the [Factual Developer Docs](http://developer.factual.com) for more information about Engine.

# Example App

An example app is included in this repository to demonstrate the usage of this library, see [./example](./example) for documentation and usage instructions.
