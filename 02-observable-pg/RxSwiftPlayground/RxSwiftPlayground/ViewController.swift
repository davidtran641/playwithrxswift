//
//  ViewController.swift
//  RxSwiftPlayground
//
//  Created by Scott Gardner on 10/15/17.
//  Copyright © 2017 Scott Gardner. All rights reserved.
//

import UIKit
import RxSwift


class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    example(of: "subscribe") {
      let one = 1
      let two = 2
      let three = 3
      let observable = Observable.of(one, two, three)
      observable.subscribe { event in
        print(event)
      }
    }
    
    example(of: "empty") {
      let observable = Observable<Void>.empty()
      observable.subscribe(onNext: { (event) in
        print(event)
      }, onCompleted: {
        print("completed")
      })
    }
    
    example(of: "never") {
      let observable = Observable<Void>.never()
      observable.subscribe(onNext: { (event) in
        print(event)
      }, onCompleted: {
        print("completed")
      })
    }
    
    example(of: "range") {
      let observable = Observable<Int>.range(start: 0, count: 5)
      observable.subscribe { event in
        print(event)
      }
    }
    
    example(of: "DisposeBag") {
      let disposeBag = DisposeBag()
      Observable.of("A", "B", "C")
        .subscribe {
          print($0)
        }
        .disposed(by: disposeBag)
    }
    
    example(of: "create") {
      enum MyError: Error {
        case anError
      }
      
      let disposeBag = DisposeBag()
      Observable<String>.create { observer in
          observer.onNext("1")
          observer.onError(MyError.anError)
          observer.onCompleted()
          observer.onNext("?")
          return Disposables.create()
        }.subscribe(onNext: { print($0) },
                    onError: { print($0) },
                    onCompleted: { print("Completed") },
                    onDisposed: { print("Disposed") })
        .disposed(by: disposeBag)
    }
    
    example(of: "deffered") {
      let disposeBag = DisposeBag()
      var flip = false
      let factory = Observable<Int>.deferred({ () -> Observable<Int> in
        flip = !flip
        if flip {
          return Observable.of(1,2,3)
        } else {
          return Observable.of(4,5,6)
        }
      })
      
      for _ in 0...3 {
        factory.subscribe {
          print($0, terminator: " ")
        }
        .disposed(by: disposeBag)
        print()
      }
    }
    
    example(of: "single") {
      let disposeBag = DisposeBag()
      enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
      }
      
      func loadText(from name: String) -> Single<String> {
        return Single.create { single -> Disposable in
          let disposable = Disposables.create()
          
          guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
            single(.error(FileReadError.fileNotFound))
            return disposable
          }
          
          guard let data = FileManager.default.contents(atPath: path) else {
            single(.error(FileReadError.unreadable))
            return disposable
          }
          
          guard let content = String(data: data, encoding: .utf8) else {
            single(.error(FileReadError.encodingFailed))
            return disposable
          }
          
          single(.success(content))
          return disposable
        }
      }
      
      loadText(from: "Copyright").subscribe {
        switch $0 {
        case .error(let error):
          print(error)
        case .success(let value):
          print(value)
        }
      }.disposed(by: disposeBag)
    }
    
    example(of: "challenge-side-effect") {
      let disposeBag = DisposeBag()
      let observable = Observable<Void>.never()
      observable.do(onNext: { (event) in
        print(event)
      }, onError: { (error) in
        print(error)
      }, onCompleted: {
        print("onCompleted")
      }, onSubscribe: {
        print("onSubscribe")
      }, onSubscribed: {
        print("onSubscribed")
      }, onDispose: {
        print("onDispose")
      }).subscribe(onNext: { (event) in
        print(event)
      }, onCompleted: {
        print("completed")
      }).disposed(by: disposeBag)
    }
    
    example(of: "Challenge-debug-info") {
      let disposeBag = DisposeBag()
      let observable = Observable<Void>.never()
      observable.debug("never-id", trimOutput: false).subscribe(onNext: { (event) in
        print(event)
      }, onCompleted: {
        print("completed")
      }).disposed(by: disposeBag)    }
    
  }
  
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

