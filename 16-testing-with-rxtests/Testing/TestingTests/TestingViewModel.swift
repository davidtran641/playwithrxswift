/*
 * Copyright (c) 2014-2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Testing

class TestingViewModel : XCTestCase {

  var viewModel: ViewModel!
  var scheduler: ConcurrentDispatchQueueScheduler!

  override func setUp() {
    super.setUp()
    viewModel = ViewModel()
    scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    
  }
  
  func testColorIsRedWhenHexStringIsFF0000_async() {
    let disposeBag = DisposeBag()
    let expect = expectation(description: #function)
    var result: UIColor!
    
    viewModel.color.asObservable()
      .skip(1)
      .subscribe(onNext: {
        result = $0
        expect.fulfill()
      })
      .disposed(by: disposeBag)
    
    viewModel.hexString.value = "#ff0000"
    waitForExpectations(timeout: 1) { error in
      if let error = error {
        XCTFail(error.localizedDescription)
        return
      }
      XCTAssertEqual(.red, result)
    }
  }
  
  func testColorIsRedWhenHexStringIsFF0000() {
    let colorObservable = viewModel.color.asObservable().subscribeOn(scheduler)
    viewModel.hexString.value = "#ff0000"
    let result = try! colorObservable.toBlocking(timeout: 1).first()
    XCTAssertEqual(result, .red)
  }
  
  func testRgbIs010WhenHexStringIs00FF00() {
    let rgbObservable = viewModel.rgb.asObservable().subscribeOn(scheduler)
    viewModel.hexString.value = "#00ff00"
    let result = try! rgbObservable.toBlocking(timeout: 1).first()!
    
    XCTAssertEqual(0 * 255, result.0)
    XCTAssertEqual(1 * 255, result.1)
    XCTAssertEqual(0 * 255, result.2)
  }
  
  func testColorNameIsRayWenderlichGreenWhenHexStringIs006636() {
    let colorNameObservable = viewModel.colorName.asObservable().subscribeOn(scheduler)
    viewModel.hexString.value = "#006636"
    let result = try! colorNameObservable.toBlocking(timeout: 1).first()!
    XCTAssertEqual("rayWenderlichGreen", result)
  }
}
