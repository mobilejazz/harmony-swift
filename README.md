<p align="center">
  <a href="https://harmony.mobilejazz.com">
    <img src="https://raw.githubusercontent.com/mobilejazz/metadata/master/images/icons/harmony.svg" alt="MJ Harmony logo" width="80" height="80">
  </a>

  <h3 align="center">Harmony Swift</h3>

  <p align="center">
    Harmony is a <em>framework</em> developed by <a href="https://mobilejazz.com">Mobile Jazz</a> that specifies best practices, software architectural patterns and other software development related guidelines.
    <br />
    <br />
    <a href="https://harmony.mobilejazz.com">Documentation</a>
    ·
    <a href="https://github.com/mobilejazz/harmony-kotlin">Kotlin</a>
    ·
    <a href="https://github.com/mobilejazz/harmony-typescript">TypeScript</a>
    ·
    <a href="https://github.com/mobilejazz/harmony-php">PHP</a>
  </p>
  
  <p align="center">
  [![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_Windows-Green?style=flat-square)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Harmony)](https://img.shields.io/cocoapods/v/Harmony)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![Twitter](https://img.shields.io/badge/twitter-@mobilejazzcom-blue.svg?style=flat-square)](https://twitter.com/mobilejazzcom)
    <a href="https://github.com/mobilejazz/harmony-swift/blob/master/LICENSE"><img alt="GitHub license" src="https://img.shields.io/github/license/mobilejazz/harmony-swift"></a>
  </p>
</p>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods

Harmony is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Harmony', '~> 2.0.2'
```
For unit test, you can use the following pod:
```ruby
pod 'HarmonyTesting', '~> 2.0.2'
```

### Carthage

```ruby
github "mobilejazz/harmony-swift" "2.0.2"
```

Resolve dependencies `carthage update --use-xcframeworks --platform iOS` and add `Harmony.xcframework` to your project. For unit test, add `HarmonyTesting.xcframework` in your build phase of your testing target.

### Swift Package Manager

```ruby
dependencies: [
    .package(url: "https://github.com/mobilejazz/harmony-swift", .upToNextMajor(from: "2.0.2"))
]
```
This package includes two libraries: `Harmony` and `HarmonyTesting`.

## Development

First of all, run to resolve the dependencies.

```ruby
carthage update --use-xcframeworks --platform [iOS|macOS] --no-use-binaries
```

The development of the library is done using Carthage. For this, we use the .xcodeproj. Including the unit tests.

If we want to use the Example for Harmony development, open Example/Harmony.xcworkspace. Example uses Cocoapods to resolve the dependency on Harmony. Any new dependencies must be added in the Harmony .podsec. This way it will be available for both development and distribution of the library. Later, we must add the dependencies in Carthage and SPM as well.
Any dependencies used for Example development, for example Kingfisher for downloading images, must be added in the Podfile and not in the .podspec.

####Important!
All the new dependencies must be added in all the package managers we support (Carthage, Cocoapods and SPM).

## Author

Mobile Jazz, info@mobilejazz.com

## API Reference 

[https://harmony.mobilejazz.com/docs/introduction](https://harmony.mobilejazz.com/docs/introduction)

## License

Harmony is available under the Apache 2.0 license. See the LICENSE file for more info.
