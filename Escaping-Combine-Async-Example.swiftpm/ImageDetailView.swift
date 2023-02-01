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
	
	// MARK: - Private Properties
	
	@State private var animate: Bool = false
	@State private var scale: CGFloat = 1.0
	@State private var lastScale: CGFloat = 1.0
	@State private var imageOffset: CGSize = .zero
	@State private var lastImageOffset: CGSize = .zero
	
	static let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
	private let minScale = 1.0
	private let maxScale = 6.0
	
	private var panGesture: some Gesture {
		DragGesture()
			.onChanged(onDragGestureChanged)
			.onEnded(onDragGestureEnded)
	}
	
	private var zoomGesture: some Gesture {
		MagnificationGesture()
			.onChanged(onMagnificationGestureChanged)
			.onEnded(onMagnificationGestureEnded)
	}
	
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
		withAnimation(.linear) {
			scale = 1
			imageOffset = .zero
			lastImageOffset = .zero
			impactOccurred()
		}
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
	
	// Pan Gesture
	func onDragGestureChanged(value: DragGesture.Value) {
		withAnimation(.linear) {
			if scale == 1 {
				imageOffset = value.translation
			} else {
				imageOffset.width = lastImageOffset.width + value.translation.width
				imageOffset.height = lastImageOffset.height + value.translation.height
			}
		}
	}
	
	func onDragGestureEnded(value: DragGesture.Value) {
		if scale <= 1 {
			resetImageState()
		} else {
			lastImageOffset.height += value.translation.height
			lastImageOffset.width += value.translation.width
		}
	}
	
	// Zoom Gesture
	func onMagnificationGestureChanged(value: MagnificationGesture.Value) {
		imageOffset = .zero
		lastImageOffset = .zero
		
		let delta = value / lastScale
		scale *= delta
		lastScale = value
	}
	
	func onMagnificationGestureEnded(value: MagnificationGesture.Value) {
		if scale < minScale || scale > maxScale { impactOccurred() }
		
		withAnimation {
			scale = max(scale, minScale)
			scale = min(scale, maxScale)
		}
		
		lastScale = minScale
	}
	
	func impactOccurred() {
		ImageDetailView.feedbackGenerator.impactOccurred()
	}
}

// MARK: - Subviews

private extension ImageDetailView {
	var image: some View {
		detailImage?.image
			.resizable()
			.scaledToFit()
			.opacity(animate ? 1 : 0)
			.scaleEffect(scale)
			.animation(.linear, value: animate)
			.animation(.spring(), value: scale)
			.offset(x: imageOffset.width, y: imageOffset.height)
			.onTapGesture(count: 2, perform: onImageDoubleTapped)
			.gesture(panGesture)
			.gesture(zoomGesture)
	}
	
	var controls: some View {
		HStack {
			// Zoom Out
			Button {
				if scale > minScale {
					scale -= 1
					imageOffset = .zero
				} else {
					impactOccurred()
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
					impactOccurred()
					return
				}
				
				scale += 1
				imageOffset = .zero
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

struct ImageDetailView_Previews: PreviewProvider {
	static var previews: some View {
		ImageDetailView(detailImage: .constant(DetailImage(title: "Image 1", image: Image(systemName: "applelogo"))))
			.preferredColorScheme(.dark)
	}
}
