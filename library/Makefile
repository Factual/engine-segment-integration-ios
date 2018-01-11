MKDIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

LIB_ROOT = $(MKDIR)/lib
LIB_VERSION = $(shell cat VERSION)
LIB_NAME = segment-analytics-factual-engine-ios-$(LIB_VERSION)
LIB_OUTPUT = $(LIB_ROOT)/$(LIB_NAME)

tarball: analytics-engine
	tar czf $(LIB_NAME).tar.gz -C $(LIB_OUTPUT) $(shell ls $(LIB_OUTPUT))

BUILD_ROOT = $(MKDIR)/build
BUILD_OUTPUT = $(BUILD_ROOT)/Build/Products
BUILD_CONFIGURATION := Release

ARM_DIR = $(BUILD_OUTPUT)/$(BUILD_CONFIGURATION)-iphoneos
X86_DIR = $(BUILD_OUTPUT)/$(BUILD_CONFIGURATION)-iphonesimulator
ANALYTICS_ENGINE_LIB = libAnalyticsEngineIntegration.a
ANALYTICS_ENGINE_HEADERS = *.h

analytics-engine: analytics-engine-x86 analytics-engine-arm
	mkdir -p $(LIB_OUTPUT)
	lipo $(ARM_DIR)/lib*.a $(X86_DIR)/lib*.a -output $(LIB_OUTPUT)/$(ANALYTICS_ENGINE_LIB) -create
	cp $(ARM_DIR)/$(ANALYTICS_ENGINE_HEADERS) $(LIB_OUTPUT)

PROJECT_NAME=SegmentAnalyticsFactualEngine
BASE_ARGS = -workspace $(PROJECT_NAME).xcworkspace -derivedDataPath $(BUILD_ROOT)
SIMULATOR_VERSION = $(shell xcodebuild -showsdks | grep -i "simulator - ios" | sed -E 's/.*-sdk (.*)/\1/')
X86_ARGS = -sdk $(SIMULATOR_VERSION)
SFE_ARGS = -configuration $(BUILD_CONFIGURATION) -scheme $(PROJECT_NAME)

analytics-engine-x86: install-pods
	xcodebuild $(BASE_ARGS) $(SFE_ARGS) $(X86_ARGS)| xcpretty

analytics-engine-arm: install-pods
	xcodebuild $(BASE_ARGS) $(SFE_ARGS) | xcpretty

podspec:
	erb $(PROJECT_NAME).podspec.erb > $(PROJECT_NAME).podspec

install-deps:
	gem install xcpretty
	brew install cocoapods

install-pods:
	pod repo update
	erb Podfile.erb > Podfile
	pod install

clean:
	rm -rf $(BUILD_ROOT) $(LIB_ROOT) *.tar.gz *~ *.xcworkspace *.lock Podfile Pods $(PROJECT_NAME).xcodeproj/xcuserdata/
