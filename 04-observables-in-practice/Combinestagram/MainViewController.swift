/*
 * Copyright (c) 2016-present Razeware LLC
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

import UIKit
import RxSwift

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!
  
  private let bag = DisposeBag()
  private let images = Variable<[UIImage]>([])

  override func viewDidLoad() {
    super.viewDidLoad()
    
    images.asObservable().subscribe(onNext: { [weak self] photos in
      guard let imagePreview = self?.imagePreview else {return}
      imagePreview.image = UIImage.collage(images: photos, size: imagePreview.frame.size)
    }).disposed(by: bag)
    
    images.asObservable().subscribe(onNext: {[weak self] photos in
      self?.updateUI(photos: photos)
    }).disposed(by: bag)
  }
  
  @IBAction func actionClear() {
    images.value = []
  }

  @IBAction func actionSave() {
    guard let image = imagePreview.image else {return}
    PhotoWriter.save(image)
      .subscribe(onSuccess: { [weak self](id) in
        self?.showMessage("Saved with id: \(id)")
        self?.actionClear()
      }, onError: {[weak self] (error) in
        self?.showMessage("Error", description: error.localizedDescription)
      })
      .disposed(by: bag)
    
  }

  @IBAction func actionAdd() {
//    images.value.append(UIImage(named: "IMG_1907")!)
    let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
    photosViewController.selectedPhotos.subscribe(onNext: { [weak self] (image) in
      guard let images = self?.images else {return}
      images.value.append(image)
    }, onDisposed: {
      print("Completed photo selection")
    }).disposed(by: bag)
    
    navigationController?.pushViewController(photosViewController, animated: true)
    
  }
  
  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }

  func showMessage(_ title: String, description: String? = nil) {
    self.alert(title, description: description).subscribe().disposed(by: bag)
  }
}


