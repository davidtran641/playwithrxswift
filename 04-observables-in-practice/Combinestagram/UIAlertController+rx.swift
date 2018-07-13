//
//  UIAlertController+rx.swift
//  Combinestagram
//
//  Created by tranduc on 7/12/18.
//  Copyright © 2018 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
  func alert(_ message: String, description: String? = nil) -> Completable {
    return Completable.create(subscribe: {[weak self] (observer) -> Disposable in
      let alert = UIAlertController(title: message, message: description, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
        observer(.completed)
      }))
      self?.present(alert, animated: true, completion: nil)
      
      return Disposables.create {
        self?.dismiss(animated: true, completion: nil)
      }
    })
    
    
  }
}
