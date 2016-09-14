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

/// A light-weight UITextView subclass that adds support for placeholder.
@IBDesignable open class RSKPlaceholderTextView: UITextView {
    
    // MARK: - Public Properties
    
    /// Determines whether or not the placeholder text view contains text.
    open var isEmpty: Bool { return text.isEmpty }
    
    /// The string that is displayed when there is no other text in the placeholder text view. This value is `nil` by default.
    @IBInspectable open var placeholder: NSString? { didSet { setNeedsDisplay() } }
    
    /// The color of the placeholder. This property applies to the entire placeholder string. The default placeholder color is `UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)`.
    @IBInspectable open var placeholderColor: UIColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    // MARK: - Superclass Properties
    
    override open var attributedText: NSAttributedString! { didSet { setNeedsDisplay() } }
    
    override open var bounds: CGRect { didSet { setNeedsDisplay() } }
    
    override open var contentInset: UIEdgeInsets { didSet { setNeedsDisplay() } }
    
    override open var font: UIFont? { didSet { setNeedsDisplay() } }
    
    override open var textAlignment: NSTextAlignment { didSet { setNeedsDisplay() } }
    
    override open var textContainerInset: UIEdgeInsets { didSet { setNeedsDisplay() } }
    
    override open var typingAttributes: [String : Any] {
        didSet {
            guard isEmpty else {
                return
            }
            setNeedsDisplay()
        }
    }
    
    // MARK: - Object Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInitializer()
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInitializer()
    }
    
    // MARK: - Drawing
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard isEmpty else {
            return
        }
        guard let placeholder = self.placeholder else {
            return
        }
        
        var placeholderAttributes = typingAttributes
        if placeholderAttributes[NSFontAttributeName] == nil {
            placeholderAttributes[NSFontAttributeName] = typingAttributes[NSFontAttributeName] ?? font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
        if placeholderAttributes[NSParagraphStyleAttributeName] == nil {
            let typingParagraphStyle = typingAttributes[NSParagraphStyleAttributeName]
            if typingParagraphStyle == nil {
                let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                paragraphStyle.alignment = textAlignment
                paragraphStyle.lineBreakMode = textContainer.lineBreakMode
                placeholderAttributes[NSParagraphStyleAttributeName] = paragraphStyle
            } else {
                placeholderAttributes[NSParagraphStyleAttributeName] = typingParagraphStyle
            }
        }
        placeholderAttributes[NSForegroundColorAttributeName] = placeholderColor
        
        let placeholderInsets = UIEdgeInsets(top: contentInset.top + textContainerInset.top,
                                             left: contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding,
                                             bottom: contentInset.bottom + textContainerInset.bottom,
                                             right: contentInset.right + textContainerInset.right + textContainer.lineFragmentPadding)
        
        let placeholderRect = UIEdgeInsetsInsetRect(rect, placeholderInsets)
        placeholder.draw(in: placeholderRect, withAttributes: placeholderAttributes)
    }
    
    // MARK: - Helper Methods
    
    fileprivate func commonInitializer() {
        contentMode = .topLeft
        NotificationCenter.default.addObserver(self, selector: #selector(RSKPlaceholderTextView.handleTextViewTextDidChangeNotification(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    internal func handleTextViewTextDidChangeNotification(_ notification: Notification) {
        guard let object = notification.object as? RSKPlaceholderTextView, object === self else {
            return
        }
        setNeedsDisplay()
    }
}
