//
//  PHPhotoLibrary+rx.swift
//  Combinestagram
//
//  Created by tranduc on 7/16/18.
//  Copyright © 2018 Underplot ltd. All rights reserved.
//

import UIKit
import Photos
import RxSwift

extension PHPhotoLibrary {
  static var authorized: Observable<Bool> {
    return Observable.create({ (observer) -> Disposable in
      DispatchQueue.main.async {
        if authorizationStatus() == .authorized {
          observer.onNext(true)
          observer.onCompleted()
        } else {
          observer.onNext(false)
          requestAuthorization({ (status) in
            observer.onNext(status == .authorized)
            observer.onCompleted()
          })
        }
      }
      return Disposables.create()
    })
  }
}
