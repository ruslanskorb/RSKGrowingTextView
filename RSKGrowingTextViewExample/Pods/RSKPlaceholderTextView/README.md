## RSKPlaceholderTextView [![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg?style=flat)](https://developer.apple.com/swift/) [![Swift Package Manager Compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange.svg?style=flat")](https://swift.org/package-manager/) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RSKPlaceholderTextView.svg)](https://cocoapods.org) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<p align="center">
  <img src="RSKPlaceholderTextViewExample/RSKPlaceholderTextViewExample.gif" alt="Sample">
</p>

A light-weight UITextView subclass that adds support for placeholder.

## Installation

### Using [Swift Package Manager](https://swift.org/package-manager/)

1. To add the `RSKPlaceholderTextView` package to your Xcode project, select File > Swift Packages > Add Package Dependency and enter the repository URL. 
    
        https://github.com/ruslanskorb/RSKPlaceholderTextView.git

### Using [CocoaPods](http://cocoapods.org)

1.  Add the pod `RSKPlaceholderTextView` to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html).

        pod 'RSKPlaceholderTextView'

2.  Run `pod install` from Terminal, then open your app's `.xcworkspace` file to launch Xcode.

### Using [Carthage](https://github.com/Carthage/Carthage)

1.  Add the `ruslanskorb/RSKPlaceholderTextView` project to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

        github "ruslanskorb/RSKPlaceholderTextView"

2.  Run `carthage update`, then follow the [additional steps required](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the iOS and/or Mac frameworks into your project.

## Basic Usage

Import the module.

```swift
import RSKPlaceholderTextView
```

Just create a text view and set the placeholder.

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    self.textView = RSKPlaceholderTextView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 100))
    self.textView.placeholder = "What do you want to say about this event?"

    self.view.addSubview(self.textView)
}
```

## Demo

Build and run the `RSKPlaceholderTextViewExample` project in Xcode to see `RSKPlaceholderTextView` in action.
Have fun. Figure out hooks for customization.

## Contact

Ruslan Skorb

- http://github.com/ruslanskorb
- http://twitter.com/ruslanskorb
- ruslan.skorb@gmail.com

## License

This project is available under the Apache License, version 2.0. See the LICENSE file for more info.
