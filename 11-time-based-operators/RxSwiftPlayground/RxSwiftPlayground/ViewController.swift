//
//  ViewController.swift
//  RxSwiftPlayground
//
//  Created by Scott Gardner on 10/15/17.
//  Copyright © 2017 Scott Gardner. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
  let rows = ["Replay", "Buffer", "Window", "Delay", "Timeout"]
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rows.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    cell.textLabel?.text = rows[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    case 0:
      let vc = ReplayViewController()
      navigationController?.pushViewController(vc, animated: true)
      break
    case 1:
      let vc = BufferViewController()
      navigationController?.pushViewController(vc, animated: true)
      break
    case 2:
      let vc = WindowViewController()
      navigationController?.pushViewController(vc, animated: true)
      break
    case 3:
      let vc = DelayViewController()
      navigationController?.pushViewController(vc, animated: true)
      break
    case 4:
      let vc = TimeoutViewController()
      navigationController?.pushViewController(vc, animated: true)
      break
    default:
      break
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
