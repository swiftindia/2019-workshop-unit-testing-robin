//
//  DictionaryTokenStorageTests.swift
//  SwiftIndiaAuthTests
//
//  Created by Robin Malhotra on 25/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import XCTest
import Fakery
@testable import SwiftIndiaAuth
@testable import TokenStorage

class DictionaryTokenStorageTests: XCTestCase {
	let dictStorage = DictionaryTokenStorage()
	let faker = Faker()

    func testExample() {
		let randomNumber = faker.number.randomInt(min: 100, max: 200)
		var arr: [String] = []
		for _ in 0..<randomNumber {
			let authTokens = AuthTokens(accessToken: UUID().uuidString, refreshToken: UUID().uuidString)
			let name = UUID().uuidString
			arr.append(name)
			let result = dictStorage.set(tokens: authTokens, with: name)
			switch result {
			case .success:
				let getResult = dictStorage.get(with: name)
				switch getResult {
				case .success(let tokens):
					XCTAssertEqual(authTokens, tokens)
				case .failure:
					XCTFail()
				}
			case .failure:
				XCTFail()
			}
		}
		XCTAssertEqual(randomNumber, dictStorage.count)
    }

	func testFailure() {
		let randomNameNotInDict = UUID().uuidString
		let result = dictStorage.get(with: randomNameNotInDict)
		switch result {
		case .success:
			XCTFail("should've not found a token")
		case .failure(let error):
			switch error {
			case .tokenNotFound(let name):
				XCTAssertEqual(randomNameNotInDict, name)
			default:
				XCTFail("should've failed with a .tokenNotFound")
			}
		}
	}

	func testDeletes() {
		let id = UUID().uuidString
		let dictStorage = DictionaryTokenStorage(dictValues: [id: AuthTokens(accessToken: UUID().uuidString, refreshToken: UUID().uuidString)])
		let result = dictStorage.delete(with: id)
		switch result {
		case .success():
			break
		case .failure:
			XCTFail()
		}
	}

}
