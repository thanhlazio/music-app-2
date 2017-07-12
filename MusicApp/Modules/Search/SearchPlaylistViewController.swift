//
//  SearchPlaylistViewController.swift
//  MusicApp
//
//  Created by Hưng Đỗ on 7/11/17.
//  Copyright © 2017 HungDo. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SearchPlaylistViewController: UIViewController {
    
    var store: SearchStore!
    var action: SearchAction!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindStore()
        bindAction()
    }

}

extension SearchPlaylistViewController: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "Playlist"
    }
    
}

extension SearchPlaylistViewController {
    
    func bindStore() {
        
    }
    
}

extension SearchPlaylistViewController {
    
    func bindAction() {
        
    }
    
}
