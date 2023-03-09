//
//  PlaceholderModifier.swift
//  Placeholder
//
//  Created by Eduard Caziuc on 04.03.2023.
//

import SwiftUI

/// A view modifier that applies an animated shimmering placeholder effect to any view,
/// typically to show that an operation is in progress.
public struct PlaceholderModifier: ViewModifier {
	var animation: Animation = Self.defaultAnimation
	@State private var phase: CGFloat = 0

	public static let defaultAnimation = Animation.linear(duration: 1.6).repeatForever(autoreverses: false)

	public func body(content: Content) -> some View {
		content
			.redacted(reason: .placeholder)
			.modifier(AnimatedMask(phase: phase).animation(animation))
			.onAppear { phase = 0.8 }
	}

	/// An animatable modifier to interpolate between `phase` values.
	struct AnimatedMask: AnimatableModifier {
		var phase: CGFloat = 0

		var animatableData: CGFloat {
			get { phase }
			set { phase = newValue }
		}

		func body(content: Content) -> some View {
			content.mask(GradientMask(phase: phase).scaleEffect(3))
		}
	}

	/// A slanted, animatable gradient between transparent and opaque to use as mask.
	/// The `phase` parameter shifts the gradient, moving the opaque band.
	struct GradientMask: View {
		let phase: CGFloat
		let centerColor = Color.black
		let edgeColor = Color.black.opacity(0.6)

		var body: some View {
			LinearGradient(gradient:
									Gradient(stops: [
										.init(color: edgeColor, location: phase),
										.init(color: centerColor, location: phase + 0.1),
										.init(color: edgeColor, location: phase + 0.2),
									]), startPoint: .topLeading, endPoint: .bottomTrailing)
		}
	}
}

public extension View {
	/// Adds an animated shimmering placeholder effect to any view, typically to show that
	/// an operation is in progress.
	/// - Parameters:
	///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
	///   - animation: A custom animation. The default animation is
	///   `.linear(duration: 1.6).repeatForever(autoreverses: false)`.
	@ViewBuilder func placeholder(active: Bool = true, animation: Animation = PlaceholderModifier.defaultAnimation) -> some View {
		if active {
			modifier(PlaceholderModifier(animation: animation))
		} else {
			self
		}
	}
}


// MARK: - Previews

struct PlaceholderModifier_Previews: PreviewProvider {
	struct Example: View {
		@State var placeholder: Bool = false

		var body: some View {
			ScrollView {
				VStack {
					VStack(alignment: .leading) {
						Text("Title 1").font(.title)
						Text(String(repeating: "Text ", count: 32))
						Rectangle().fill(.red)
							.frame(height: 60)
					}.placeholder(active: placeholder)

					VStack(alignment: .leading) {
						Text("Title 2").font(.title)
						Text(String(repeating: "Text ", count: 42))
						Rectangle().fill(.indigo)
							.frame(height: 60)
					}.placeholder(active: placeholder)

					VStack(alignment: .leading) {
						Text("Title 3").font(.title)
						Text(String(repeating: "Text ", count: 52))

						Rectangle().fill(.green)
							.frame(height: 60)

					}.placeholder(active: placeholder)
				}
				.padding(.horizontal)
			}
			.safeAreaInset(edge: .bottom) {
				Button(action: {
					Task {
						placeholder = true
						try? await Task.sleep(nanoseconds: 6_000_000_000)
						placeholder = false
					}
				}, label: {
					Text("Async Task")
						.frame(maxWidth: .infinity, maxHeight: 40)
				})
				.tint(.teal)
				.buttonStyle(.borderedProminent)
				.padding(.horizontal)
			}
		}
	}

	static var previews: some View {
		Example()
	}
}
