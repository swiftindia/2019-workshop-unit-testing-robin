//
//  LoginAPIClients.swift
//  SwiftIndiaAuthTests
//
//  Created by Robin Malhotra on 26/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import XCTest
@testable import SwiftIndiaAuth

class LoginAPIClients: XCTestCase {

	lazy var bundle = Bundle(for: type(of: self))

	func requestLoader(for json: String) -> RequestLoading {
		return { [weak self] (request, completion) in
			let httpURLResponse = HTTPURLResponse.init(url: try! request.toURLRequest().url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
			let data = try! Data(contentsOf: self!.bundle.url(forResource: json, withExtension: "json")!)
			let tuple = (data, httpURLResponse)
			completion(.success(tuple))
		}
	}


    func testSuccess() {
        let validTokenLoader = requestLoader(for: "ValidAccessToken")
		let apiClient = LoginAPIClient(baseURL: "https://google.com", requestLoader: validTokenLoader)

		let validTokenExpectation = expectation(description: "validTokenExpectation")
		let inputs = Auth.Login.Inputs(username: UUID().uuidString, password: UUID().uuidString, clientID: UUID().uuidString, clientSecret: UUID().uuidString)
		apiClient.requestToken(inputs: inputs) { (result) in
			switch result {
			case .success(let tokens):
				let accessToken = """
				eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiIxMDk4NjVhMy0wMzgzLTRjOWEtOTIxOS05NGVhYmFjMzBiZTkiLCJzdWIiOiIxIiwiZXhwaXJlc0luIjoiMTBzIiwiaWF0IjoxNTY0MDUzODAwfQ.i8THycrsyu4txCD-Z3lYAw664ExdnK8xzIueuwiiZ6nKY6QxxtPFhLHPKTrq_TuwiNj64f7wsbGiW9s9D06BYGNirBd-94BOIhZ5benFO1FRZai_pQxNyW4huVZZVl3TY26J6qOzWt0UnUStNkPqCrhoaQcBFWEEWklJr8U_J-AZnmdqLs45oS5AX4yjSxFwC_5j8UnaauevjMEtGsEF1NMfn5Z2JkfqN-oLUo4zdTbqJS62daHjakOdguThQRWoDPr2EEsOdrrrJd1palvmsIiiCG3GcsAVbBl6gcliuzLJcps1zPWnof4Cea6NQtKNs-J2Eesiw0uzunrTZwDxTg
				"""
				let refreshToken = """
				eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJjMzFiYjRjNS01MTQ0LTRmZWUtYTY2ZS1lYzJiN2I0YTgyZjIiLCJzdWIiOiIiLCJleHBpcmVzSW4iOiIxMHMiLCJpYXQiOjE1NjQwNTM4MDB9.lawQ033zM4467NoDDnrTTnGx423lcNiMVdwEZzeAesUaYs59r6V2ZlGvbhIYhsNQNziJPRmmkkT3-DbzTHipLtHXtwjVf1_niLvpgaFgfRgTT1cAnNqJhBoxegm1gJTKNEqMP0YK7g8OGC11RYoLtW91xY7FqOjeYBt5pjMkf4VOnAW9pUZPJlyPkQkPvHv3d4ZPlQg4-xtIbbMR7Ek0f1DGIsiCLINT560HeBekTqLuC0RoK8JtkBkxrUsd1_npih3Mr0cI_alKGmbeW2j14t9csLqJVeSls_TYGdn5m4uTIUawjXTnVgnTRaFxLllodkEaOKSBJWTykUrxQol-kw
				"""
				XCTAssertEqual(accessToken, tokens.accessToken)
				XCTAssertEqual(refreshToken, tokens.refreshToken)
				validTokenExpectation.fulfill()
			case .failure:
				XCTFail()
			}
		}

		wait(for: [validTokenExpectation], timeout: 10)
    }

}
