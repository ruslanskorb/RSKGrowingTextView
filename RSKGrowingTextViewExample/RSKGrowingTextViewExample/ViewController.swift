//
//  ViewController.swift
//  RSKGrowingTextViewExample
//
//  Created by Ruslan Skorb on 12/14/15.
//  Copyright © 2015 Ruslan Skorb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var bottomLayoutGuideTopAndGrowingTextViewBottomVeticalSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var growingTextView: RSKGrowingTextView!
    
    private var isVisibleKeyboard = true
    
    // MARK: - Object Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.unregisterForKeyboardNotifications()
    }
    
    // MARK: - Helper Methods
    
    private func adjustContent(for keyboardRect: CGRect) {
        let keyboardHeight = keyboardRect.height
        self.bottomLayoutGuideTopAndGrowingTextViewBottomVeticalSpaceConstraint.constant = self.isVisibleKeyboard ? keyboardHeight - self.view.safeAreaInsets.bottom : 0.0
        self.view.layoutIfNeeded()
    }
    
    @IBAction func handleTapGestureRecognizer(sender: UITapGestureRecognizer) {
        self.growingTextView.resignFirstResponder()
    }
    
    @objc private func handle(keyboardNotification: Notification) {
        guard let userInfo = keyboardNotification.userInfo, let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardRect = self.view.convert(keyboardFrameEnd.cgRectValue, from: nil)
        switch keyboardNotification.name {
        case UIResponder.keyboardDidHideNotification, UIResponder.keyboardWillHideNotification:
            self.isVisibleKeyboard = false
        case UIResponder.keyboardDidShowNotification, UIResponder.keyboardWillShowNotification:
            self.isVisibleKeyboard = true
        case UIResponder.keyboardWillChangeFrameNotification:
            break
        default:
            return
        }
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
        var options: UIView.AnimationOptions = [.beginFromCurrentState]
        let keyboardAnimationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        if let keyboardAnimationCurve = keyboardAnimationCurve?.intValue,
           let animationCurve = UIView.AnimationCurve(rawValue: keyboardAnimationCurve) {
            switch animationCurve {
            case .easeInOut:
                options.insert(.curveEaseInOut)
            case .easeIn:
                options.insert(.curveEaseIn)
            case .easeOut:
                options.insert(.curveEaseOut)
            case .linear:
                options.insert(.curveLinear)
            @unknown default:
                break
            }
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.adjustContent(for: keyboardRect)
        })
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}

