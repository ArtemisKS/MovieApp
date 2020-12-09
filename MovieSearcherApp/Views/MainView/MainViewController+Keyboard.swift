//
//  MainViewController+Keyboard.swift
//  MovieSearcherApp
//
//  Created by Artem Kupriianets on 09.12.2020.
//

import UIKit

extension MainViewController {
    
    private var bottomSafeArea: CGFloat {
        let window = UIApplication.shared.keyWindow
        return window?.safeAreaInsets.bottom ?? 0
    }
    
    func addKeyboardObservers() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showKeyboard(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideKeyboard(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc func showKeyboard(_ notification: Notification) {
        if let keyboardHeight = getKeyboardHeightFrom(notification) {
            
            footerResLabel.frame = getFooterLabelFrame(with: keyboardHeight)
        }
    }
    
    @objc func hideKeyboard(_ notification: Notification) {
        footerResLabel.frame = getFooterLabelFrame()
    }
    
    func getKeyboardHeightFrom(_ notification: Notification) -> CGFloat? {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            return keyboardRectangle.height
        }
        return nil
    }
    
    func getFooterLabelFrame(with keyboardHeight: CGFloat? = nil) -> CGRect {
        
        let origin = CGPoint(
            x: 0,
            y: getFooterLabelY(with: keyboardHeight))
        
        let size = CGSize(
            width: view.frame.width,
            height: getFooterLabelHeight(with: keyboardHeight))
        
        return CGRect(origin: origin, size: size)
    }
    
    func getFooterLabelY(with keyboardHeight: CGFloat?) -> CGFloat {
        let val = keyboardHeight ?? bottomSafeArea
        return view.frame.height - footerResLabelHeight
            - val
    }
    
    func getFooterLabelHeight(with keyboardHeight: CGFloat?) -> CGFloat {
        let val = keyboardHeight != nil ?
            footerResLabelHeight : footerResLabelHeight + bottomSafeArea
        return val
    }
}
