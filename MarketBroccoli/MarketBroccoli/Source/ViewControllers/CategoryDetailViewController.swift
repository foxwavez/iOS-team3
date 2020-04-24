//
//  CategoryDetailViewController.swift
//  MarketBroccoli
//
//  Created by Hailey Lee on 2020/04/13.
//  Copyright © 2020 Team3. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class CategoryDetailViewController: UIViewController {
  // MARK: - Properties
  private var customMenuBar = CategoryDetailHeaderView()
  let customMenuBarheigt: CGFloat = 50
  private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(
    frame: .init(
      x: 0, y: customMenuBarheigt,
      width: view.frame.width,
      height: view.frame.height - customMenuBarheigt), // .zero로 했을 때 안나오는 문제 해결 할 것
    collectionViewLayout: collectionViewFlowLayout)
    .then {
      $0.isPagingEnabled = true
      $0.register(cell: CategoryDetailCollectionViewCell.self)
      $0.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
  }
  var categoryDetailNavigationTitle = ""
  var selectedCellTitle = ""
  var categoryId: Int? {
    didSet {
      // categoryData[section].count
      print("didSet categoryID")
    }
  }
  private let selectedCategory = CategorySelected()
  private var page: Int = 0 {
    didSet {
//      let width = self.collectionView
//        .cellForItem(at: IndexPath(item: 0, section: 0))?
//        .subviews
//        .compactMap { $0 as? UICollectionView }
//        .compactMap { $0.collectionViewLayout as? UICollectionViewFlowLayout }
//        .first?
//        .itemSize
//        .width
    }
  }
  var s캐스팅을위한연습: CGFloat = 0 {
    didSet {
      let cell = self.collectionView
        .visibleCells.first
//        .cellForItem(at: IndexPath(item: 0, section: 0))
      let subviews = cell?.subviews
      let cv = subviews?.filter { $0 is UICollectionView }.first as! UICollectionView
      let flowLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout
      let width = flowLayout?.itemSize.width
    }
  }
  
  enum UI {
    static let inset: CGFloat = 14
    static let spacing: CGFloat = 14
  }
  
  // MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupLayout()
    setupNavigtion()
  }
  
  
  var itemWidth: CGFloat = 0
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.itemWidth = self.collectionView
      .visibleCells.first?
//      .cellForItem(at: IndexPath(item: 0, section: 0))?
      .subviews
      .compactMap { $0 as? UICollectionView }
      .compactMap { $0.collectionViewLayout as? UICollectionViewFlowLayout }
      .first?
      .itemSize
      .width ?? 0
    print(itemWidth, "제발 나와줘")
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews() // 타이밍이 컬렉션뷰 레이아웃이 잡히고
    // 그 다음에 플로우레이아웃이 잡혀야
    setupFlowLayout()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.setupBroccoliNavigationBar(title: "카테고리")
    self.addNavigationBarCartButton()
  }
  // MARK: - Setup Attribute
  private func setupUI() {
    view.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
    collectionView.dataSource = self
    collectionView.delegate = self
    guard let categoryId = categoryId else { return }
    customMenuBar.categories(categories: categoryData[categoryId - 1].row)
    [collectionView, customMenuBar] .forEach {
      view.addSubview($0)
    }
  }
  private func setupLayout() {
    let guide = view.safeAreaLayoutGuide
    collectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(guide.snp.bottom)
    }
    customMenuBar.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(guide)
      $0.height.equalTo(customMenuBarheigt)
      $0.bottom.equalTo(collectionView.snp.top)
    }
    [selectedCategory].forEach {
      customMenuBar.addSubview($0)
    }
    if let item = customMenuBar.subviews.first as? UILabel {
      item.textColor = .kurlyMainPurple
      selectedCategory.snp.makeConstraints {
        $0.top.equalTo(item.snp.bottom)
        $0.leading.trailing.width.equalTo(item)
        $0.height.equalTo(2)
      }
    }
  }
  private func setupNavigtion() {
    self.addSubNavigationBarCartButton()
    self.setupSubNavigationBar(title: categoryDetailNavigationTitle)
  }
  private func setupFlowLayout() {
    let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    collectionViewFlowLayout.sectionInset = insets
    collectionViewFlowLayout.minimumLineSpacing = 0
    collectionViewFlowLayout.minimumInteritemSpacing = 0
    collectionViewFlowLayout.itemSize = CGSize(
      width: collectionView.frame.width,
      height: collectionView.frame.height
    )
    collectionViewFlowLayout.scrollDirection = .horizontal
  }
}
// MARK: - UIScrollViewDelegate
//extension CategoryDetailViewController: UIScrollViewDelegate {
//  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//    if scrollView == collectionView {
//      let cellWidth = itemWidth * 2 + (UI.inset + UI.spacing * 2)
//      var page = round(collectionView.contentOffset.x / cellWidth)
//      var isRight = true
//      if velocity.x > 0 {
//        page += 1
//        isRight = true
//      }
//      if velocity.x < 0 {
//        page -= 1
//        isRight = false
//      }
//      page = max(page, 0)
//      print(page, "페이지는/")
//      targetContentOffset.pointee.x = page * cellWidth
////      categoryMoved(Int(page), direction: isRight)
//    }
//    print(collectionView.contentOffset.x)
//  }
//}
extension CategoryDetailViewController: UICollectionViewDelegate {
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView == collectionView {
      let cellWidth = itemWidth * 2 + (UI.inset + UI.spacing * 2)
      var page = round(collectionView.contentOffset.x / cellWidth)
      var isRight = true
      if velocity.x > 0 {
        page += 1
        isRight = true
      }
      if velocity.x < 0 {
        page -= 1
        isRight = false
      }
      page = max(page, 0)
      print(page, "페이지는!!!!!!!")
      print(itemWidth, "아이템 사이즌!!!!!!!!!")
      targetContentOffset.pointee.x = page * cellWidth
      //      categoryMoved(Int(page), direction: isRight)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension CategoryDetailViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let categoryId = categoryId else { return 0 }
    return categoryData[categoryId - 1].row.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let categoryId = categoryId else { return UICollectionViewCell() }
    let cell = collectionView.dequeue(CategoryDetailCollectionViewCell.self, indexPath: indexPath)
    print("가로 - 몇 번째?", indexPath.section, indexPath.row)
    cell.configure(id: categoryId)
    return cell
  }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
  }
}

// MARK: - ACTIONS
extension CategoryDetailViewController {
  
}
