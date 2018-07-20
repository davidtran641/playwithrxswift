/*
 * Copyright (c) 2016 Razeware LLC
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
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet var tableView: UITableView!
  
  private let categories = Variable<[EOCategory]>([])
  private let disposeBag = DisposeBag()
  
  private let download = DownloadView()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(download)
    view.layoutIfNeeded()
    print(download.frame)

    categories
      .asObservable()
      .subscribe(onNext: { [weak self] _ in
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      })
    
    startDownload()
  }

  func startDownload() {
    download.progress.progress = 0.0
    download.label.text = "Download: 0%"
    
    let eoCategories = EONET.categories
    let downloadEvent = eoCategories.flatMap { categories in
      return Observable.from(categories.map { category in
        EONET.events(forLast: 360, category: category)
      })
    }
    .merge(maxConcurrent: 2)
    
    
    let updatedCategories = eoCategories
      .flatMap { categories in
        downloadEvent.scan((0,categories)) { (updated, events) in
          return (updated.0 + 1, updated.1.map { category in
            let eventsForCat = EONET.filteredEvents(events: events, forCategory: category)
            if !eventsForCat.isEmpty {
              var cat = category
              cat.events = cat.events + eventsForCat
              return cat
            }
            return category
          })
        }
      }
      .do(onNext: {[weak self] updated in
        DispatchQueue.main.async {
          let progress = Float(updated.0) / Float(updated.1.count)
          self?.download.progress.progress = progress
          let percent = Int(progress * 100.0)
          self?.download.label.text = "Download: \(percent)%"
        }
      })
      .do(onError: { [weak self] _ in
          self?.hideLoading()
        }, onCompleted: { [weak self] in
          self?.hideLoading()
      })
    
    eoCategories
      .concat(updatedCategories.map { $0.1 })
      .bind(to: categories)
      .disposed(by: disposeBag)
    
    configIndicator()
  }
  
  private func configIndicator() {
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
    indicator.startAnimating()
  }
  
  private func hideLoading() {
    DispatchQueue.main.async {
      self.navigationItem.setRightBarButton(nil, animated: true)
    }
  }
  
  // MARK: UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let category = categories.value[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
    cell.textLabel?.text = "\(category.name) (\(category.events.count))"
    cell.accessoryType = category.events.count > 0 ? .disclosureIndicator : .none
    cell.detailTextLabel?.text = category.description
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categories.value[indexPath.row]
    if !category.events.isEmpty {
      let vc = storyboard!.instantiateViewController(withIdentifier: "events") as! EventsViewController
      vc.title = category.name
      vc.events.value = category.events
      navigationController?.pushViewController(vc, animated: true)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

