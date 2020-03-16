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
    
    // MARK: - Private Properties
    
    private var placeholderAttributes: [NSAttributedString.Key: Any] {
        
        var placeholderAttributes = self.typingAttributes
        
        if placeholderAttributes[.font] == nil {
            
            placeholderAttributes[.font] = self.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
        
        if placeholderAttributes[.paragraphStyle] == nil {
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.textAlignment
            paragraphStyle.lineBreakMode = self.textContainer.lineBreakMode
            placeholderAttributes[.paragraphStyle] = paragraphStyle
        }
        
        placeholderAttributes[.foregroundColor] = self.placeholderColor
        
        return placeholderAttributes
    }
    
    private var placeholderInsets: UIEdgeInsets {
        
        let placeholderInsets = UIEdgeInsets(top: self.contentInset.top + self.textContainerInset.top,
                                             left: self.contentInset.left + self.textContainerInset.left,
                                             bottom: self.contentInset.bottom + self.textContainerInset.bottom,
                                             right: self.contentInset.right + self.textContainerInset.right)
        return placeholderInsets
    }
    
    private lazy var placeholderLayoutManager: NSLayoutManager = NSLayoutManager()
    
    private lazy var placeholderTextContainer: NSTextContainer = NSTextContainer()
    
    // MARK: - Open Properties
    
    /// The attributed string that is displayed when there is no other text in the placeholder text view. This value is `nil` by default.
    @NSCopying open var attributedPlaceholder: NSAttributedString? {
        
        didSet {
            
            guard self.attributedPlaceholder != oldValue else {
                
                return
            }
            if let attributedPlaceholder = self.attributedPlaceholder {
                
                let attributes = attributedPlaceholder.attributes(at: 0, effectiveRange: nil)
                if let font = attributes[.font] as? UIFont,
                    self.font != font {
                    
                    self.font = font
                    self.typingAttributes[.font] = font
                }
                if let foregroundColor = attributes[.foregroundColor] as? UIColor,
                    self.placeholderColor != foregroundColor {
                    
                    self.placeholderColor = foregroundColor
                }
                if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle,
                    self.textAlignment != paragraphStyle.alignment {
                    
                    let mutableParagraphStyle = NSMutableParagraphStyle()
                    mutableParagraphStyle.setParagraphStyle(paragraphStyle)
                    
                    self.textAlignment = paragraphStyle.alignment
                    self.typingAttributes[.paragraphStyle] = mutableParagraphStyle
                }
            }
            guard self.isEmpty == true else {
                
                return
            }
            self.setNeedsDisplay()
        }
    }
    
    /// Determines whether or not the placeholder text view contains text.
    open var isEmpty: Bool { return self.text.isEmpty }
    
    /// The string that is displayed when there is no other text in the placeholder text view. This value is `nil` by default.
    @IBInspectable open var placeholder: NSString? {
        
        get {
            
            return self.attributedPlaceholder?.string as NSString?
        }
        set {
            
            if let newValue = newValue as String? {
                
                self.attributedPlaceholder = NSAttributedString(string: newValue, attributes: self.placeholderAttributes)
            }
            else {
                
                self.attributedPlaceholder = nil
            }
        }
    }
    
    /// The color of the placeholder. This property applies to the entire placeholder string. The default placeholder color is `UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)`.
    @IBInspectable open var placeholderColor: UIColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0) {
        
        didSet {
            
            if let placeholder = self.placeholder as String? {
                
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: self.placeholderAttributes)
            }
        }
    }
    
    // MARK: - Superclass Properties
    
    open override var attributedText: NSAttributedString! { didSet { self.setNeedsDisplay() } }
    
    open override var bounds: CGRect { didSet { self.setNeedsDisplay() } }
    
    open override var contentInset: UIEdgeInsets { didSet { self.setNeedsDisplay() } }
    
    open override var font: UIFont? {
        
        didSet {
            
            if let placeholder = self.placeholder as String? {
                
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: self.placeholderAttributes)
            }
        }
    }
    
    open override var textAlignment: NSTextAlignment {
        
        didSet {
            
            if let placeholder = self.placeholder as String? {
                
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: self.placeholderAttributes)
            }
        }
    }
    
    open override var textContainerInset: UIEdgeInsets { didSet { self.setNeedsDisplay() } }
    
    open override var typingAttributes: [NSAttributedString.Key: Any] {
        
        didSet {
            
            if let placeholder = self.placeholder as String? {
                
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: self.placeholderAttributes)
            }
        }
    }
    
    // MARK: - Object Lifecycle
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.commonInitializer()
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        
        super.init(frame: frame, textContainer: textContainer)
        
        self.commonInitializer()
    }
    
    // MARK: - Superclass API
    
    open override func caretRect(for position: UITextPosition) -> CGRect {
        
        guard self.text.isEmpty == true,
            let attributedPlaceholder = self.attributedPlaceholder,
            attributedPlaceholder.length > 0 else {
            
            return super.caretRect(for: position)
        }
        
        var caretRect = super.caretRect(for: position)
        
        let placeholderUsedRect = self.placeholderUsedRect(for: attributedPlaceholder)
        
        let userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection
        if #available(iOS 10.0, *) {
            
            userInterfaceLayoutDirection = self.effectiveUserInterfaceLayoutDirection
        }
        else {
            
            userInterfaceLayoutDirection = UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute)
        }
        
        let placeholderInsets = self.placeholderInsets
        switch userInterfaceLayoutDirection {
            
        case .rightToLeft:
            caretRect.origin.x = placeholderInsets.left + placeholderUsedRect.maxX - self.textContainer.lineFragmentPadding
            
        case .leftToRight:
            fallthrough
            
        @unknown default:
            caretRect.origin.x = placeholderInsets.left + placeholderUsedRect.minX + self.textContainer.lineFragmentPadding
        }
        
        return caretRect
    }
    
    open override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        guard self.isEmpty == true else {
            
            return
        }
        
        guard let attributedPlaceholder = self.attributedPlaceholder else {
            
            return
        }
        
        var inset = self.placeholderInsets
        inset.left += self.textContainer.lineFragmentPadding
        inset.right += self.textContainer.lineFragmentPadding
        
        let placeholderRect = rect.inset(by: inset)
        
        attributedPlaceholder.draw(in: placeholderRect)
    }
    
    // MARK: - Private API
    
    private func commonInitializer() {
        
        self.contentMode = .topLeft
        
        NotificationCenter.default.addObserver(self, selector: #selector(RSKPlaceholderTextView.handleTextViewTextDidChangeNotification(_:)), name: UITextView.textDidChangeNotification, object: self)
    }
    
    @objc internal func handleTextViewTextDidChangeNotification(_ notification: Notification) {
        
        guard let object = notification.object as? RSKPlaceholderTextView, object === self else {
            
            return
        }
        self.setNeedsDisplay()
    }
    
    private func placeholderUsedRect(for attributedPlaceholder: NSAttributedString) -> CGRect {
        
        if self.placeholderTextContainer.layoutManager == nil {
            
            self.placeholderLayoutManager.addTextContainer(self.placeholderTextContainer)
        }
        
        let placeholderTextStorage = NSTextStorage(attributedString: attributedPlaceholder)
        placeholderTextStorage.addLayoutManager(self.placeholderLayoutManager)
        
        self.placeholderTextContainer.lineFragmentPadding = self.textContainer.lineFragmentPadding
        self.placeholderTextContainer.size = CGSize(width: self.textContainer.size.width, height: 0.0)
        
        self.placeholderLayoutManager.ensureLayout(for: self.placeholderTextContainer)
        
        return self.placeholderLayoutManager.usedRect(for: self.placeholderTextContainer)
    }
}
