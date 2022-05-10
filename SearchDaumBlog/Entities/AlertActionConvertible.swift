//
//  AlertActionConvertible.swift
//  SearchDaumBlog
//
//  Created by 신새별 on 2022/04/21.
//

import Foundation
import UIKit

protocol AlertActionConvertible {
  var title: String { get }
  var style: UIAlertAction.Style { get }
  
}
