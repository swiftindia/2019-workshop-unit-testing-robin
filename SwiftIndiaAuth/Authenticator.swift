//
//  Authenticator.swift
//  SwiftIndiaAuth
//
//  Created by Robin Malhotra on 26/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import Foundation
import TokenStorage

public protocol HeaderMutating {
	func addHeaders(_ headers: [String: String]) -> Self
}

protocol RequestAuthenticator {
	associatedtype Request: HeaderMutating
	func addAuthentication(to request: Request) -> (Result<Request, TokenStorageError>)
}

typealias Handler = (Result<AuthTokens, Error>) -> Void

struct RefreshedTokens: Codable {
	let accessToken: String
}
protocol TokenRefresher {
	func performRefresh(with inputs: Auth.Refresh.Inputs, then handler: @escaping Handler)
}

extension URLRequest: HeaderMutating {
	public func addHeaders(_ headers: [String : String]) -> URLRequest {
		var copy = self
		for (key, value) in headers {
			copy.addValue(value, forHTTPHeaderField: key)
		}
		return copy
	}
}

typealias AuthenticationLayer = RequestAuthenticator & TokenRefresher

class Authenticator<Request: HeaderMutating>: AuthenticationLayer {

	let tokenStorage: TokenStorage
	let tokenID: String
	let baseURL: String
	let networking: RequestLoading
	let lock = NSLock()
	private let queue: DispatchQueue
	private var pendingHandlers: [Handler] = []
	let jsonDecoder = JSONDecoder()

	public init(tokenID: String, baseURL: String, tokenStorage: TokenStorage, accessQueue: DispatchQueue = .init(label: "AuthTokens Refresh"), requestLoader: @escaping RequestLoading) {
		self.tokenID = tokenID
		self.tokenStorage = tokenStorage
		self.baseURL = baseURL
		self.networking = requestLoader
		self.queue = accessQueue

		self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
	}

	func addAuthentication(to request: Request) -> (Result<Request, TokenStorageError>) {
		let result = tokenStorage.get(with: tokenID)
		switch result {
		case .success(let tokens):
			let headers = [
				"Authorization": "Bearer \(tokens.accessToken)"
			]
			let newRequest = request.addHeaders(headers)
			return .success(newRequest)
		case .failure(let error):
			return .failure(error)
		}
	}

	func refreshTokens(inputs: Auth.Refresh.Inputs, completion: @escaping (Result<AuthTokens, Error>) -> Void) {
		let tokenStorage = self.tokenStorage
		let tokenID = self.tokenID

		queue.async { [weak self] in
			let result = tokenStorage.get(with: tokenID)
			switch result {
			case .success:
				self?.performRefresh(with: inputs, then: completion)
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func performRefresh(with inputs: Auth.Refresh.Inputs, then handler: @escaping Handler) {
		pendingHandlers.append(handler)

		guard pendingHandlers.count == 1 else {
			return
		}
		let tokenStorage = self.tokenStorage
		let tokenID = self.tokenID
		let jsonDecoder = self.jsonDecoder

		networking(Auth.Refresh.tokenRequest(with: baseURL, inputs: inputs), { (result) in
			switch result {
			case .success(let data,_):
				do {
					let newAuthToken = try jsonDecoder.decode(RefreshedTokens.self, from: data)
					let newTokens = AuthTokens(accessToken: newAuthToken.accessToken, refreshToken: inputs.refreshToken)
					let saveResult = tokenStorage.set(tokens: newTokens, with: tokenID)
					switch saveResult {
					case .success:
						self.handle(.success(newTokens))
					case .failure(let error):
						self.handle(.failure(error))
					}
				} catch {
					self.handle(.failure(error))
				}
			case .failure(let error):
				self.handle(.failure(error))
			}
		})
	}

	func handle(_ result: Result<AuthTokens, Error>) {
		let handlers = self.pendingHandlers
		pendingHandlers = []
		handlers.forEach{ $0(result) }
	}
}


