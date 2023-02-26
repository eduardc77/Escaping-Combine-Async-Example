//
//  AsyncImage.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 28.01.2023.
//

import SwiftUI

struct AsyncImageView: View {
	let urlString: String
	let width: CGFloat = 300
	let height: CGFloat = 300
	
	var body: some View {
		AsyncImage(url: URL(string: urlString)) { phase in
			switch phase {
			case .success(let image):
				image
					.resizable()
					.scaledToFit()
					.frame(width: width, height: height)
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
