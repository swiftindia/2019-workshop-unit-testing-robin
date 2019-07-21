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
	func testCorrectHTTPMethod() throws {
		let request = Request(method: .get)
		let urlRequest = try request.toURLRequest()
		URLRequest.http
		XCTAssertEqual(urlRequest.httpMethod, "GET")
	}
}
