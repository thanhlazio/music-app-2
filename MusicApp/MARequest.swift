//
//  MARequest.swift
//  MusicApp
//
//  Created by Thành Lã on 11/23/18.
//  Copyright © 2018 HungDo. All rights reserved.
//

import Foundation
import Alamofire

protocol MARequest {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
    var headers: [String: Any] { get }
    var parameters: [String: Any]? { get }
    var requireAccessToken: Bool { get }
}

extension MARequest {
    var headers: [String: Any] {
        return [
            "Content-Type":"application/json; charset=utf-8",
            "Accept":"application/json"
        ]
    }
    
    var additionHttpHeaderFields: [String: String] {
        return [:]
    }
}
