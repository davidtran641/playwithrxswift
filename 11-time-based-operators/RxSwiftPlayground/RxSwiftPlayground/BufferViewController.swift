//
//  BufferViewController.swift
//  RxSwiftPlayground
//
//  Created by tranduc on 7/20/18.
//  Copyright © 2018 Scott Gardner. All rights reserved.
//

import UIKit
import RxSwift

class BufferViewController: UIViewController {
  
  var timer: DispatchSourceTimer?
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    edgesForExtendedLayout = []
    
    let bufferTimeSpan: RxTimeInterval = 4
    let bufferMaxCount = 2
    
    let sourceObservable = PublishSubject<String>()
    
    let sourceTimeline = TimelineView<String>.make()
    let bufferedTimeline = TimelineView<Int>.make()
    let stack = UIStackView.makeVertical([
      UILabel.makeTitle("buffer"),
      UILabel.make("Emitted elements:"),
      sourceTimeline,
      UILabel.make("Buffered elements (at most \(bufferMaxCount) every (bufferTimeSpan) seconds):"),
      bufferedTimeline])
    
    _ = sourceObservable.subscribe(sourceTimeline)
    
    sourceObservable.buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
      .map { $0.count }
      .subscribe(bufferedTimeline)
    
    let hostView = setupHostView()
    hostView.addSubview(stack)
    self.view.addSubview(hostView)
    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//
//      sourceObservable.onNext("🐱")
//      sourceObservable.onNext("🐱")
//      sourceObservable.onNext("🐱")
//    }
    
    let elementsPerSecond = 0.7
    timer = DispatchSource.timer(interval: 1.0 /
      Double(elementsPerSecond), queue: .main) {
        
        sourceObservable.onNext("🐱")
      }
    
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

