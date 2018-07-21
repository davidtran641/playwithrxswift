//
//  ReplayViewController.swift
//  RxSwiftPlayground
//
//  Created by tranduc on 7/20/18.
//  Copyright © 2018 Scott Gardner. All rights reserved.
//

import UIKit
import RxSwift

class ReplayViewController: UIViewController {
  
  // Support code -- DO NOT REMOVE
  class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
    static func make() -> TimelineView<E> {
      return TimelineView(width: 320, height: 100)
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
    
    let elementsPerSecond = 1
    let maxElements = 10
    let replayedElements = 2
    let replayDelay: TimeInterval = 3
    
//    let sourceObservable = Observable<Int>.create { observer in
//      var value = 1
//      let timer = DispatchSource.timer(interval: 1.0 /
//        Double(elementsPerSecond), queue: .main) {
//          if value <= maxElements {
//            observer.onNext(value)
//            value = value + 1
//          }
//      }
//      return Disposables.create {
//        timer.suspend()
//      }
//    }
////    .replay(replayedElements)
//    .replayAll()
    
    let sourceObservable = Observable<Int>
      .interval(RxTimeInterval(1.0 / Double(elementsPerSecond)), scheduler: MainScheduler.instance)
      .replay(replayedElements)
    
    let sourceTimeline = TimelineView<Int>.make()
    let replayedTimeline = TimelineView<Int>.make()
    
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("replay"),
      UILabel.make("Emit \(elementsPerSecond) per second:"),
      sourceTimeline,
      UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
      replayedTimeline]
    )
    
    _ = sourceObservable.subscribe(sourceTimeline)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
      _ = sourceObservable.subscribe(replayedTimeline)
    }
    
    _ = sourceObservable.connect()
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    self.view.addSubview(hostView)
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}

