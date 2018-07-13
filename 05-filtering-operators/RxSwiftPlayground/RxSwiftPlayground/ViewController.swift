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
    
    example(of: "ignoreElements") {
      let strikes = PublishSubject<String>()
      let disposeBag = DisposeBag()
      
      strikes
        .ignoreElements()
        .subscribe { _ in
          print("You're out")
        }
        .disposed(by: disposeBag)
      strikes.onNext("1")
      strikes.onNext("2")
      strikes.onNext("3")
      
      strikes.onCompleted()
    }
    
    example(of: "elementAt") {
      let strikes = PublishSubject<String>()
      let disposeBag = DisposeBag()
      
      strikes
        .elementAt(2)
        .subscribe { event in
          print(event)
        }
        .disposed(by: disposeBag)
      strikes.onNext("1")
      strikes.onNext("2")
      strikes.onNext("3")
      
      strikes.onCompleted()
    }
    
    example(of: "filter") {
      let disposeBag = DisposeBag()
      
      Observable.of(1,2,3,4,5,6)
        .filter { value in
          value % 2 == 0
        }.subscribe { event in
          print(event)
        }
        .disposed(by: disposeBag)
      
    }
    
    example(of: "skip") {
      let disposeBag = DisposeBag()
      Observable.of("A", "B", "C", "D", "E", "F")
        .skip(3)
        .subscribe{ event in
          print(event)
        }
        .disposed(by: disposeBag)
    }
    example(of: "skipWhile") {
      let disposeBag = DisposeBag()
      
      Observable.of(2,2,3,4,5,6)
        .skipWhile { value in
          value % 2 == 0
        }.subscribe { event in
          print(event)
        }
        .disposed(by: disposeBag)
    }
    
    example(of: "SkipUtil") {
      let disposeBag = DisposeBag()
      
      let subject = PublishSubject<String>()
      let trigger = PublishSubject<String>()
      
      subject
        .skipUntil(trigger)
        .subscribe { event in
          print(event)
        }
        .disposed(by: disposeBag)
      
      subject.onNext("A")
      subject.onNext("B")
      trigger.onNext("X")
      subject.onNext("C")
      subject.onNext("D")
      
    }
    
    example(of: "take") {
      let disposeBag = DisposeBag()
      Observable.of(1,2,3,4,5,6)
        .take(3)
        .subscribe { event in print(event)}
        .disposed(by: disposeBag)
    }
    
    example(of: "takeWhile") {
      let disposeBag = DisposeBag()
      Observable.of(2,2,4,4,6,6)
        .enumerated()
        .takeWhile { index, value in
          value % 2 == 0 && index < 3
        }.map{ $0.element }
        .subscribe { event in print(event)}
        .disposed(by: disposeBag)
    }
    
    example(of: "takeUtil") {
      let disposeBag = DisposeBag()
      
      let subject = PublishSubject<String>()
      let trigger = PublishSubject<String>()
      
      subject
        .takeUntil(trigger)
        .subscribe { event in
          print(event)
        }
        .disposed(by: disposeBag)
      
      subject.onNext("1")
      subject.onNext("2")
      trigger.onNext("X")
      subject.onNext("3")
      subject.onNext("4")
    }
    
    example(of: "distinctUntilChanged") {
      let disposeBag = DisposeBag()
      Observable.of("A", "A", "B", "B", "A")
        .distinctUntilChanged()
        .subscribe {event in print(event)}
        .disposed(by: disposeBag)
    }
    
    example(of: "distinctUntilChanged(_:)") {
      let disposeBag = DisposeBag()
      let formatter = NumberFormatter()
      formatter.numberStyle = .spellOut
      
      Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        .distinctUntilChanged { a,b in
          guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
            let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {
              return false
          }
          print(aWords, bWords)
          
          var containMatch = false
          for aWord in aWords {
            for bWord in bWords {
              if aWord == bWord {
                containMatch = true
                break
              }
            }
          }
          return containMatch
        }
        .subscribe {event in print(event)}
        .disposed(by: disposeBag)
    }
    
    example(of: "Challenge-phonenumber") {
      
      let disposeBag = DisposeBag()
      
      let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
      ]
      
      func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
          phone.startIndex,
          offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
          phone.startIndex,
          offsetBy: 7)
        )
        
        return phone
      }
      
      let input = PublishSubject<Int>()
      
      // Add your code here
      input
        .filter { (value) -> Bool in
          return value < 10 && value >= 0
        }
        .skipWhile { value -> Bool in
          return value <= 0
        }
        .take(10).toArray().subscribe(onNext: { numbers in
          let phone = phoneNumber(from: numbers)
          if let contact = contacts[phone] {
            print("Dialing \(contact) (\(phone))...")
          } else {
            print("Contact not found")
          }
        })
        .disposed(by: disposeBag)
      
      
      input.onNext(0)
      input.onNext(603)
      
      input.onNext(2)
      input.onNext(1)
      
      // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
      input.onNext(2)
      
      "5551212".characters.forEach {
        if let number = (Int("\($0)")) {
          input.onNext(number)
        }
      }
      
      input.onNext(9)
    }
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

