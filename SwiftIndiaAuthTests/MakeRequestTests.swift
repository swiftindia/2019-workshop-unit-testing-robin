//
//  MakeRequestTests.swift
//  SwiftIndiaAuthTests
//
//  Created by Robin Malhotra on 22/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import XCTest
import Fakery
@testable import SwiftIndiaAuth

class MakeRequestTests: XCTestCase {

	let fakery = Faker()
	let validBase = "swiftindiaauth.herokuapp.com"
	lazy var validEndpoint = Auth.tokenEndpoint(with: self.validBase)


	func testCorrectHTTPMethod() throws {
		let request = Request(method: .get, endpoint: validEndpoint)
		let urlRequest = try request.toURLRequest()
		XCTAssertEqual(urlRequest.httpMethod, "GET")
	}

	func testCorrectEndpointURLInRequest() throws {
		let request = Request(method: .get, endpoint: validEndpoint)
		let urlRequest = try request.toURLRequest()
		XCTAssertEqual(urlRequest.url?.absoluteString, "https://swiftindiaauth.herokuapp.com/oauth/token")
	}

	func testIncorrectEndpointURLInRequest() throws {
		let invalidEndpoint = Endpoint(path: "oauth/token", baseURL: "google.com")
		let request = Request(method: .get, endpoint: invalidEndpoint)
		do {
			_ = try request.toURLRequest()
		} catch {
			if case Endpoint.EndpointError.invalidURL(let endpoint) = error {
				XCTAssertEqual(invalidEndpoint, endpoint)
			} else {
				XCTFail()
			}
		}

	}

	func testLoginEndpoint() {
		XCTAssertEqual(validEndpoint.url?.absoluteString, "https://swiftindiaauth.herokuapp.com/oauth/token")
	}

	func testHeaders() throws {
		let randomNumberOfHeaders = fakery.number.randomInt(min: 10, max: 100)
		let headerDict: [String: String] = (0..<randomNumberOfHeaders).reduce(into: [:]) { (dict, _) in
			dict[UUID().uuidString] = UUID().uuidString
		}

		let urlRequest = try Request(method: .get, endpoint: Auth.tokenEndpoint(with: "https://apple.com"), headers: headerDict).toURLRequest()
		XCTAssertEqual(urlRequest.allHTTPHeaderFields, headerDict)
	}
}
