import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ImageViewModel()
	@State var detailImage: DetailImage?

	var body: some View {
		NavigationView {
			Group {
				if !viewModel.downloadFinished {
					VStack(spacing: 8) {
						ProgressView()
						Text("Loading...")
							.foregroundColor(.secondary)
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(.ultraThinMaterial)

				} else {
					ScrollView {
						ForEach(Array(zip(viewModel.images.indices, viewModel.images)), id: \.0) { index, image in
							imageView(with: image)
								.padding()

								.onTapGesture {
									detailImage = DetailImage(title: "Image \(index + 1)", image: Image(uiImage: image ?? UIImage()))
								}
						}
						.frame(maxWidth: .infinity, maxHeight: .infinity)
					}
				}
			}
			.navigationBarTitleDisplayMode(.large)
			.navigationTitle("Images For You")
		}
		.navigationViewStyle(.stack)

		.refreshable {
			Task {
				await viewModel.downloadImages()
			}
		}

		.task {
			await viewModel.downloadImages()
		}
		
		.fullScreenCover(
			item: $detailImage,
			content: { _ in ImageDetailView(detailImage: $detailImage) }
		)
	}
}

// MARK: - Subviews

private extension ContentView {
	@ViewBuilder
	func imageView(with image: UIImage?) -> some View {
		if let image = image {
			Image(uiImage: image)
				.resizable()
				.scaledToFit()
				.frame(height: 200)
				.cornerRadius(8)
		} else {
			Color.secondary
		}
	}
}

struct DetailImage: Identifiable {
	var title: String
	var image: Image

	var id: String {
		return UUID().uuidString
	}
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
