//
//  DownloadManager.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 28.01.2023.
//

import SwiftUI
import Combine

class DownloadManager {
	// MARK: -  Types
	
	enum GetError: Error {
		case missingURL
		case missingData
	}
	
	typealias HttpCallResponse = Result<UIImage?, Error>
	
	// MARK: - Properties
	
	var url: URL?
	
	// MARK: - Initialization
	
	init(url: URL?) {
		self.url = url
	}
	
	// MARK: - Public Methods
	
	///Downloads an image using @escaping completion.
	func downloadImageUsingEscaping(completion: @escaping (HttpCallResponse) -> ()) {
		guard let url = url else {
			completion(.failure(GetError.missingURL))
			return
		}
		
		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			guard let self = self else { return }
			
			if let error = error {
				print("Error in downloadImageUsingEscaping: \(String(describing: error.localizedDescription)).")
				completion(.failure(error))
			}
			
			guard let data = data else {
				completion(.failure(GetError.missingData))
				return
			}
			
			let image = self.responseHandler(data: data, response: response)
			completion(.success(image))
		}
		.resume()
	}
	
	///Downloads an image using Combine.
	func downloadImageUsingCombine() -> AnyPublisher<UIImage?, Error> {
		URLSession.shared.dataTaskPublisher(for: url!)
			.map(responseHandler)
			.mapError({ $0 })
			.eraseToAnyPublisher()
	}
	
	///Downloads an image using Async/Await.
	func downloadImageUsingAsync() async throws -> UIImage? {
		guard let url = url else { return nil }
		
		do {
			let (data, response) = try await URLSession.shared.data(from: url)
			let image = responseHandler(data: data, response: response)
			return image
		} catch {
			throw error
		}
	}
}

// MARK: - Private Methods

private extension DownloadManager {
	func responseHandler(data: Data?, response: URLResponse?) -> UIImage? {
		guard let data = data,
				let image = UIImage(data: data),
				let response = response as? HTTPURLResponse,
				response.statusCode >= 200 && response.statusCode < 300
		else {
			print("Error in responseHandler.")
			return nil
		}
		return image
	}
}
