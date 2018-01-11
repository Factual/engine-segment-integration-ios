LIB_VERSION=$(shell cat ../library/VERSION)
LIB_TARBALL=segment-analytics-factual-engine-ios-$(LIB_VERSION).tar.gz

LIB_URL=https://factual.bintray.com/files/$(LIB_TARBALL)

LOCAL_POD_ROOT=./SegmentAnalyticsFactualEngineLocalPod

install-dev:
	cp Podfile.dev Podfile
	pod install

install-test:
	cp Podfile.test Podfile
	pod install

install-test-local: local-lib-pod
	wget $(LIB_URL) -O $(LOCAL_POD_ROOT)/$(LIB_TARBALL)
	tar Cxzf $(LOCAL_POD_ROOT) $(LOCAL_POD_ROOT)/$(LIB_TARBALL)
	cp Podfile.test-local Podfile
	pod install

local-lib-pod:
	mkdir -p $(LOCAL_POD_ROOT)
	cp ../library/VERSION $(LOCAL_POD_ROOT)
	cp ../library/SegmentAnalyticsFactualEngine.podspec $(LOCAL_POD_ROOT)

clean:
	rm -rf Podfile $(LOCAL_POD_ROOT) AnalyticsEngineDemo.xcworkspace/ Pods AnalyticsEngineDemo.xcodeproj/xcuserdata/ *.lock *~ AnalyticsEngineDemo.xcodeproj/project.xcworkspace/xcuserdata

clean-simulators:
	xcrun simctl erase all
