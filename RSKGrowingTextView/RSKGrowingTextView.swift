//
// Copyright 2015-present Ruslan Skorb, http://ruslanskorb.com/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this work except in compliance with the License.
// You may obtain a copy of the License in the LICENSE file, or at:
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit

/// The type of the block which contains user defined actions that will run during the height change.
public typealias HeightChangeUserActionsBlockType = ((_ oldHeight: CGFloat, _ newHeight: CGFloat) -> Void)

/// The `RSKGrowingTextViewDelegate` protocol extends the `UITextViewDelegate` protocol by providing a set of optional methods you can use to receive messages related to the change of the height of `RSKGrowingTextView` objects.
@objc public protocol RSKGrowingTextViewDelegate: UITextViewDelegate {
    ///
    /// Tells the delegate that the growing text view did change height.
    ///
    /// - Parameters:
    ///     - textView: The growing text view object that has changed the height.
    ///     - growingTextViewHeightBegin: CGFloat that identifies the start height of the growing text view.
    ///     - growingTextViewHeightEnd: CGFloat that identifies the end height of the growing text view.
    ///
    @objc optional func growingTextView(_ textView: RSKGrowingTextView, didChangeHeightFrom growingTextViewHeightBegin: CGFloat, to growingTextViewHeightEnd: CGFloat)
    
    ///
    /// Tells the delegate that the growing text view will change height.
    ///
    /// - Parameters:
    ///     - textView: The growing text view object that will change the height.
    ///     - growingTextViewHeightBegin: CGFloat that identifies the start height of the growing text view.
    ///     - growingTextViewHeightEnd: CGFloat that identifies the end height of the growing text view.
    ///
    @objc optional func growingTextView(_ textView: RSKGrowingTextView, willChangeHeightFrom growingTextViewHeightBegin: CGFloat, to growingTextViewHeightEnd: CGFloat)
}

/// A light-weight UITextView subclass that automatically grows and shrinks based on the size of user input and can be constrained by maximum and minimum number of lines.
@IBDesignable open class RSKGrowingTextView: RSKPlaceholderTextView {
    
    // MARK: - Private Properties
    
    private var calculatedHeight: CGFloat {
        let calculationTextStorage = NSTextStorage(attributedString: attributedText)
        calculationTextStorage.addLayoutManager(calculationLayoutManager)
        
        calculationTextContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        calculationTextContainer.size = textContainer.size
        
        calculationLayoutManager.ensureLayout(for: calculationTextContainer)
        
        var height = calculationLayoutManager.usedRect(for: calculationTextContainer).height + contentInset.top + contentInset.bottom + textContainerInset.top + textContainerInset.bottom
        if height < minHeight {
            height = minHeight
        } else if height > maxHeight {
            height = maxHeight
        }
        
        return height
    }
    
    private let calculationLayoutManager = NSLayoutManager()
    
    private let calculationTextContainer = NSTextContainer()
    
    private weak var heightConstraint: NSLayoutConstraint?
    
    private var maxHeight: CGFloat { return heightForNumberOfLines(maximumNumberOfLines) }
    
    private var minHeight: CGFloat { return heightForNumberOfLines(minimumNumberOfLines) }
    
    // MARK: - Open Properties
    
    /// A Boolean value that determines whether the animation of the height change is enabled. Default value is `true`.
    @IBInspectable open var animateHeightChange: Bool = true
    
    /// The receiver's delegate.
    open weak var growingTextViewDelegate: RSKGrowingTextViewDelegate? { didSet { delegate = growingTextViewDelegate } }
    
    /// The duration of the animation of the height change. The default value is `0.35`.
    @IBInspectable open var heightChangeAnimationDuration: Double = 0.35
    
    /// The block which contains user defined actions that will run during the height change.
    open var heightChangeUserActionsBlock: HeightChangeUserActionsBlockType?
    
    /// The maximum number of lines before enabling scrolling. The default value is `5`.
    @IBInspectable open var maximumNumberOfLines: Int = 5 {
        didSet {
            if maximumNumberOfLines < minimumNumberOfLines {
                maximumNumberOfLines = minimumNumberOfLines
            }
            refreshHeightIfNeededAnimated(false)
        }
    }
    
    /// The minimum number of lines. The default value is `1`.
    @IBInspectable open var minimumNumberOfLines: Int = 1 {
        didSet {
            if minimumNumberOfLines < 1 {
                minimumNumberOfLines = 1
            } else if minimumNumberOfLines > maximumNumberOfLines {
                minimumNumberOfLines = maximumNumberOfLines
            }
            refreshHeightIfNeededAnimated(false)
        }
    }
    
    /// The current displayed number of lines. This value is calculated based on the height of text lines.
    open var numberOfLines: Int {
        guard let font = self.font else {
            return 0
        }
        
        let textRectHeight = contentSize.height - contentInset.top - contentInset.bottom - textContainerInset.top - textContainerInset.bottom
        let numberOfLines = textRectHeight / font.lineHeight
        
        return lround(Double(numberOfLines))
    }
    
    // MARK: - Superclass Properties
    
    override open var attributedText: NSAttributedString! {
        didSet {
            superview?.layoutIfNeeded()
        }
    }
    
    override open var contentSize: CGSize {
        didSet {
            guard window != nil && !oldValue.equalTo(contentSize) else {
                return
            }
            if isFirstResponder {
                refreshHeightIfNeededAnimated(animateHeightChange)
            } else {
                refreshHeightIfNeededAnimated(false)
            }
        }
    }
    
    // MARK: - Object Lifecycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitializer()
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInitializer()
    }
    
    override open var intrinsicContentSize: CGSize {
        if heightConstraint != nil {
            return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
        } else {
            return CGSize(width: UIViewNoIntrinsicMetric, height: calculatedHeight)
        }
    }
    
    // MARK: - Private API
    
    private func commonInitializer() {
        contentInset = UIEdgeInsetsMake(1.0, 0.0, 1.0, 0.0)
        scrollsToTop = false
        showsVerticalScrollIndicator = false
        
        for constraint in constraints {
            if constraint.firstAttribute == .height && constraint.relation == .equal {
                heightConstraint = constraint
                break
            }
        }
        
        calculationLayoutManager.addTextContainer(calculationTextContainer)
    }
    
    private func heightForNumberOfLines(_ numberOfLines: Int) -> CGFloat {
        var height = contentInset.top + contentInset.bottom + textContainerInset.top + textContainerInset.bottom
        if let font = self.font {
            height += font.lineHeight * CGFloat(numberOfLines)
        }
        return ceil(height)
    }
    
    private func refreshHeightIfNeededAnimated(_ animated: Bool) {
        let oldHeight = bounds.height
        let newHeight = calculatedHeight
        
        if oldHeight != newHeight {
            typealias HeightChangeSetHeightBlockType = ((_ oldHeight: CGFloat, _ newHeight: CGFloat) -> Void)
            let heightChangeSetHeightBlock: HeightChangeSetHeightBlockType = { (oldHeight: CGFloat, newHeight: CGFloat) -> Void in
                self.setHeight(newHeight)
                self.heightChangeUserActionsBlock?(oldHeight, newHeight)
                self.superview?.layoutIfNeeded()
            }
            typealias HeightChangeCompletionBlockType = ((_ oldHeight: CGFloat, _ newHeight: CGFloat) -> Void)
            let heightChangeCompletionBlock: HeightChangeCompletionBlockType = { (oldHeight: CGFloat, newHeight: CGFloat) -> Void in
                self.layoutManager.ensureLayout(for: self.textContainer)
                self.scrollToVisibleCaretIfNeeded()
                self.growingTextViewDelegate?.growingTextView?(self, didChangeHeightFrom: oldHeight, to: newHeight)
            }
            growingTextViewDelegate?.growingTextView?(self, willChangeHeightFrom: oldHeight, to: newHeight)
            if animated {
                UIView.animate(
                    withDuration: heightChangeAnimationDuration,
                    delay: 0.0,
                    options: [.allowUserInteraction, .beginFromCurrentState],
                    animations: { () -> Void in
                        heightChangeSetHeightBlock(oldHeight, newHeight)
                    },
                    completion: { (finished: Bool) -> Void in
                        heightChangeCompletionBlock(oldHeight, newHeight)
                    }
                )
            } else {
                heightChangeSetHeightBlock(oldHeight, newHeight)
                heightChangeCompletionBlock(oldHeight, newHeight)
            }
        } else {
            scrollToVisibleCaretIfNeeded()
        }
    }
    
    private func scrollRectToVisibleConsideringInsets(_ rect: CGRect) {
        let insets = UIEdgeInsetsMake(contentInset.top + textContainerInset.top, contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding, contentInset.bottom + textContainerInset.bottom, contentInset.right + textContainerInset.right)
        let visibleRect = UIEdgeInsetsInsetRect(bounds, insets)
        
        guard !visibleRect.contains(rect) else {
            return
        }
        
        var contentOffset = self.contentOffset
        if rect.minY < visibleRect.minY {
            contentOffset.y = rect.minY - insets.top * 2
        } else {
            contentOffset.y = rect.maxY + insets.bottom * 2 - bounds.height
        }
        setContentOffset(contentOffset, animated: false)
    }
    
    private func scrollToVisibleCaretIfNeeded() {
        guard let textPosition = selectedTextRange?.end else {
            return
        }
        
        if textStorage.editedRange.location == NSNotFound && !isDragging && !isDecelerating {
            let caretRect = self.caretRect(for: textPosition)
            let caretCenterRect = CGRect(x: caretRect.midX, y: caretRect.midY, width: 0.0, height: 0.0)
            scrollRectToVisibleConsideringInsets(caretCenterRect)
        }
    }
    
    private func setHeight(_ height: CGFloat) {
        if let heightConstraint = self.heightConstraint {
            heightConstraint.constant = height
        } else if !constraints.isEmpty {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        } else {
            frame.size.height = height
        }
    }
}
