//
//  DragGestureViewModifier.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 25.02.2023.
//

import SwiftUI

struct DragGestureViewModifier: ViewModifier {
	@Binding var offset: CGSize
	let axes: Axis.Set
	let resets: Bool
	let animation: Animation
	let onEnded: ((_ dragOffset: CGSize) -> ())?

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
						if !resets {
							onEnded?(lastOffset)
						} else {
							onEnded?(value.translation)
						}

						withAnimation(animation) {
							if !resets {
								lastOffset = CGSize(
									width: lastOffset.width + value.translation.width,
									height: lastOffset.height + value.translation.height)
							} else {
								offset = .zero
							}
						}
					}
			)
			.onChange(of: offset) { offset in
				if offset == .zero {
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
	///   - offset: Binds the offset to have access outside the view modifier.
	///   - axes: Determines the drag axes. Default allows for both horizontal and vertical movement.
	///   - resets: If the View should reset to starting state onEnded.
	///   - animation: The drag animation.
	///   - onEnded: The action to perform when this gesture’s value ends. The action closure’s parameter contains the gesture’s new value.
	///
	func withDragGesture(
		offset: Binding<CGSize>,
		_ axes: Axis.Set = [.horizontal, .vertical],
		resets: Bool = false,
		animation: Animation = .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.0),
		onEnded: ((_ dragOffset: CGSize) -> ())? = nil) -> some View {
			modifier(DragGestureViewModifier(offset: offset, axes: axes, resets: resets, animation: animation, onEnded: onEnded))
		}
}


// MARK: - Previews

struct DragGestureViewModifier_Previews: PreviewProvider {
	struct ExampleView: View {
		@State var offset: CGSize = .zero

		var body: some View {
			AsyncImageView(urlString: "https://picsum.photos/1000")
				.withDragGesture(offset: $offset, resets: true)
		}
	}

	static var previews: some View {
		ExampleView()
			.previewDevice("iPhone 14 Pro")
	}
}
