//
//  Authenticator.swift
//  SwiftIndiaAuth
//
//  Created by Robin Malhotra on 26/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import Foundation

public protocol HeaderMutating {
	func addHeaders(_ headers: [String: String]) -> Self
}

protocol RequestAuthenticator {
	associatedtype Request: HeaderMutating
	func addAuthentication(to request: Request, completion: (Result<Request, TokenStorageError>) -> Void)
}

struct RefreshTokens {
	let accessToken: String
}
protocol TokenRefresher {
	func refreshTokens(completion: @escaping (Result<RefreshTokens, Error>) -> Void)
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

	public typealias Handler = (Result<AuthTokens, Error>) -> Void
	private let queue: DispatchQueue
	private var pendingHandlers: [Handler] = []

	public init(tokenID: String, baseURL: String, tokenStorage: TokenStorage, accessQueue: DispatchQueue = .init(label: "AuthTokens Refresh"), requestLoader: @escaping RequestLoading) {
		self.tokenID = tokenID
		self.tokenStorage = tokenStorage
		self.baseURL = baseURL
		self.networking = requestLoader
		self.queue = accessQueue
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

	func refreshTokens(completion: @escaping (Result<RefreshTokens, Error>) -> Void) {
		let tokenStorage = self.tokenStorage
		let tokenID = self.tokenID
		queue.async { [weak self]
			let result = tokenStorage.get(with: tokenID)
			switch result {
			case .success(let tokens):
				
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}


