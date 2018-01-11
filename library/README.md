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

TBD
