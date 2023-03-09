import SwiftUI

struct ContentView: View {
	@State private var detailImage: DetailImage?
	@State private var scrollOffset: CGPoint = .zero

	@State var urlStrings = ["https://picsum.photos/1000", "https://picsum.photos/1000", "https://picsum.photos/1000"]

	var body: some View {
		VStack {
			OffsetObservingScrollView(offset: $scrollOffset) {
				
				LazyStack(spacing: 24) {
					ForEach(Array(zip(urlStrings.indices, urlStrings)), id: \.0) { index, image in

						ImageView(viewModel: ImageViewModel(urlString: urlStrings[index]), index: index, detailImage: $detailImage)

							.onChange(of: scrollOffset) { position in
								if position.y > 0.96 {
									urlStrings.append("https://picsum.photos/id/\(index + 1)/1000")
								}
							}
					}
				}
				.frame(maxWidth: .infinity)
				.padding()
			}
		}
		.navigationTitle("Images For You")

		.fullScreenCover(
			item: $detailImage,
			content: { _ in
				ImageDetailView(detailImage: $detailImage)
			}
		)
	}
}

// MARK: - Subviews

private extension ContentView {
	@ViewBuilder
	func imageView(with image: UIImage?, at index: Int) -> some View {

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
