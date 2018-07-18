//
//  ViewController.swift
//  RxSwiftPlayground
//
//  Created by Scott Gardner on 10/15/17.
//  Copyright © 2017 Scott Gardner. All rights reserved.
//

import UIKit
import RxSwift

public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    example(of: "startWith") {
      let numbers = Observable.of(2, 3, 4)
      
      let observable = numbers.startWith(1)
      observable.subscribe(onNext: { value in
        print(value)
      })
    }
    
    example(of: "Observable.concat") {
      // 1
      let first = Observable.of(1, 2, 3)
      let second = Observable.of(4, 5, 6)
      // 2
      let observable = Observable.concat([first, second])
      observable.subscribe(onNext: { value in
        print(value)
      })
    }
    
    example(of: "concatMap") {
      let sequences = [
        "Germany": Observable.of("Berlin", "Münich", "Frankfurt"),
        "Spain": Observable.of("Madrid", "Barcelona", "Valencia")
      ]
      let observable = Observable.of("Germany", "Spain")
        .concatMap { country in sequences[country] ?? .empty()}
      
      // 3
      _ = observable.subscribe(onNext: { string in
        print(string)
      })
    }
    
    example(of: "merge") {
      let bag = DisposeBag()
      
      let left = PublishSubject<String>()
      let right = PublishSubject<String>()
      
      let source = Observable.of(left, right)
      let observable = source.merge()
      observable.subscribe {
        print($0)
      }
      .disposed(by: bag)
      
      left.onNext("Left: 1")
      right.onNext("Right: 1")
      left.onNext("Left: 2")
      left.onNext("Left: 3")
      left.onCompleted()
      right.onNext("Right: 2")
      right.onCompleted()
      
    }
    
    example(of: "combineLatest") {
      let bag = DisposeBag()
      let left = PublishSubject<String>()
      let right = PublishSubject<String>()
      
      Observable
        .combineLatest(left, right, resultSelector: { lastLeft, lastRight in
          return "\(lastLeft) \(lastRight)"
        })
        .subscribe {
          print($0)
        }
        .disposed(by: bag)
      
      left.onNext("A")
      right.onNext("1")
      left.onNext("B")
      left.onNext("C")
      left.onCompleted()
      right.onNext("2")
      right.onCompleted()
    }
    
    example(of: "zip") {
      enum Weather {
        case cloudy
        case sunny
      }
      
      let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy,
                                                    .sunny)
      let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid",
                                "Vienna")
      
      let bag = DisposeBag()
      
      let observable = Observable.zip(left, right, resultSelector: { (weather, city) in
        return "It's \(weather) in \(city)"
      })
      observable
        .subscribe { print($0)}
        .disposed(by: bag)
      
    }
    
    example(of: "withLatestFrom") {
      let bag = DisposeBag()
      
      let button = PublishSubject<Void>()
      let textField = PublishSubject<String>()
      
      let observable = button.withLatestFrom(textField)
      observable
        .subscribe {
          print($0)
        }
        .disposed(by: bag)
      
      textField.onNext("Par")
      textField.onNext("Pari")
      textField.onNext("Paris")
      button.onNext(())
      button.onNext(())
    }
    
    example(of: "sample") {
      let bag = DisposeBag()
      
      let button = PublishSubject<Void>()
      let textField = PublishSubject<String>()
      
      let observable = textField.sample(button)
      observable
        .subscribe {
          print($0)
        }
        .disposed(by: bag)
      
      textField.onNext("Par")
      textField.onNext("Pari")
      textField.onNext("Paris")
      button.onNext(())
      button.onNext(())
    }
    
    example(of: "amb") {
      let left = PublishSubject<String>()
      let right = PublishSubject<String>()
      
      let observable = left.amb(right)
      let disposable = observable.subscribe(onNext: { value in
        print(value)
      })
      
      left.onNext("Left: Lisbon")
      right.onNext("Right: Copenhagen")
      left.onNext("Left: London")
      left.onNext("Left: Madrid")
      right.onNext("Right: Vienna")
      disposable.dispose()
    }
    
    example(of: "switchLatest") {
      // 1
      let one = PublishSubject<String>()
      let two = PublishSubject<String>()
      let three = PublishSubject<String>()

      let source = PublishSubject<Observable<String>>()
      
      let observable = source.switchLatest()
      let disposable = observable.subscribe { print($0) }
      
      source.onNext(one)
      one.onNext("1 - 1")
      two.onNext("2 - 1")
      
      source.onNext(two)
      two.onNext("2 - 2")
      one.onNext("1 - 2")
      
      source.onNext(three)
      two.onNext("2 - 3")
      one.onNext("1 - 3")
      three.onNext("3 - 1")
      
      source.onNext(one)
      two.onNext("2 - 4")
      one.onNext("1 - 4")
      three.onNext("3 - 2")
      
      disposable.dispose()
    }
    
    example(of: "reduce") {
      let source = Observable.of(1, 3, 5, 7, 9)
      let observable = source.reduce(0, accumulator: +)
      observable.subscribe { print($0) }.dispose()
    }
    
    example(of: "scan") {
      let source = Observable.of(1, 3, 5, 7, 9)
      let observable = source.scan(0, accumulator: +)
      observable.subscribe { print($0) }.dispose()
    }
    
    example(of: "challenge - zip") {
      let source = Observable.of(1, 3, 5, 7, 9)
      let observable = Observable.zip(source, source.scan(0, accumulator: +), resultSelector: { ($0, $1) })
      
      observable.subscribe { print($0) }.dispose()
    }
    
    example(of: "challenge - zip2") {
      let source = Observable.of(1, 3, 5, 7, 9)
      let observable = source.scan((0,0), accumulator: { (result, value) in
        (value, result.1 + value)
      })
      
      observable.subscribe { print($0) }.dispose()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

