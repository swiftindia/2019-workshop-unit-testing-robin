//
//  AuthenticatorTEsts.swift
//  SwiftIndiaAuthTests
//
//  Created by Robin Malhotra on 26/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import XCTest
@testable import SwiftIndiaAuth

/**
An integration test to make sure token refreshes work the way they should. Tests for the following behaviours:
- Requests made before token expiry are made with an old token
- Requests made after the token is done refreshing are made with the new token
- *All* Requests that failed between the token expiring and it refreshing are retried with a new token

Here's a diagram of it looks like:
-----------------------------------------------------------------  Here's a "timeline" with requests distributed randomly and uniformly over the timeline (much like an actual app)


Your token expires somewhere in the middle, like so
-------------|---------------------------------------------------
That `|` is the token expiry time


there’ll be a time when your system detects the expiry and starts a refresh
-------------|(1)----(2)---------(3)---------------------------------------
1 = token expires
2 = you detect said expiry, start refreshing
3 = refresh complete


So, in our fake URLSession (FullCycleSession),
- all requests made before 1 succeed if they’re made with the old token
- between 1 and 3, all requests have to be retried with the new token (so I’ll have to write a test for that (edited)
- post 3, all requests should be made only once (no retries with the new token

Since this is a time based test and I don’t want to actually run this scenario over x seconds, we'll simulate this by making a batch of 50-100 requests and batching them up, then sending them to our API client every few milliseconds
*/

extension URLSession {
	/**
	DO NOT USE THIS IN PRODUCTION!
	First of all, no calls will fire, because there's no resume at the end of the data task. This is because if you call resume() on an abstract URLDataTask, it'll fail spectacularly with an NSInternalConsistencyException. Yay!
	*/
	func fakeTestingOnlyRequestLoadingInterface(request: Request, completion: @escaping ((RequestLoadingResult) -> Void)) {
		do {
			let urlRequest = try request.toURLRequest()
			self.dataTask(with: urlRequest) { (data, urlResponse, error) in
				if let data = data, let response = urlResponse as? HTTPURLResponse {
					completion(.success((data, response)))
				} else if let error = error {
					completion(.failure(error))
				}
			}
		} catch {
			fatalError()
		}
	}
}

class AuthenticatorTests: XCTestCase {

	func requestLoader(for json: String) -> RequestLoading {
		return { [weak self] (request, completion) in
			let httpURLResponse = HTTPURLResponse.init(url: try! request.toURLRequest().url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
			let data = try! Data(contentsOf: Bundle(for: type(of: self!)).url(forResource: json, withExtension: "json")!)
			let tuple = (data, httpURLResponse)
			completion(.success(tuple))
		}
	}

	let dictionaryTokenStorage = DictionaryTokenStorage()
	lazy var authenticator = Authenticator<URLRequest>(tokenID: UUID().uuidString, baseURL: UUID().uuidString, tokenStorage: self.dictionaryTokenStorage, requestLoader: self.requestLoader(for: ""))

    func testAuthenticator() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
