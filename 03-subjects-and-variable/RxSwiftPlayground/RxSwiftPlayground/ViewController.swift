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
    
    example(of: "PublishSubject") {
      let disposeBag = DisposeBag()
      let subject = PublishSubject<String>()
      subject.onNext("Is anyone listening?")
      
      let subscriptionOne = subject.subscribe(onNext: { string in
        print(string)
      })
      subscriptionOne.disposed(by: disposeBag)
      
      subject.on(.next("1"))
      subject.onNext("2")
      
      let subscriptionTwo = subject.subscribe({ (event) in
        print("2) ", event.element ?? event)
      })
      
      subject.onNext("3")
      
      subscriptionOne.dispose()
      subject.onNext("4")
      
      subject.onCompleted()
      subject.onNext("5")
      
      subscriptionTwo.dispose()
      
      subject.subscribe({ (event) in
        print("3) ", event.element ?? event)
      }).disposed(by: disposeBag)
      
      subject.onNext("?")
    }
    
    enum MyError: Error {
      case anError
    }
    
    func printLable<T: CustomStringConvertible>(lable: String, event: Event<T>) {
      print(lable, event.element ?? event.error ?? event)
    }
    
    example(of: "BehaviorSubject") {
      let subject = BehaviorSubject(value: "Initial Value")
      let disposeBag = DisposeBag()
      
      subject.subscribe {
        printLable(lable: "1)", event: $0)
      }.disposed(by: disposeBag)
      
      subject.onNext("X")
      
      subject.onError(MyError.anError)
      
      subject.subscribe {
        printLable(lable: "2)", event: $0)
      }.disposed(by: disposeBag)
      
    }
    
    example(of: "ReplaySubject") {
      let subject = ReplaySubject<String>.create(bufferSize: 2)
      let disposeBag = DisposeBag()
      
      subject.onNext("1")
      subject.onNext("2")
      subject.onNext("3")
      
      subject
        .subscribe {
          printLable(lable: "1)", event: $0)
        }.disposed(by: disposeBag)
      
      subject
        .subscribe {
          printLable(lable: "2)", event: $0)
        }.disposed(by: disposeBag)
      
      subject.onNext("4")
      subject.onError(MyError.anError)
      
      subject
        .subscribe {
          printLable(lable: "3)", event: $0)
        }.disposed(by: disposeBag)
    }
    
    example(of: "Variable") {
      let variable = Variable("Initial Value")
      let disposeBag = DisposeBag()
      
      variable.value = "New initial value"
      
      variable.asObservable()
        .subscribe {
          printLable(lable: "1)", event: $0)
        }
        .disposed(by: disposeBag)
      
      variable.value = "1"
      
      variable.asObservable()
        .subscribe {
          printLable(lable: "2)", event: $0)
        }
        .disposed(by: disposeBag)
      
      variable.value = "2"
    }
    
    example(of: "challenge-blackjack-card") {
      let disposeBag = DisposeBag()
      
      let dealtHand = PublishSubject<[(String, Int)]>()
      
      func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining: UInt32 = 52
        var hand = [(String, Int)]()
        
        for _ in 0..<cardCount {
          let randomIndex = Int(arc4random_uniform(cardsRemaining))
          hand.append(deck[randomIndex])
          deck.remove(at: randomIndex)
          cardsRemaining -= 1
        }
        
        if points(for: hand) > 21 {
          dealtHand.onError(HandError.busted)
        } else {
          dealtHand.onNext(hand)
        }
        
      }
      
      // Add subscription to dealtHand here
      dealtHand.subscribe(onNext: { (hand) in
        print(cardString(for: hand), points(for: hand))
      }, onError: { (error) in
        print(error)
      }).disposed(by: disposeBag)
      
    }
    
    example(of: "challenge-user-session") {
      
      enum UserSession {
        
        case loggedIn, loggedOut
      }
      
      enum LoginError: Error {
        
        case invalidCredentials
      }
      
      let disposeBag = DisposeBag()
      
      // Create userSession Variable of type UserSession with initial value of .loggedOut
      let userSession = Variable(UserSession.loggedOut)
      
      // Subscribe to receive next events from userSession
      userSession.asObservable().subscribe(onNext: { (value) in
        print("UserSession", value)
      }).disposed(by: disposeBag)
      
      func logInWith(username: String, password: String, completion: (Error?) -> Void) {
        guard username == "johnny@appleseed.com",
          password == "appleseed"
          else {
            completion(LoginError.invalidCredentials)
            return
        }
        
        userSession.value = .loggedIn
        
      }
      
      func logOut() {
        userSession.value = .loggedOut
        
      }
      
      func performActionRequiringLoggedInUser(_ action: () -> Void) {
        // Ensure that userSession is loggedIn and then execute action()
        guard userSession.value == .loggedIn else {
          print("You can't do that")
          return
        }
        action()
      }
      
      for i in 1...2 {
        let password = i % 2 == 0 ? "appleseed" : "password"
        
        logInWith(username: "johnny@appleseed.com", password: password) { error in
          guard error == nil else {
            print(error!)
            return
          }
          
          print("User logged in.")
        }
        
        performActionRequiringLoggedInUser {
          print("Successfully did something only a logged in user can do.")
        }
      }
    }
    
  }
  
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

