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

import RSKPlaceholderTextView
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
    
    private var calculatedHeight: CGFloat { makeCalculatedSize(textContainerSize: CGSize(width: textContainer.size.width, height: 0.0)).height }
    
    private let calculationLayoutManager = NSLayoutManager()
    
    private let calculationTextContainer = NSTextContainer()
    
    private var _calculationTextLayoutManager: NSObject?
    
    @available(iOS 16.0, *)
    private var calculationTextLayoutManager: NSTextLayoutManager? { _calculationTextLayoutManager as? NSTextLayoutManager }
    
    private weak var heightConstraint: NSLayoutConstraint?
    
    private var maxHeight: CGFloat { return heightForNumberOfLines(maximumNumberOfLines) }
    
    private var minHeight: CGFloat { return heightForNumberOfLines(minimumNumberOfLines) }
    
    // MARK: - Open Properties
    
    /// A Boolean value that determines whether the animation of the height change is enabled. Default value is `true`.
    @IBInspectable open var animateHeightChange: Bool = true
    
    /// The receiver's delegate.
    @objc open weak var growingTextViewDelegate: RSKGrowingTextViewDelegate? { didSet { delegate = growingTextViewDelegate } }
    
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
    
    /// The current displayed number of lines. This value is calculated at run time.
    open var numberOfLines: Int {
        var numberOfLines = 0
        if #available(iOS 16.0, *), let textLayoutManager {
            textLayoutManager.enumerateTextLayoutFragments(from: textLayoutManager.documentRange.location, options: [.ensuresLayout]) { layoutFragment in
                numberOfLines += layoutFragment.textLineFragments.count
                return true
            }
        } else {
            var index = 0
            var lineRange = NSRange()
            let numberOfGlyphs = layoutManager.numberOfGlyphs
            while index < numberOfGlyphs {
                _ = layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
                index = NSMaxRange(lineRange)
                numberOfLines += 1
            }
        }
        return numberOfLines
    }
    
    // MARK: - Superclass Properties
    
    open override var attributedPlaceholder: NSAttributedString? {
        didSet {
            refreshHeightIfNeededAnimated(false)
        }
    }

    override open var attributedText: NSAttributedString! {
        didSet {
            refreshHeightIfNeededAnimated(false)
        }
    }
    
    override open var contentSize: CGSize {
        didSet {
            guard !oldValue.equalTo(contentSize) else {
                return
            }
            if window != nil && isFirstResponder {
                refreshHeightIfNeededAnimated(animateHeightChange)
            } else {
                refreshHeightIfNeededAnimated(false)
            }
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        if heightConstraint != nil {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        } else {
            return CGSize(width: UIView.noIntrinsicMetric, height: calculatedHeight)
        }
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var textContainerSize = size
        
        textContainerSize.width -= textContainerInset.left + textContainerInset.right
        textContainerSize.height -= textContainerInset.top + textContainerInset.bottom
        
        let size = makeCalculatedSize(textContainerSize: textContainerSize)
        return size
    }
    
    open override func sizeToFit() {
        self.bounds.size = makeCalculatedSize(textContainerSize: .zero)
    }
    
    // MARK: - Object Lifecycle
    
    required public init?(coder aDecoder: NSCoder) {
        if #available(iOS 16.0, *) {
            let calculationTextLayoutManager = NSTextLayoutManager()
            calculationTextLayoutManager.textContainer = calculationTextContainer
            _calculationTextLayoutManager = calculationTextLayoutManager
        } else {
            calculationLayoutManager.addTextContainer(calculationTextContainer)
        }
        super.init(coder: aDecoder)
        commonInitializer()
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        if #available(iOS 16.0, *) {
            let calculationTextLayoutManager = NSTextLayoutManager()
            calculationTextLayoutManager.textContainer = calculationTextContainer
            _calculationTextLayoutManager = calculationTextLayoutManager
        } else {
            calculationLayoutManager.addTextContainer(calculationTextContainer)
        }
        super.init(frame: frame, textContainer: textContainer)
        commonInitializer()
    }
    
    @available(iOS 16.0, *)
    public convenience init(usingTextLayoutManager: Bool) {
        if usingTextLayoutManager {
            self.init(frame: .zero, textContainer: nil)
        } else {
            let layoutManager = NSLayoutManager()
            let textStorage = NSTextStorage()
            textStorage.addLayoutManager(layoutManager)
            let textContainer = NSTextContainer()
            layoutManager.addTextContainer(textContainer)
            self.init(frame: .zero, textContainer: textContainer)
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleRSKGrowingTextViewTextDidChangeNotification(_ notification: Notification) {
        refreshHeightIfNeededAnimated(animateHeightChange)
    }
    
    // MARK: - Private API
    
    private func commonInitializer() {
        if #available(iOS 16.0, *), textLayoutManager == nil {
            _calculationTextLayoutManager = nil
            calculationLayoutManager.addTextContainer(calculationTextContainer)
        }
        
        var textContainerInset = textContainerInset
        textContainerInset.top += 1.0
        textContainerInset.bottom += 1.0
        self.textContainerInset = textContainerInset
        
        scrollsToTop = false
        showsVerticalScrollIndicator = false
        
        for constraint in constraints {
            if constraint.firstAttribute == .height, constraint.relation == .equal, type(of: constraint) == NSLayoutConstraint.self {
                heightConstraint = constraint
                heightConstraint?.constant = calculatedHeight
                invalidateIntrinsicContentSize()
                setNeedsLayout()
                break
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(RSKGrowingTextView.handleRSKGrowingTextViewTextDidChangeNotification(_:)), name: UITextView.textDidChangeNotification, object: self)
    }
    
    private func heightForNumberOfLines(_ numberOfLines: Int) -> CGFloat {
        var height = textContainerInset.top + textContainerInset.bottom
        
        var numberOfNonEmptyLines = 0
        if #available(iOS 16.0, *), let calculationTextLayoutManager {
            calculationTextLayoutManager.enumerateTextLayoutFragments(from: calculationTextLayoutManager.documentRange.location, options: [.ensuresLayout]) { layoutFragment in
                var index = 0
                while index < layoutFragment.textLineFragments.count, numberOfNonEmptyLines < numberOfLines {
                    height += layoutFragment.textLineFragments[index].typographicBounds.height
                    index += 1
                    numberOfNonEmptyLines += 1
                }
                return numberOfNonEmptyLines < numberOfLines
            }
        } else {
            var index = 0
            let numberOfGlyphs = calculationLayoutManager.numberOfGlyphs
            while index < numberOfGlyphs, numberOfNonEmptyLines < numberOfLines {
                var lineRange = NSRange()
                height += calculationLayoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange).height
                index = NSMaxRange(lineRange)
                numberOfNonEmptyLines += 1
            }
        }
        
        let numberOfEmptyLines = (numberOfLines - numberOfNonEmptyLines)
        if numberOfEmptyLines > 0 {
            let font = (self.typingAttributes[.font] as? UIFont) ?? self.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
            var lineHeight = font.lineHeight
            if let paragraphStyle = self.typingAttributes[.paragraphStyle] as? NSParagraphStyle {
                if paragraphStyle.lineHeightMultiple > 0.0 {
                    lineHeight *= paragraphStyle.lineHeightMultiple
                }
                if paragraphStyle.minimumLineHeight > 0.0, lineHeight < paragraphStyle.minimumLineHeight {
                    lineHeight = paragraphStyle.minimumLineHeight
                } else if paragraphStyle.maximumLineHeight > 0.0, lineHeight > paragraphStyle.maximumLineHeight {
                    lineHeight = paragraphStyle.maximumLineHeight
                }
                lineHeight += paragraphStyle.lineSpacing
            }
            height += lineHeight * CGFloat(numberOfEmptyLines)
        }
        
        return ceil(height)
    }
    
    private func makeCalculatedSize(textContainerSize: CGSize) -> CGSize {
        var size = CGSize.zero
        
        if #available(iOS 16.0, *), let calculationTextLayoutManager {
            let calculationTextContentStorage: NSTextContentStorage?
            if let attributedText, attributedText.length > 0 {
                calculationTextContentStorage = NSTextContentStorage()
                calculationTextContentStorage?.attributedString = attributedText
            } else if let attributedPlaceholder, attributedPlaceholder.length > 0 {
                calculationTextContentStorage = NSTextContentStorage()
                calculationTextContentStorage?.attributedString = attributedPlaceholder
            } else {
                calculationTextContentStorage = nil
            }
            if let calculationTextContentStorage {
                calculationTextContentStorage.addTextLayoutManager(calculationTextLayoutManager)
                
                calculationTextContainer.lineFragmentPadding = textContainer.lineFragmentPadding
                calculationTextContainer.size = textContainerSize
                
                calculationTextLayoutManager.textContainer = calculationTextContainer
                calculationTextLayoutManager.ensureLayout(for: calculationTextLayoutManager.documentRange)
                
                size = calculationTextLayoutManager.usageBoundsForTextContainer.size
            }
        } else {
            let calculationTextStorage: NSTextStorage?
            if let attributedText = attributedText, attributedText.length > 0 {
                calculationTextStorage = NSTextStorage(attributedString: attributedText)
            } else if let attributedPlaceholder = attributedPlaceholder, attributedPlaceholder.length > 0 {
                calculationTextStorage = NSTextStorage(attributedString: attributedPlaceholder)
            } else {
                calculationTextStorage = nil
            }
            if let calculationTextStorage {
                calculationTextStorage.addLayoutManager(calculationLayoutManager)
                
                calculationTextContainer.lineFragmentPadding = textContainer.lineFragmentPadding
                calculationTextContainer.size = textContainerSize
                
                calculationLayoutManager.ensureLayout(for: calculationTextContainer)
                
                let usedRect = calculationLayoutManager.usedRect(for: calculationTextContainer)
                size = CGSize(width: usedRect.maxX, height: usedRect.maxY)
            }
        }
        
        size.height = ceil(textContainerInset.top + size.height + textContainerInset.bottom)
        size.width = ceil(textContainerInset.left + size.width + textContainerInset.right)
        
        let minHeight = minHeight
        if size.height < minHeight {
            size.height = minHeight
            return size
        }
        
        let maxHeight = maxHeight
        if size.height > maxHeight {
            size.height = maxHeight
            return size
        }
        
        return size
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
            let heightChangeCompletionBlock: HeightChangeCompletionBlockType = { [weak self] (oldHeight: CGFloat, newHeight: CGFloat) -> Void in
                guard let self else {
                    return
                }
                if #available(iOS 16.0, *), let textLayoutManager = self.textLayoutManager {
                    textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
                } else {
                    self.layoutManager.ensureLayout(for: self.textContainer)
                }
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
        let insets = UIEdgeInsets(
            top: contentInset.top + textContainerInset.top,
            left: contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding,
            bottom: contentInset.bottom + textContainerInset.bottom,
            right: contentInset.right + textContainerInset.right + textContainer.lineFragmentPadding
        )
        let visibleRect = bounds.inset(by: insets)
        
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
