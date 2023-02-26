//
//  ImageDetailView.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 28.01.2023.
//

import SwiftUI

struct ImageDetailView: View {
	
	// MARK: - Public Properties
	
	@Binding var detailImage: DetailImage?
	let axes: Axis.Set = [.horizontal, .vertical]
	let minScale = 1.0
	let maxScale = 6.0
	
	// MARK: - Private Properties
	
	@State private var animate: Bool = false
	@State private var scale: CGFloat = 1.0
	@State private var imageOffset: CGSize = .zero
	@State private var impactOccurred: Bool = false

	var body: some View {
		NavigationView {
			VStack {
				Spacer()
				image
				Spacer()
				controls
			}
			.navigationTitle(detailImage?.title ?? "")
			.navigationBarTitleDisplayMode(.inline)

			.toolbar {
				ToolbarItem {
					Button("Done") {
						self.detailImage = nil
					}
				}
			}
			.onAppear { animate = true }
		}
		.preferredColorScheme(.dark)
		.navigationViewStyle(.stack)

	}
}

//MARK: - Private Methods

private extension ImageDetailView {
	// Reset State
	private func resetImageState() {
		scale = 1
		impactOccurred = true
	}
	
	// Double Tap Gesture
	
	/// Zoom the photo to 6x scale if the photo isn't zoomed in and reset state if it is zoomed.
	func onImageDoubleTapped() {
		if scale == minScale {
			scale = maxScale
		} else {
			resetImageState()
		}
	}
}

// MARK: - Subviews

private extension ImageDetailView {
	var image: some View {
		detailImage?.image
			.resizable()
			.scaledToFit()
			.opacity(animate ? 1 : 0)
			.onTapGesture(count: 2, perform: onImageDoubleTapped)

			.withMagnificationGesture(scale: $scale, resets: false, minScale: minScale, maxScale: maxScale) { scale in
				if scale < minScale || scale > maxScale { impactOccurred = true }
			}
//			.withRotationGesture(resets: true)
			.withDragGesture(offset: $imageOffset, resets: scale <= 1 ? true : false)
		
			.animation(.spring(), value: scale)
			.withHaptic(onChangeOf: $impactOccurred)

			.onChange(of: scale) { newValue in
				imageOffset = .zero
			}
	}
	
	var controls: some View {
		HStack {
			// Zoom Out
			Button {
				if scale > minScale {
					scale -= 1
				} else {
					impactOccurred = true
				}
				
				if scale < minScale {
					resetImageState()
				}
			} label: {
				Image(systemName: "minus.magnifyingglass")
			}
			
			// Reset
			Button {
				resetImageState()
			} label: {
				Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
			}
			
			// Zoom In
			Button {
				guard scale < maxScale else {
					impactOccurred = true
					return
				}
				
				scale += 1
			} label: {
				Image(systemName: "plus.magnifyingglass")
			}
		}
		.font(.largeTitle)
		.padding(.vertical, 10)
		.padding(.horizontal)
		.background(.ultraThinMaterial)
		.cornerRadius(10)
		.opacity(animate ? 1 : 0)
	}
}


// MARK: - Previews

struct ImageDetailView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			ImageDetailView(detailImage: .constant(DetailImage(title: "Image 1", image: Image(systemName: "applelogo"))))
		}
	}
}

enum HapticOptions {
	case reset
}
