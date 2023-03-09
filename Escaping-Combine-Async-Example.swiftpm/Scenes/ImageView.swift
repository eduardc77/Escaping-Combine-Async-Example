//
//  ImageView.swift
//  
//
//  Created by Eduard Caziuc on 05.03.2023.
//

import SwiftUI

struct ImageView: View {
	@StateObject var viewModel: ImageViewModel
	var index: Int
	@Binding var detailImage: DetailImage?

	var body: some View {

		Button {
			withAnimation {
				detailImage = DetailImage(title: "Image \(index + 1)", image: viewModel.image ?? Image(""))
			}
		} label: {
			viewModel.image?
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(height: 260)
				.cornerRadius(8)
				.contentShape(Rectangle())
		}
		.buttonStyle(.scale)
		.placeholder(active: viewModel.image == nil)

		.onAppear {
			if viewModel.image == nil {
				Task {
					await viewModel.downloadImage()
				}
			}
		}
	}
}
