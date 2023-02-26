//
//  RotationGestureViewModifier.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 25.02.2023.
//

import SwiftUI

struct RotationGestureViewModifier: ViewModifier {
	let resets: Bool
	let animation: Animation
	let onEnded: ((_ angle: Double) -> ())?

	@State private var angle: Double = 0
	@State private var lastAngle: Double = 0

	func body(content: Content) -> some View {
		content
			.rotationEffect(Angle(degrees: angle + lastAngle))
		
			.simultaneousGesture(
				RotationGesture(minimumAngleDelta: Angle(degrees: 2))
					.onChanged { value in
						angle = value.degrees
					}
					.onEnded { value in
						if !resets {
							onEnded?(lastAngle)
						} else {
							onEnded?(value.degrees)
						}

						withAnimation(.spring()) {
							if resets {
								angle = 0
							} else {
								lastAngle += angle
								angle = 0
							}
						}
					}
			)
	}
}

public extension View {

	/// Add a RotationGesture to a View.
	///
	/// RotationGesture is added as a simultaneousGesture, to not interfere with other gestures Developer may add.
	///
	/// - Parameters:
	///   - resets: If the View should reset to starting state onEnded.
	///   - animation: The rotation animation.
	///   - onEnded: The action to perform when this gesture’s value ends. The action closure’s parameter contains the gesture’s new value.
	///
	func withRotationGesture(
		resets: Bool = true,
		animation: Animation = .spring(),
		onEnded: ((_ angle: Double) -> ())? = nil) -> some View {
			modifier(RotationGestureViewModifier(resets: resets, animation: animation, onEnded: onEnded))
		}
}

// MARK: - Previews

struct RotationGestureViewModifier_Previews: PreviewProvider {
	struct ExampleView: View {
		var body: some View {
			AsyncImageView(urlString: "https://picsum.photos/1000")
				.withRotationGesture(resets: false)
		}
	}

	static var previews: some View {
		ExampleView()
			.previewDevice("iPhone 14 Pro")
	}
}
