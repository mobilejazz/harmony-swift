//
//  NetworkAssembly.swift
//  SwiftCore
//
//  Created by Joan Martin on 31/10/2017.
//  Copyright © 2017 Mobile Jazz. All rights reserved.
//

import UIKit

import Swinject
import Alamofire
import MJSwiftCore

class NetworkAssembly: Assembly {
    
    struct Names {
        static let networkRepository = "network"
    }
    
    func assemble(container: Container) {
        
        // OAuth
//        container.register(OAuth2.self) { _ in
//            let oauth2 = OAuth2(settings: [
//                "client_id": "my_swift_app",
//                "client_secret": "C7447242",
//                "authorize_uri": "https://github.com/login/oauth/authorize",
//                "token_uri": "https://github.com/login/oauth/access_token",   // code grant only
//                "redirect_uris": ["myapp://oauth/callback"],   // register your own "myapp" scheme in Info.plist
//                "scope": "user repo:status",
//                "secret_in_body": true,    // Github needs this
//                "keychain": false,         // if you DON'T want keychain integration
//                ] as OAuth2JSON)
//
//            // Debug
//            oauth2.logger = OAuth2DebugLogger(.trace)
//            return oauth2
//        }.inObjectScope(.container)
//        container.register(OAuth2RetryHandler.self) { r in OAuth2RetryHandler(oauth2:r.resolve(OAuth2.self)!) }.inObjectScope(.container)
        
        // Alamofire Request Retrier and Adapter
        container.register(RequestAdapter.self) { r in MultiRequestAdapter([BaseURLRequestAdapter("http://demo5266963.mockable.io/api")]) }
        container.register(RequestRetrier.self) { r in MultiRequestRetrier([UnauthorizedStatusCodeRetrier()]) }
        
        // Alamofire Session Manager
        container.register(SessionManager.self) { r in
            let sessionManager = SessionManager()
            sessionManager.adapter = r.resolve(RequestAdapter.self)
            sessionManager.retrier = r.resolve(RequestRetrier.self)
            return sessionManager
        }
        
        // Network Clients
        container.register(Repository<ItemEntity>.self, name: Names.networkRepository) { r in ItemNetworkService(r.resolve(SessionManager.self)!) }
    }
}
