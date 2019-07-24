//
//  MakeRequestTests.swift
//  SwiftIndiaAuthTests
//
//  Created by Robin Malhotra on 22/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import XCTest
@testable import SwiftIndiaAuth

class MakeRequestTests: XCTestCase {

	let validEndpoint = Auth.tokenEndpoint(with: "swiftindiaauth.herokuapp.com")


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
		let endpoint = Auth.tokenEndpoint(with: "swiftindiaauth.herokuapp.com")
		XCTAssertEqual(endpoint.url?.absoluteString, "https://swiftindiaauth.herokuapp.com/oauth/token")
	}
}
