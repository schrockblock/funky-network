# FunkyNetwork

[![CI Status](http://img.shields.io/travis/schrockblock/funky-etwork.svg?style=flat)](https://travis-ci.org/schrockblock/funky-network)
[![Version](https://img.shields.io/cocoapods/v/FunkyNetwork.svg?style=flat)](http://cocoapods.org/pods/FunkyNetwork)
[![License](https://img.shields.io/cocoapods/l/FunkyNetwork.svg?style=flat)](http://cocoapods.org/pods/FunkyNetwork)
[![Platform](https://img.shields.io/cocoapods/p/FunkyNetwork.svg?style=flat)](http://cocoapods.org/pods/FunkyNetwork)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

Checkout the tests to get started! 

The example project also has some good stuff. `LoginNetworkCall` shows how you can send, receive, and parse json with this library and Eson (a different pod I wrote). `AuthenticatedNetworkCall` shows how you can alter the headers and most other things in this pod.

## Advantages

1. Functional code!
2. Modular! Using subclassing and having one call per class makes it really easy to take calls with you between controllers, view models, or even projects.
3. Lightweight! Only a few classes here, and none terribly long or involved.
4. Convenient! Smart defaults make things easy to work with out of the box.
5. Flexible! Since everything is broken up into tiny pieces, it's easy to swap things out, or mix and match.

## Installation

FunkyNetwork is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FunkyNetwork', git: 'https://github.com/schrockblock/funky-network.git'
```

## Author

Elliot Schrock

## License

FunkyNetwork is available under the MIT license. See the LICENSE file for more info.
