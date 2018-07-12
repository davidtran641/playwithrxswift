//
//  Support.swift
//  RxSwiftPlayground
//
//  Created by tranduc on 7/6/18.
//  Copyright © 2018 Scott Gardner. All rights reserved.
//

import UIKit

public func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}
