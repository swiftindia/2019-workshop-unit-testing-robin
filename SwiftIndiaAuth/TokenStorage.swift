//
//  TokenStorage.swift
//  SwiftIndiaAuth
//
//  Created by Robin Malhotra on 25/07/19.
//  Copyright © 2019 rmalhotra. All rights reserved.
//

import Foundation

/**
Tokens as per the OAuth 2.0 spec. Please avoid adding user specific details here and instead relegate to another type
*/
public struct AuthTokens: Equatable, Decodable {
	public let accessToken: String
	public let refreshToken: String

	public init(accessToken: String, refreshToken: String) {
		self.accessToken = accessToken
		self.refreshToken = refreshToken
	}
}

public enum TokenStorageError: Error {
	case tokenNotFound(String)
	case underlyingStorageError(Error)
}

/**
Abstraction over Token Storage. Can work over `UserDefaults` or Keychain Storage or a Database or even over plain old files!
*/
public protocol TokenStorage {
	func set(tokens: AuthTokens, with id: String) -> Result<Void, TokenStorageError>
	func get(with id: String) -> Result<AuthTokens, TokenStorageError>
	func delete(with id: String) -> Result<Void, TokenStorageError>
}

/**
Token Storage in an in-memory dictionary. Prefer using only in tests
*/
public class DictionaryTokenStorage: TokenStorage {

	var count: Int {
		return dict.count
	}

	public init(dictValues: [String: AuthTokens] = [:]) {
		self.dict = dictValues
	}

	//TODO: __Maybe__ add an isolation queue: http://khanlou.com/2016/04/the-GCD-handbook/ , last section?
	private var dict: [String: AuthTokens] = [:]

	public func set(tokens: AuthTokens, with id: String) -> Result<Void, TokenStorageError>{
		dict[id] = tokens
		return .success(())
	}

	public func get(with id: String) -> Result<AuthTokens, TokenStorageError> {
		if let token = dict[id] {
			return .success(token)
		} else {
			return .failure(TokenStorageError.tokenNotFound(id))
		}
	}

	public func delete(with id: String) -> Result<Void, TokenStorageError> {
		dict.removeValue(forKey: id)
		return .success(())
	}
}
