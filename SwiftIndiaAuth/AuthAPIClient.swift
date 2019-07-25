//
//  AuthAPIClient.swift
//  SwiftIndiaAuth
//
//  Created by Robin Malhotra on 26/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import Foundation

typealias RequestLoadingResult = Result<(Data,HTTPURLResponse), Error>
typealias RequestLoading = (Request, @escaping (RequestLoadingResult) -> Void) -> Void

class LoginAPIClient {
	let networking: RequestLoading
	let jsonDecoder = JSONDecoder()
	let baseURL: String


	init(baseURL: String, requestLoader: @escaping RequestLoading) {
		self.baseURL = baseURL
		self.networking = requestLoader
		jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
	}

	func requestToken(inputs: Auth.Login.Inputs, completion: @escaping (Result<AuthTokens, Error>) -> Void) {
		let request = Auth.Login.tokenRequest(with: baseURL, inputs: inputs)
		/// I hate if let strongSelf = self's, they're an anti pattern
		let jsonDecoder = self.jsonDecoder

		networking(request) { (result) in
			switch result {
			case .success(let (data, _)):
				do {
					/// use response to parse errors based on statusCode
					let successResult = try jsonDecoder.decode(AuthTokens.self, from: data)
					completion(.success(successResult))
				} catch {
					completion(.failure(error))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
