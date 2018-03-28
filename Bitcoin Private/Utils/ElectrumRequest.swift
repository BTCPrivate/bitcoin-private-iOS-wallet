//
//  ElectrumRequest.swift
//  Bitcoin Private
//
//  Created by Satraj Bambra on 2018-03-24.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import JSONRPCKit

struct ElectrumRequest: JSONRPCKit.Request {
    typealias Response = String
    
    let type: String
    let params: String
    
    var method: String {
        return type
    }
    
    var parameters: Any? {
        return [params]
    }
    
    func response(from resultObject: Any) throws -> Response {
        if let response = resultObject as? Response {
            return response
        }
        return ""
    }
}
