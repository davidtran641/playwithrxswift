//
//  TimeoutViewController.swift
//  RxSwiftPlayground
//
//  Created by tranduc on 7/21/18.
//  Copyright © 2018 Scott Gardner. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TimeoutViewController: UIViewController {
  
  class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
      return TimelineView(width: 400, height: 100)
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    edgesForExtendedLayout = []
    
    let button = UIButton(type: .system)
    button.setTitle("Press me now!", for: .normal)
    button.sizeToFit()
    
    let tapsTimeline = TimelineView<String>.make()
    let stack = UIStackView.makeVertical([
      button,
      UILabel.make("Taps on button above"),
      tapsTimeline])
    
    let tapObservable = button
      .rx.tap
      .map { _ in "•"}
    
//    let _ = tapObservable
//      .timeout(5, scheduler: MainScheduler.instance)
//      .subscribe(tapsTimeline)
    
    let _ = tapObservable
      .timeout(5, other: Observable.just("X"), scheduler: MainScheduler.instance)
      .subscribe(tapsTimeline)
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    self.view.addSubview(hostView)
  }
  
}

