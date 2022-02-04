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
    <a href="https://travis-ci.org/mobilejazz/harmony-ios"><img alt="CI Status" src="http://img.shields.io/travis/mobilejazz/harmony-ios.svg?style=flat)"></a>
    <a href="http://cocoapods.org/pods/Harmony"><img alt="Version" src="https://img.shields.io/cocoapods/v/Harmony.svg?style=flat"></a>
    <a href="http://cocoapods.org/pods/Harmony"><img alt="License" src="https://img.shields.io/cocoapods/l/Harmony.svg?style=flat"></a>
    <a href="http://cocoapods.org/pods/Harmony"><img alt="Platform" src="https://img.shields.io/cocoapods/p/Harmony.svg?style=flat"></a>
  </p>
</p>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods

Harmony is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Harmony', '~> 2.0.0'
```
For unit test, you can use the following pod:
```ruby
pod 'HarmonyTesting', '~> 2.0.0'
```

### Carthage

```ruby
github "mobilejazz/harmony-swift" "2.0.0"
```

Resolve dependencies `carthage update --use-xcframeworks --platform iOS` and add `Harmony.xcframework` to your project. For unit test, add `HarmonyTesting.xcframework` in your build phase of your testing target.

### Swift Package Manager

```ruby
dependencies: [
    .package(url: "https://github.com/mobilejazz/harmony-swift", .upToNextMajor(from: "2.0.0"))
]
```
This package includes two libraries: `Harmony` and `HarmonyTesting`.

## Author

Mobile Jazz, info@mobilejazz.com

## API Reference 

[https://harmony.mobilejazz.com/docs/introduction](https://harmony.mobilejazz.com/docs/introduction)

## License

Harmony is available under the Apache 2.0 license. See the LICENSE file for more info.
