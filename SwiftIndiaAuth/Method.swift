//
//  Method.swift
//  SwiftIndiaAuth
//
//  Created by Robin Malhotra on 22/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import Foundation

struct Request {

	enum Method {
		case get
		case post

		func string() -> String {
			switch self {
			case .get:
				return "GET"
			case .post:
				return "POST"
			}
		}
	}

	let method: Method

	init(method: Method) {
		self.method = method
	}

	func toURLRequest() throws -> URLRequest {
		var request = URLRequest(url: URL(string: "https://google.com")!)
		request.httpMethod = self.method.string()
		return request
	}
}
