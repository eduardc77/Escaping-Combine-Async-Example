//
//  MagnificationGestureViewModifier.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 25.02.2023.
//

import SwiftUI

struct MagnificationGestureViewModifier: ViewModifier {
	@Binding var scale: CGFloat
	var resets: Bool
	var animation: Animation
	var minScale: Double = 1.0
	var maxScale: Double = 6.0
	var onEnded: (() -> ())?

	@State private var lastScale: CGFloat = 1

	func body(content: Content) -> some View {
		content
			.scaleEffect(scale)
			.simultaneousGesture(
				MagnificationGesture()
					.onChanged { value in
						let delta = value / lastScale
						scale *= delta
						lastScale = value
					}
					.onEnded { value in
						onEnded?()
						withAnimation(animation) {
							if !resets {
								scale = max(scale, minScale)
								scale = min(scale, maxScale)
							}
							lastScale = minScale
						}
					}
			)
	}
}

public extension View {
	/// Add a MagnificationGesture to a View.
	///
	/// MagnificationGesture is added as a simultaneousGesture, to not interfere with other gestures Developer may add.
	///
	/// - Parameters:
	///   - scale: Bind the scale to have access outside the view modifier.
	///   - resets: If the View should reset to starting state onEnded.
	///   - animation: The magnification animation.
	///   - onEnded: The action to perform when this gesture’s value ends.
	///
	func withMagnificationGesture(
		scale: Binding<CGFloat>,
		resets: Bool = false,
		animation: Animation = .spring(),
		minScale: Double = 1.0,
		maxScale: Double = 6.0,
		onEnded: (() -> ())? = nil) -> some View {
			modifier(MagnificationGestureViewModifier(scale: scale, resets: resets, animation: animation, onEnded: onEnded))
		}
}


// MARK: - Previews

struct MagnificationGestureViewModifier_Previews: PreviewProvider {
	struct ExampleView: View {
		@State var scale: CGFloat = 1

		var body: some View {
			AsyncImageView(urlString: "https://picsum.photos/1000")

				.withMagnificationGesture(scale: $scale, resets: false, animation: .spring())
		}
	}

	static var previews: some View {
		ExampleView()
	}
}
