//
//  ImageViewModel.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 28.01.2023.
//

import SwiftUI
import Combine

class ImageViewModel: ObservableObject {
	var imageCache = ImageCache.getImageCache()
	var downloadManager: DownloadManager
	var cancellable = Set<AnyCancellable>()
	var urlString: String

	@Published var image: Image?

	var downloadMethod: DownloadMethod
	
	// MARK: - Initialization
	
	init(urlString: String) {
		self.urlString = urlString
		downloadManager = DownloadManager(url: URL(string: self.urlString))
		downloadMethod = DownloadMethod(rawValue: Int.random(in: 1..<DownloadMethod.allCases.count)) ?? .asyncAwait
	}

	@MainActor
	func downloadImage() async {
		switch downloadMethod {
		case .escaping:
			fetchImageUsingEscaping()
		case .combine:
			fetchImageUsingCombine()
		case .asyncAwait:
			await fetchImageUsingAsync()
		}
	}

	func loadImageFromCache() -> Bool {
		guard let cacheImage = imageCache.get(forKey: urlString) else {
			return false
		}
		DispatchQueue.main.async {
			self.image = Image(uiImage: cacheImage)
		}

		return true
	}
	
	// MARK: - @Escaping
	
	private func fetchImageUsingEscaping() {
		if loadImageFromCache() {
			return
		}
		downloadManager.downloadImageUsingEscaping { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let image):
				DispatchQueue.main.async {
					guard let loadedImage = image else { return }
					self.imageCache.set(forKey: self.urlString, image: loadedImage)
					self.image = Image(uiImage: loadedImage)
				}
			case .failure(let error):
				print("Error occurred while downloading image using escaping: \(error.localizedDescription).")
			}
		}

	}
	
	// MARK: - Combine
	
	private func fetchImageUsingCombine() {
		if loadImageFromCache() {
			return
		}
		downloadManager.downloadImageUsingCombine()
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .failure(let error): print("Error occurred while downloading image using combine \(error).")
				case .finished: break
				}
			} receiveValue: { [weak self] image in
				DispatchQueue.main.async {
					guard let self = self, let loadedImage = image else { return }
					self.imageCache.set(forKey: self.urlString, image: loadedImage)
					self.image = Image(uiImage: loadedImage)
				}
			}
			.store(in: &cancellable)
	}
	
	// MARK: - Async/Await
	
	private func fetchImageUsingAsync() async {
		if loadImageFromCache() {
			return
		}
		do {
			let image = try await downloadManager.downloadImageUsingAsync()
			await MainActor.run {
				guard let loadedImage = image else { return }
				self.imageCache.set(forKey: self.urlString, image: loadedImage)
				self.image = Image(uiImage: loadedImage)
			}
		} catch {
			print("Error occurred while downloading image using Async/Await \(error).")
		}

	}
	
	@ViewBuilder
	private var imageUsingAsyncImage: some View {
		AsyncImageView(urlString: urlString)
	}
}

enum DownloadMethod: Int, CaseIterable {
	case escaping
	case combine
	case asyncAwait
}

class ImageCache {
	var cache = NSCache<NSString, UIImage>()

	func get(forKey: String) -> UIImage? {
		return cache.object(forKey: NSString(string: forKey))
	}

	func set(forKey: String, image: UIImage) {
		cache.setObject(image, forKey: NSString(string: forKey))
	}
}

extension ImageCache {
	private static var imageCache = ImageCache()
	static func getImageCache() -> ImageCache {
		return imageCache
	}
}
