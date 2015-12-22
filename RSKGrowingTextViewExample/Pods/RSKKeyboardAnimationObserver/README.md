## RSKKeyboardAnimationObserver ![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/ruslanskorb/RSKKeyboardAnimationObserver)

Easy way to handle iOS keyboard showing/dismissing. 

## Introduction
Working with iOS keyboard demands a lot of duplicated code. This category allows you to declare your animations with smooth keyboard animation timing while writing very little code.

## Demo
![KeyboardAnimationDemo1](https://raw.githubusercontent.com/Just-/demo/master/an_kb_animation_demo.gif)
![KeyboardAnimationDemo2](https://raw.githubusercontent.com/Just-/demo/master/kb_anim_demo.gif)

## Installation
*RSKKeyboardAnimationObserver requires iOS 6.0 or later.*

### Using [CocoaPods](http://cocoapods.org)

1.  Add the pod `RSKKeyboardAnimationObserver` to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html).

        pod 'RSKKeyboardAnimationObserver'

2.  Run `pod install` from Terminal, then open your app's `.xcworkspace` file to launch Xcode.
3.  Import the `RSKKeyboardAnimationObserver.h` header. Typically, this should be written as `#import <RSKKeyboardAnimationObserver/RSKKeyboardAnimationObserver.h>`

### Using [Carthage](https://github.com/Carthage/Carthage)

1.  Add the `ruslanskorb/RSKKeyboardAnimationObserver` project to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

        github "ruslanskorb/RSKKeyboardAnimationObserver"

2.  Run `carthage update`, then follow the [additional steps required](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the iOS and/or Mac frameworks into your project.
3.  Import the RSKKeyboardAnimationObserver framework/module.
    *  Using Modules: `@import RSKKeyboardAnimationObserver`
    *  Without Modules: `#import <RSKKeyboardAnimationObserver/RSKKeyboardAnimationObserver.h>`

## Example
Imagine that you need to implement chat-like input over keyboard. OK, import this category.

``` objective-c
#import <RSKKeyboardAnimationObserver/RSKKeyboardAnimationObserver.h>
```

Then make autolayout constraint between your input bottom and superview botton in *Interface Builder*, connect it with your view controller implementation through *IBOutlet*.

``` objective-c
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatInputBottomSpace;
```

Then subscribe to keyboard in the place you like (**viewDidAppear** is the best place really).

``` objective-c
__weak typeof(self) weakSelf = self;
[self rsk_subscribeKeyboardWithWillShowOrHideAnimation:^(CGRect keyboardRectEnd, NSTimeInterval duration, BOOL isShowing) {
    __strong typeof(self) strongSelf = weakSelf;
    if (strongSelf) {
        strongSelf.chatInputBottomSpace.constant = isShowing ?  CGRectGetHeight(keyboardRectEnd) : 0;
        [strongSelf.view layoutIfNeeded];
    }
} onComplete:nil];
```

That’s all! 

**Don’t forget** to unsubscribe from keyboard events (**viewDidDisappear** is my recommendation). Calling this category method will do all the “dirty” work for you.

    [self rsk_unsubscribeKeyboard];

For more complex behaviour (like in demo section) you can use extended API call with **before animation** section.

``` objective-c
__weak typeof(self) weakSelf = self;
[self rsk_subscribeKeyboardWithBeforeWillShowOrHideAnimation:^(CGRect keyboardRectEnd, NSTimeInterval duration, BOOL isShowing) {
    __strong typeof(self) strongSelf = weakSelf;
    if (strongSelf) {
        strongSelf.isKeaboardAnimation = YES;
        
        [UIView transitionWithView:strongSelf.imageView duration:duration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (isShowing) {
                strongSelf.imageView.image = [strongSelf.imageView.image applyLightEffect];
            } else {
                [strongSelf.imageView hnk_setImageFromURL:strongSelf.model.cardImageUrl];
            }
        } completion:nil];
    }
 } willShowOrHideAnimation:^(CGRect keyboardRectEnd, NSTimeInterval duration, BOOL isShowing) {
    __strong typeof(self) strongSelf = weakSelf;
    if (strongSelf) {
        strongSelf.headerHeight.constant = isShowing ? kHeaderMinHeight : kHeaderMaxHeight;
        strongSelf.panelSpace.constant = isShowing ?  CGRectGetHeight(keyboardRectEnd) : 0;
        
        for (UIView *v in strongSelf.headerAlphaViews) {
            v.alpha = isShowing ? 0.0f : 1.0f;
        }

        [strongSelf.view layoutIfNeeded];
    }
} onComplete:^(BOOL finished, BOOL isShown) {
    __strong typeof(self) strongSelf = weakSelf;
    if (strongSelf) {
        strongSelf.isKeaboardAnimation = NO;
    }
}];
```

## Contact

Ruslan Skorb

- http://github.com/ruslanskorb
- http://twitter.com/ruslanskorb
- ruslan.skorb@gmail.com

## License

This project is is available under the MIT license. See the LICENSE file for more info. Attribution by linking to the [project page](https://github.com/ruslanskorb/RSKKeyboardAnimationObserver) is appreciated.
