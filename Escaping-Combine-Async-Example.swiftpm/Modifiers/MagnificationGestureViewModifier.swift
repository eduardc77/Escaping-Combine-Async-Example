//
//  MagnificationGestureViewModifier.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 25.02.2023.
//

import SwiftUI

struct MagnificationGestureViewModifier: ViewModifier {
	@Binding var scale: CGFloat
	let resets: Bool
	let animation: Animation
	let minScale: Double
	let maxScale: Double
	let scaleMultiplier: CGFloat
	let onEnded: ((_ scale: CGFloat) -> ())?

	@State private var lastScale: CGFloat = 1.0

	func body(content: Content) -> some View {
		content
			.scaleEffect(scale * scaleMultiplier)

			.simultaneousGesture(
				MagnificationGesture()
					.onChanged { value in
						let delta = value / lastScale
						scale *= delta
						lastScale = value
					}
					.onEnded { value in
						if !resets {
							onEnded?(lastScale)
						} else {
							onEnded?(value - 1)
						}

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
	///   - scale: Binds the scale to have access outside the view modifier.
	///   - resets: If the View should reset to starting state onEnded.
	///   - animation: The magnification animation.
	///   - scaleMultiplier: Used to scale the View while dragging.
	///   - onEnded: The action to perform when this gesture’s value ends. The action closure’s parameter contains the gesture’s new value.
	///
	func withMagnificationGesture(
		scale: Binding<CGFloat>,
		resets: Bool = true,
		animation: Animation = .spring(),
		minScale: Double = 1.0,
		maxScale: Double = 6.0,
		scaleMultiplier: CGFloat = 1,
		onEnded: ((_ scale: CGFloat) -> ())? = nil) -> some View {
			modifier(MagnificationGestureViewModifier(scale: scale, resets: resets, animation: animation, minScale: minScale, maxScale: maxScale, scaleMultiplier: scaleMultiplier, onEnded: onEnded))
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
			.previewDevice("iPhone 14 Pro")
	}
}
