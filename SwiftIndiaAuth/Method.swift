//
//  Method.swift
//  SwiftIndiaAuth
//
//  Created by Robin Malhotra on 22/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import Foundation

protocol DataConvertible {
	func toData() throws -> Data
}

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
	let body: DataConvertible

	init(method: Method,
		endpoint: Endpoint,
		headers: [String: String] = [:],
		body: DataConvertible) {
		self.method = method
		self.endpoint = endpoint
		self.headers = headers
		self.body = body
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

		request.httpBody = try body.toData()
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

	struct Login {
		static func tokenRequest(with baseURL: String, inputs: Inputs) -> Request {
			return Request(method: .get, endpoint: Auth.tokenEndpoint(with: baseURL), headers: [:], body: inputs)
		}

		struct Inputs: Codable, Equatable, DataConvertible {
			let username: String
			let password: String
			let clientID: String
			let clientSecret: String

			let grantType = "password"
			let scope = "offline_access"

			enum CodingKeys: String, CodingKey {
				case clientID = "clientId"
				case username
				case password
				case clientSecret
				case grantType
				case scope
			}

			func toData() throws -> Data {
				let encoder = JSONEncoder()
				encoder.keyEncodingStrategy = .convertToSnakeCase
				return try encoder.encode(self)
			}

		}
	}
}



