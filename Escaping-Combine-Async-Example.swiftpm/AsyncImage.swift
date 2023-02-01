//
//  AsyncImage.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 28.01.2023.
//

import SwiftUI

struct AsyncImageView: View {
	let urlString: String

	var body: some View {
		AsyncImage(url: URL(string: urlString)) { phase in
			switch phase {
			case .success(let image):
				image
					.resizable()
					.scaledToFit()
					.frame(width: 200, height: 200)
			case .empty:
				ProgressView()
			case .failure(_):
				Color.red
			@unknown default:
				Color.clear
			}
		}
	}
}
