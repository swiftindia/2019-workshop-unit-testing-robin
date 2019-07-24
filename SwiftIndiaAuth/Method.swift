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

		func string() -> String {
			switch self {
			case .get:
				return "GET"
			}
		}
	}

	let method: Method
	let endpoint: Endpoint
	let headers: [String: String]

	init(method: Method,
		endpoint: Endpoint,
		headers: [String: String] = [:]) {
		self.method = method
		self.endpoint = endpoint
		self.headers = headers
	}

	func toURLRequest() throws -> URLRequest {
		guard let url = endpoint.url else {
			throw Endpoint.EndpointError.invalidURL(endpoint)
		}
		var request = URLRequest(url: url)
		request.httpMethod = self.method.string()
		for (key, value) in headers {
			request.setValue(value, forHTTPHeaderField: key)
		}
		return request
	}
}

public struct Endpoint: Equatable {
	let path: String
	let baseURL: String

	enum EndpointError: Error {
		case invalidURL(Endpoint)
	}

	public var url: URL? {
		var components = URLComponents()
		/// We can have our schemes coming in externally as well
		components.scheme = "https"
		components.host = baseURL
		components.path = path
		return components.url
	}
}

enum Auth {
	static func tokenEndpoint(with baseURL: String) -> Endpoint {
		return Endpoint(path: "/oauth/token", baseURL: baseURL)
	}

	static func tokenRequest(with baseURL: String) -> Request {
		return Request(method: .get, endpoint: Auth.tokenEndpoint(with: baseURL), headers: [:])
	}
}



