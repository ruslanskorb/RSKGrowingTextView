//
// UIViewController+RSKKeyboardAnimationObserver.h
//
// Copyright (c) 2015 Anton Gaenko
// Copyright (c) 2015-present Ruslan Skorb, http://ruslanskorb.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (RSKKeyboardAnimationObserver)

/**
 Block to handle a start point of animation, could be used for simultaneous animations OR for setting some flags for internal usage.
 
 @param keyboardRectEnd  The end frame of the keyboard.
 @param duration         Duration for keyboard change frame animation.
 */
typedef void(^RSKKeyboardBeforeWillChangeFrameAnimationBlock)(CGRect keyboardRectEnd, NSTimeInterval duration);

/**
 Block to handle a start point of animation, could be used for simultaneous animations OR for setting some flags for internal usage.
 
 @param keyboardRectEnd  The end frame of the keyboard.
 @param duration         Duration for keyboard showing animation.
 @param isShowing        If isShowing is YES we will handle keyboard showing, if NO we will process keyboard dismissing.
 */
typedef void(^RSKKeyboardBeforeWillShowOrHideAnimationBlock)(CGRect keyboardRectEnd, NSTimeInterval duration, BOOL isShowing);

/**
 Block which contains user defined animations.
 
 @param keyboardRectEnd  The end frame of the keyboard.
 @param duration         Duration for keyboard change frame animation.
 */
typedef void(^RSKKeyboardWillChangeFrameAnimationBlock)(CGRect keyboardRectEnd, NSTimeInterval duration);

/**
 Block to handle completion of keyboard animation.
 
 @param finished If NO animation was canceled during performing.
 */
typedef void(^RSKKeyboardWillChangeFrameAnimationCompletionBlock)(BOOL finished);

/**
 Block which contains user defined animations.
 
 @param keyboardRectEnd  The end frame of the keyboard.
 @param duration         Duration for keyboard showing animation.
 @param isShowing        If isShowing is YES we handle keyboard showing, if NO we process keyboard dismissing.
 */
typedef void(^RSKKeyboardWillShowOrHideAnimationBlock)(CGRect keyboardRectEnd, NSTimeInterval duration, BOOL isShowing);

/**
 Block to handle completion of keyboard animation.
 
 @param finished If NO animation was canceled during performing.
 @param isShown  If YES the keyboard was shown.
 */
typedef void(^RSKKeyboardWillShowOrHideAnimationCompletionBlock)(BOOL finished, BOOL isShown);

/**
 Animation block will be called inside [UIView animateWithDuration:::::].
 
 @tip viewDidAppear is the best place to subscribe to keyboard events.
 
 @param beforeWillChangeFrameAnimationBlock  Preanimation actions should be performed inside this block.
 @param willChangeFrameAnimationBlock        User defined animations. If using auto layout don't forget to call layoutIfNeeded.
 @param completionBlock                      User defined completion block, will be called when animation ends.
 
 @warning These blocks will be holding inside UIViewController which calls it, so as with any block-style API avoid a retain cycle.
 */
- (void)rsk_subscribeKeyboardWithBeforeWillChangeFrameAnimation:(nullable RSKKeyboardBeforeWillChangeFrameAnimationBlock)beforeWillChangeFrameAnimationBlock
                                       willChangeFrameAnimation:(nullable RSKKeyboardWillChangeFrameAnimationBlock)willChangeFrameAnimationBlock
                                                     onComplete:(nullable RSKKeyboardWillChangeFrameAnimationCompletionBlock)completionBlock;

/**
 Animation block will be called inside [UIView animateWithDuration:::::].
 
 @tip viewDidAppear is the best place to subscribe to keyboard events.
 
 @param beforeWillShowOrHideAnimationBlock   Preanimation actions should be performed inside this block.
 @param willShowOrHideAnimationBlock         User defined animations. If using auto layout don't forget to call layoutIfNeeded.
 @param completionBlock                      User defined completion block, will be called when animation ends.
 
 @warning These blocks will be holding inside UIViewController which calls it, so as with any block-style API avoid a retain cycle.
 */
- (void)rsk_subscribeKeyboardWithBeforeWillShowOrHideAnimation:(nullable RSKKeyboardBeforeWillShowOrHideAnimationBlock)beforeWillShowOrHideAnimationBlock
                                       willShowOrHideAnimation:(nullable RSKKeyboardWillShowOrHideAnimationBlock)willShowOrHideAnimationBlock
                                                    onComplete:(nullable RSKKeyboardWillShowOrHideAnimationCompletionBlock)completionBlock;

/**
 Animation block will be called inside [UIView animateWithDuration:::::].
 
 @tip viewDidAppear is the best place to subscribe to keyboard events.
 
 @param willChangeFrameAnimationBlock    User defined animations. If using auto layout don't forget to call layoutIfNeeded.
 @param completionBlock                  User defined completion block, will be called when animation ends.
 
 @warning These blocks will be holding inside UIViewController which calls it, so as with any block-style API avoid a retain cycle.
 */
- (void)rsk_subscribeKeyboardWithWillChangeFrameAnimation:(nullable RSKKeyboardWillChangeFrameAnimationBlock)willChangeFrameAnimationBlock
                                               onComplete:(nullable RSKKeyboardWillChangeFrameAnimationCompletionBlock)completionBlock;

/**
 Animation block will be called inside [UIView animateWithDuration:::::].
 
 @tip viewDidAppear is the best place to subscribe to keyboard events.
 
 @param willShowOrHideAnimationBlock User defined animations. If using auto layout don't forget to call layoutIfNeeded.
 @param completionBlock              User defined completion block, will be called when animation ends.
 
 @warning These blocks will be holding inside UIViewController which calls it, so as with any block-style API avoid a retain cycle.
 */
- (void)rsk_subscribeKeyboardWithWillShowOrHideAnimation:(nullable RSKKeyboardWillShowOrHideAnimationBlock)willShowOrHideAnimationBlock
                                              onComplete:(nullable RSKKeyboardWillShowOrHideAnimationCompletionBlock)completionBlock;

/**
 
 Call it to unsubscribe from keyboard events and clean all animations and completion blocks.
 
 @tip viewDidDisappear is the best place to call it.
 
 @warning If you will not call it when current view disappeared, subscribed view controller will handle keyboard events on other screens.
 */
- (void)rsk_unsubscribeKeyboard;

@end

NS_ASSUME_NONNULL_END
