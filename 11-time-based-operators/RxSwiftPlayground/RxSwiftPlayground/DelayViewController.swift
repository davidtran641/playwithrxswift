//
//  DelayViewController.swift
//  RxSwiftPlayground
//
//  Created by tranduc on 7/21/18.
//  Copyright © 2018 Scott Gardner. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class DelayViewController: UIViewController {
  // Support code -- DO NOT REMOVE
  class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
      let view = TimelineView(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
      view.setup()
      return view
    }
    public func on(_ event: Event<E>) {
      switch event {
      case .next(let value):
        add(.Next(String(describing: value)))
      case .completed:
        add(.Completed())
      case .error(_):
        add(.Error())
      }
    }
  }
  
  private var timer: DispatchSourceTimer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    edgesForExtendedLayout = []
    
    let elementsPerSecond = 1
    let delayInSeconds = 1.5
    
    let sourceObservable = PublishSubject<Int>()
    
    let sourceTimeline = TimelineView<Int>.make()
    let delayedTimeline = TimelineView<Int>.make()
    
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("delay"),
      UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
      sourceTimeline,
      UILabel.make("Delayed elements (with a \(delayInSeconds)s delay):"),
      delayedTimeline])
    
    var current = 1
    timer = DispatchSource.timer(interval: 1.0 / Double(elementsPerSecond), queue: .main) {
      sourceObservable.onNext(current)
      current = current + 1
    }
    
    _ = sourceObservable.subscribe(sourceTimeline)
    
    
    
    // Setup the delayed subscription
    // ADD CODE HERE
//    _ = sourceObservable
//      .delaySubscription(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
//      .subscribe(delayedTimeline)
    
//    _ = sourceObservable
//      .delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
//      .subscribe(delayedTimeline)
    
    _ = Observable<Int>
      .timer(3, scheduler: MainScheduler.instance)
      .flatMap { _ in
        sourceObservable.delay(RxTimeInterval(delayInSeconds), scheduler: MainScheduler.instance)
      }
      .subscribe(delayedTimeline)
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    self.view.addSubview(hostView)
    
  }
  
  
  
}

