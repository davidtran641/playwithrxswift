//
//  WindowViewController.swift
//  RxSwiftPlayground
//
//  Created by tranduc on 7/21/18.
//  Copyright © 2018 Scott Gardner. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class WindowViewController: UIViewController {
  
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
    
    let elementsPerSecond = 3
    let windowTimeSpan: RxTimeInterval = 4
    let windowMaxCount = 10
    let sourceObservable = PublishSubject<String>()
    
    let sourceTimeline = TimelineView<String>.make()
    
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("window"),
      UILabel.make("Emitted elements (\(elementsPerSecond) per sec.):"),
      sourceTimeline,
      UILabel.make("Windowed observables (at most \(windowMaxCount) every \(windowTimeSpan) sec):")
      ])
    
    timer = DispatchSource.timer(interval: 1.0 /
      Double(elementsPerSecond), queue: .main) {
        sourceObservable.onNext("🐱")
      }
    
    _ = sourceObservable.subscribe(sourceTimeline)
    
    _ = sourceObservable
      .window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
      .flatMap { windowObservable -> Observable<(TimelineView<Int>, String?)> in
        let timeline = TimelineView<Int>.make()
        stack.insert(timeline, at: 4)
        stack.keep(atMost: 7)
        return windowObservable
          .map { value in (timeline, value) }
          .concat(Observable.just((timeline, nil)))
      }
      .subscribe(onNext: { tuple in
        let (timeline, value) = tuple
        if let value = value {
          timeline.add(.Next(value))
        } else {
          timeline.add(.Completed(true))
        }
      })
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    
    self.view.addSubview(hostView)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  
}

