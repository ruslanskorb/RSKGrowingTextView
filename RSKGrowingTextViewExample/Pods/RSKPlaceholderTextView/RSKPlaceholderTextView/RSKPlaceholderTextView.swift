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
@IBDesignable public class RSKPlaceholderTextView: UITextView {
    
    // MARK: - Public Properties
    
    /// Determines whether or not the placeholder text view contains text.
    public var isEmpty: Bool { return text.isEmpty }
    
    /// The string that is displayed when there is no other text in the placeholder text view. This value is `nil` by default.
    @IBInspectable public var placeholder: NSString? { didSet { setNeedsDisplay() } }
    
    /// The color of the placeholder. This property applies to the entire placeholder string. The default placeholder color is `UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)`.
    @IBInspectable public var placeholderColor: UIColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) { didSet { setNeedsDisplay() } }
    
    // MARK: - Superclass Properties
    
    override public var attributedText: NSAttributedString! { didSet { setNeedsDisplay() } }
    
    override public var bounds: CGRect { didSet { setNeedsDisplay() } }
    
    override public var contentInset: UIEdgeInsets { didSet { setNeedsDisplay() } }
    
    override public var font: UIFont? { didSet { setNeedsDisplay() } }
    
    override public var textAlignment: NSTextAlignment { didSet { setNeedsDisplay() } }
    
    override public var textContainerInset: UIEdgeInsets { didSet { setNeedsDisplay() } }
    
    override public var typingAttributes: [String : AnyObject] {
        didSet {
            guard isEmpty else {
                return
            }
            setNeedsDisplay()
        }
    }
    
    // MARK: - Object Lifecycle
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidChangeNotification, object: self)
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
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard isEmpty else {
            return
        }
        guard let placeholder = self.placeholder else {
            return
        }
        
        var placeholderAttributes = typingAttributes ?? [String: AnyObject]()
        if placeholderAttributes[NSFontAttributeName] == nil {
            placeholderAttributes[NSFontAttributeName] = typingAttributes[NSFontAttributeName] ?? font ?? UIFont.systemFontOfSize(UIFont.systemFontSize())
        }
        if placeholderAttributes[NSParagraphStyleAttributeName] == nil {
            let typingParagraphStyle = typingAttributes[NSParagraphStyleAttributeName]
            if typingParagraphStyle == nil {
                let paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                paragraphStyle.alignment = textAlignment
                paragraphStyle.lineBreakMode = textContainer.lineBreakMode
                placeholderAttributes[NSParagraphStyleAttributeName] = paragraphStyle
            } else {
                placeholderAttributes[NSParagraphStyleAttributeName] = typingParagraphStyle
            }
        }
        placeholderAttributes[NSForegroundColorAttributeName] = placeholderColor
        
        let placeholderRect = CGRectInset(rect, contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding, contentInset.top + textContainerInset.top)
        placeholder.drawInRect(placeholderRect, withAttributes: placeholderAttributes)
    }
    
    // MARK: - Helper Methods
    
    private func commonInitializer() {
        contentMode = .TopLeft
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RSKPlaceholderTextView.handleTextViewTextDidChangeNotification(_:)), name: UITextViewTextDidChangeNotification, object: self)
    }
    
    internal func handleTextViewTextDidChangeNotification(notification: NSNotification) {
        guard let object = notification.object where object === self else {
            return
        }
        setNeedsDisplay()
    }
}
