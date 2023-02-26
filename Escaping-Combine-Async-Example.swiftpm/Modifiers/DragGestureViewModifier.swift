//
//  DragGestureViewModifier.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 25.02.2023.
//

import SwiftUI

struct DragGestureViewModifier: ViewModifier {
	@State var offset: CGSize = .zero
	let axes: Axis.Set
	let resets: Bool
	let animation: Animation
	let onEnded: (() -> ())?

	@State private var lastOffset: CGSize = .zero

	func body(content: Content) -> some View {
		content
			.offset(getOffset(offset: offset))
			.simultaneousGesture(
				DragGesture(coordinateSpace: .global)

					.onChanged { value in
						withAnimation(animation) {
							offset = CGSize(
								width: lastOffset.width + value.translation.width,
								height: lastOffset.height + value.translation.height)
						}
					}

					.onEnded { value in
						onEnded?()
						withAnimation(animation) {
							if !resets {
								lastOffset = CGSize(
									width: lastOffset.width + value.translation.width,
									height: lastOffset.height + value.translation.height)
							} else {
								offset = .zero
								lastOffset = .zero
							}
						}
					}
			)
			.onChange(of: resets) { resets in
				if resets {
					offset = .zero
					lastOffset = .zero
				}
			}
	}

	private func getOffset(offset: CGSize) -> CGSize {
		switch axes {
		case .vertical:
			return CGSize(width: 0, height: offset.height)
		case .horizontal:
			return CGSize(width: offset.width, height: 0)
		default:
			return offset
		}
	}
}

public extension View {
	/// Add a DragGesture to a View.
	///
	/// DragGesture is added as a simultaneousGesture, to not interfere with other gestures Developer may add.
	///
	/// - Parameters:
	///   - offset: Bind the offset to have access outside the view modifier.
	///   - resets: If the View should reset to starting state onEnded.
	///   - animation: The drag animation.
	///   - onEnded: The action to perform when this gesture’s value ends.
	///
	func withDragGesture(
		resets: Bool = false,
		_ axes: Axis.Set = [.horizontal, .vertical],
		animation: Animation = .default,
		onEnded: (() -> ())? = nil) -> some View {
			modifier(DragGestureViewModifier(axes: axes, resets: resets, animation: animation, onEnded: onEnded))
		}
}


 // MARK: - Previews

struct DragGestureViewModifier_Previews: PreviewProvider {
	struct ExampleView: View {
		@State var offset: CGSize = .zero

		var body: some View {
			AsyncImageView(urlString: "https://picsum.photos/1000")
				.withDragGesture(resets: true)
		}
	}

	static var previews: some View {
		ExampleView()
			.previewDevice("iPhone 14 Pro")
	}
}
