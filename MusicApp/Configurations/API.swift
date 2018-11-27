//
//  API.swift
//  MusicApp
//
//  Created by Hưng Đỗ on 6/13/17.
//  Copyright © 2017 HungDo. All rights reserved.
//

import RxSwift
import RxAlamofire
import NotificationBannerSwift

enum API {
    
    case categories(String)
    
    case home
    
    case playlists(category: String, page: Int)
    case playlist(id: String)
    
    case songs(category: String, page: Int)
    case song(id: String)
    
    case videos(category: String, page: Int)
    case video(id: String)
    
    case ranks(country: String)
    case rankTracks(country: String)
    
    case hotSingers
    case singers(category: String, page: Int)
    case singer(id: String)
    
    case topics
    case topic(id: String)
    
    case search(query: String)
    case searchSong(query: String)
    case searchPlaylist(query: String)
    case searchVideo(query: String)
    
}

extension API {
    
    var baseURL: String { return "https://music-api-kp.herokuapp.com" }
//    var baseURL: String { return "http://192.168.1.103:3000" }
    
    var url: String { return baseURL + path }
    
    var path: String {
        switch self {
        case let .categories(category):
            return "/categories/\(category)"
            
        case .home:
            return "/online/home"
            
        case let .playlists(category, page):
            return "/online/playlists/\(category)/\(page)"
        case let .playlist(id):
            return "/playlists/\(id)"
            
        case let .songs(category, page):
            return "/online/songs/\(category)/\(page)"
        case let .song(id):
            return "/songs/\(id)"
            
        case let .videos(category, page):
            return "/online/videos/\(category)/\(page)"
        case let .video(id):
            return "/videos/\(id)"
            
        case let .ranks(country):
            return "/ranks/\(country)"
        case let .rankTracks(country):
            return "/ranks/songs/\(country)"
            
        case .hotSingers:
            return "/online/singers"
        case let .singers(category, page):
            return "/online/singers/\(category)/\(page)"
        case let .singer(id):
            return "/singers/\(id)"
            
        case .topics:
            return "/topics"
        case let .topic(id):
            return "/topics/\(id)"
            
        case let .search(query):
            return "/search/\(query)"
        case let .searchSong(query):
            return "/search/songs/\(query)"
        case let .searchPlaylist(query):
            return "/search/playlists/\(query)"
        case let .searchVideo(query):
            return "/search/videos/\(query)"
        }
    }
    
}

extension API {
    
    func json() -> Observable<[String: Any]> {
        logger("fetch url \(self.url)")
        
        return RxAlamofire
            .json(.get, self.url)
            .catchError({ (error) -> Observable<Any> in
                logger(error.localizedDescription)
                LoadingActivityIndicatorView.stopLoading()
                MAMessage.show(title: "ERROR", subtitle: error.localizedDescription, stype: .danger)
                return .empty()
            })
            .map { json in
                guard let data = (json as? [String: Any])?["data"] as? [String: Any] else {
                    fatalError("Can not get the field 'data'")
                }
                return data
            }
            .retry(1)
    }
    
}

public func logger<T>(_ obj: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    let filename = ((file as NSString).lastPathComponent as NSString).deletingPathExtension
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'" // fullISO8601DateFormat
    print("\(formatter.string(from: Date())) | \(filename) | line: \(line) | \(obj)")
}

class MAMessage {
    static func show(title: String,
                     subtitle: String,
                     titleFont: UIFont? = UIFont.systemFont(ofSize: 13),
                     subtitleFont: UIFont? = UIFont.systemFont(ofSize: 12),
                     stype: BannerStyle) {
        
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: stype)
        banner.titleLabel?.font = titleFont
        banner.subtitleLabel?.font = subtitleFont
        
        banner.show()
    }
}
