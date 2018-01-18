# Description

This library integrates Segment Analytics Track API with Factual Engine SDK.

# Build

```
make clean install-deps install-pods
make analytics-engine
```

# Package

Make sure the `VERSION` and `DEPS_VERSION.rb` files are up to date.

```
make tarball
```

# Create podspec file

```
make podspec
```

# Push podspec to engine-pods repo

```
pod cache clean --all
pod repo push factual SegmentAnalyticsFactualEngine.podspec  --allow-warnings --verbose
```

# Upload binary to Bintray

## Upload

e.g.

```
curl -s -v -T segment-analytics-factual-engine-ios-1.0.0.tar.gz -u <BINTRAY_API_USER>:<BINTRAY_API_KEY> https://api.bintray.com/content/factual/files/segment-analytics-factual-engine/1.0.0/segment-analytics-factual-engine-ios-1.0.0.tar.gz
```

## Publish

e.g.

```
curl -X POST -u <BINTRAY_API_USER>:<BINTRAY_API_KEY> https://api.bintray.com/content/factual/files/segment-analytics-factual-engine-ios/1.0.0/publish
```
