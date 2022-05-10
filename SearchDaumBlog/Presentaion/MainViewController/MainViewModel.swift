//
//  MainViewModel.swift
//  SearchDaumBlog
//
//  Created by 신새별 on 2022/04/22.
//

import RxSwift
import RxCocoa
import Foundation

struct MainViewModel {
  let disposeBag = DisposeBag()
  
  let blogListViewModel = BlogListViewModel()
  let searchBarViewModel = SearchBarViewModel()
  
  let alertActionTapped = PublishRelay<MainViewController.AlertAction>()
  let shouldPresentAlert: Signal<MainViewController.Alert>
  init(model: MainModel = MainModel()) {
    let blogResult = searchBarViewModel.shouldLoadResult
      .flatMapLatest(model.searchBlog)
      .share()
    
    let blogValue = blogResult
      .compactMap(model.getBlogValue)
    
    let blogError = blogResult
      .compactMap(model.getBlogError)
    
    // 네트워크를 통해 가져온 값을 cellData로 변환
    let cellData = blogValue
      .map(model.getBlogListCellData)
      
    //FilterView를 선택했을 때 나오는 alertsheet를 선택했을 때 type
    let sortedType = alertActionTapped
      .filter { e in
        switch e {
        case .title, .datetime:
          return true
        default :
          return false
        }
      }
      .startWith(.title)
    
    //MainViewController -> ListView
    Observable
      .combineLatest(sortedType, cellData, resultSelector: model.sort)
      .bind(to: blogListViewModel.blogCellData)
      .disposed(by: disposeBag)
    let alertSheetForSorting = blogListViewModel.filterViewModel.sortButtonTapped
      .map { _ -> MainViewController.Alert in
        return (title: nil, message: nil, action: [.title, .datetime, .cancel], style: .actionSheet)
      }
    
    let alertForErrorMessage = blogError
      .map { message -> MainViewController.Alert in
        return (
          title: "앗!",
          message: "예상치 못한 오류가 발생했습니다. 잠시후 다시 시도해주세요. \(message)",
          action : [.confirm],
          style : .alert
        )
      }
    self.shouldPresentAlert = Observable
      .merge(
        alertSheetForSorting,
        alertForErrorMessage
      )
      .asSignal(onErrorSignalWith: .empty())
  }
}
