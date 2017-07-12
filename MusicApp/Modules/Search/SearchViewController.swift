//
//  SearchViewController.swift
//  MusicApp
//
//  Created by Hưng Đỗ on 7/11/17.
//  Copyright © 2017 HungDo. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import RxSwift
import RxCocoa
import Action
import NSObject_Rx

class SearchViewController: SegmentedPagerTabStripViewController {
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var searchView: UIView!
    
    var searchController: UISearchController!
    
    var store: SearchStore!
    var action: SearchAction!
    
    var controllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.addSubview(searchController.searchBar)
        self.definesPresentationContext = true
        
        bindStore()
        bindAction()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0: action.searchStateChange.execute(.all)
        case 1: action.searchStateChange.execute(.song)
        case 2: action.searchStateChange.execute(.playlist)
        case 3: action.searchStateChange.execute(.video)
        default: break
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return controllers
    }

}

extension SearchViewController {
    
    func bindStore() {
        bindHistories()
        
        store.state.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .all where self?.segmentedControl.selectedSegmentIndex != 0:          self?.moveToViewController(at: 0, animated: true)
                case .song where self?.segmentedControl.selectedSegmentIndex != 1:         self?.moveToViewController(at: 1, animated: true)
                case .playlist where self?.segmentedControl.selectedSegmentIndex != 2:     self?.moveToViewController(at: 2, animated: true)
                case .video where self?.segmentedControl.selectedSegmentIndex != 3:        self?.moveToViewController(at: 3, animated: true)
                default: break
                }
            })
            .addDisposableTo(rx_disposeBag)
    }
    
    private func bindHistories() {
        store.histories.asObservable()
            .bind(to: historyTableView.rx.items(cellIdentifier: "SearchHistoryCell", cellType: SearchHistoryCell.self)) { _, content, cell in
                cell.content = content
            }
            .disposed(by: rx_disposeBag)
        
        let songs = store.songs.asObservable()
        let playlists = store.playlists.asObservable()
        let videos = store.videos.asObservable()
        
        Observable
            .combineLatest(songs, playlists, videos) { songs, playlists, videos in
                songs.count + playlists.count + videos.count
            }
            .map { count in count > 0 }
            .bind(to: historyView.rx.isHidden)
            .addDisposableTo(rx_disposeBag)
    }
    
}

extension SearchViewController {
    
    func bindAction() {
        searchController.searchBar.rx.text.orEmpty
            .filter { $0.characters.count > 2 }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.action.searchTextChange.execute(text)
            })
            .addDisposableTo(rx_disposeBag)
        
        searchController.searchBar.rx.text.orEmpty
            .filter { $0.characters.count <= 2 }
            .subscribe(onNext: { [weak self] text in
                self?.action.searchTextClear.execute(())
            })
            .addDisposableTo(rx_disposeBag)
    }
    
}
