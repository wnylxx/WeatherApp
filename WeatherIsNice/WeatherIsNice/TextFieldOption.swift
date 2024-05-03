//
//  TextFieldOption.swift
//  WeatherIsNice
//
//  Created by wonyoul heo on 5/3/24.
//

import Foundation

import SwiftUI

class KeyboardHeightObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardSize.height
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        keyboardHeight = 0
    }
}
