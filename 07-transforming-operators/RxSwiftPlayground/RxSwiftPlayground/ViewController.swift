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
    
    example(of: "toArray") {
      let disposeBag = DisposeBag()
      Observable.of("A", "B", "C")
        .toArray()
        .subscribe {
          print($0)
        }
        .disposed(by: disposeBag)
    }
    
    struct Student {
      var score: BehaviorSubject<Int>
    }
    
    example(of: "flatMap") {
      let disposeBag = DisposeBag()
      
      let ryan = Student(score: BehaviorSubject(value: 80))
      let charlotte = Student(score: BehaviorSubject(value: 90))
      
      let student = PublishSubject<Student>()
      
      student
        .flatMap {
          $0.score
        }
        .subscribe {
          print($0)
        }
        .disposed(by: disposeBag)
      
      student.onNext(ryan)
      ryan.score.onNext(85)
      student.onNext(charlotte)
      ryan.score.onNext(95)
      charlotte.score.onNext(100)
    }
    
    example(of: "flatMapLastest") {
      let disposeBag = DisposeBag()
      
      let ryan = Student(score: BehaviorSubject(value: 80))
      let charlotte = Student(score: BehaviorSubject(value: 90))
      
      let student = PublishSubject<Student>()
      
      student
        .flatMapLatest {
          $0.score
        }
        .subscribe {
          print($0)
        }
        .disposed(by: disposeBag)
      
      student.onNext(ryan)
      ryan.score.onNext(85)
      student.onNext(charlotte)
      ryan.score.onNext(95)
      charlotte.score.onNext(100)
    }
    
    example(of: "materialize and dematerialize") {
      enum MyError: Error {
        case anError
      }
      
      let disposeBag = DisposeBag()
      let ryan = Student(score: BehaviorSubject(value: 80))
      let charlotte = Student(score: BehaviorSubject(value: 100))
      
      let student = BehaviorSubject(value: ryan)
      let studentScore = student.flatMapLatest {$0.score.materialize()}
      studentScore
        .filter {
          guard $0.error == nil else {
            return false
          }
          return true
        }
        .dematerialize()
        .subscribe(onNext: {
          print($0)
        })
        .disposed(by: disposeBag)
      
      ryan.score.onNext(85)
      ryan.score.onError(MyError.anError)
      ryan.score.onNext(90)
      
      student.onNext(charlotte)
      
    }
    
    example(of: "Challenge-phonenumber") {
      let disposeBag = DisposeBag()
      
      let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
      ]
      
      let convert: (String) -> UInt? = { value in
        if let number = UInt(value),
          number < 10 {
          return number
        }
        
        let keyMap: [String: UInt] = [
          "abc": 2, "def": 3, "ghi": 4,
          "jkl": 5, "mno": 6, "pqrs": 7,
          "tuv": 8, "wxyz": 9
        ]
        
        let converted = keyMap
          .filter { $0.key.contains(value.lowercased()) }
          .map { $0.value }
          .first
        
        return converted
      }
      
      let format: ([UInt]) -> String = {
        var phone = $0.map(String.init).joined()
        
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
      
      let dial: (String) -> String = {
        if let contact = contacts[$0] {
          return "Dialing \(contact) (\($0))..."
        } else {
          return "Contact not found"
        }
      }
      
      let input = Variable<String>("")
      
      // Add your code here
      input.asObservable()
        .map {
          convert($0)
        }
        .filter { $0 != nil }
        .map { value -> UInt in
          return value!
        }
        .filter { value -> Bool in
          return value < 10
        }
        .skipWhile { value -> Bool in
          return value <= 0
        }
        .take(10).toArray().subscribe(onNext: { numbers in
          let phone = format(numbers)
          print(dial(phone))
        })
        .disposed(by: disposeBag)
      
      input.value = ""
      input.value = "0"
      input.value = "408"
      
      input.value = "6"
      input.value = ""
      input.value = "0"
      input.value = "3"
      
      "JKL1A1B".forEach {
        input.value = "\($0)"
      }
      
      input.value = "9"
    }
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

