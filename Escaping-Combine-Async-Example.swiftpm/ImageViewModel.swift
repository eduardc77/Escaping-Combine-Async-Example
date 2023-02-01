//
//  ImageViewModel.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 28.01.2023.
//

import SwiftUI
import Combine

class ImageViewModel: ObservableObject {
	let downloadManager: DownloadManager
	var cancellable = Set<AnyCancellable>()
	let url = URL(string: "https://picsum.photos/2000")

	@Published var downloadFinished: Bool = false
	@Published var images = [UIImage?]()
	
	// MARK: - Initialization
	
	init() {
		downloadManager = DownloadManager(url: url)
	}
	
	func downloadImages() async {
		DispatchQueue.main.async {
			self.downloadFinished = false
			self.images = []
		}
		for _ in 0...1 {
			fetchImageUsingEscaping()
			fetchImageUsingCombine()
			await fetchImageUsingAsync()
		}

		DispatchQueue.main.async {
			self.downloadFinished = true
		}
	}
	// MARK: - @Escaping
	
	func fetchImageUsingEscaping() {
		downloadManager.downloadImageUsingEscaping { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let image):
				DispatchQueue.main.async {
					self.images.append(image)
				}
			case .failure(let error):
				print("Error occurred while downloading image using escaping: \(error.localizedDescription).")
			}
		}
	}
	
	// MARK: - Combine
	
	func fetchImageUsingCombine() {
		downloadManager.downloadImageUsingCombine()
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .failure(let error): print("Error occurred while downloading image using combine \(error).")
				case .finished: break
				}
			} receiveValue: { [weak self] image in
				self?.images.append(image)
			}
			.store(in: &cancellable)
		
	}
	
	// MARK: - Async/Await
	
	func fetchImageUsingAsync() async {
		do {
			let image = try await downloadManager.downloadImageUsingAsync()
			await MainActor.run {
				self.images.append(image)
			}
		} catch {
			print("Error occurred while downloading image using Async/Await \(error).")
		}
	}
	
	@ViewBuilder
	var imageUsingAsyncImage: some View {
		AsyncImageView(urlString: url?.absoluteString ?? "")
	}
}
