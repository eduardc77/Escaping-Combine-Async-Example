//
//  OffsetObservingScrollView.swift
//  
//
//  Created by Eduard Caziuc on 05.03.2023.
//

import SwiftUI

/// View that observes its position within a given coordinate space,
/// and assigns that position to the specified Binding.
struct PositionObservingView<Content: View>: View {
	var coordinateSpace: CoordinateSpace
	@Binding var position: CGPoint
	@ViewBuilder var content: () -> Content

	var body: some View {
		content()
			.background(GeometryReader { geometry in
				let offset = geometry.frame(in: coordinateSpace).origin
				Color.clear.preference(
					key: PreferenceKey.self,
					value: ContentValue(offset: offset, size: geometry.size)
				)
			})
	}
}

enum PreferenceKey: SwiftUI.PreferenceKey {
	static var defaultValue = ContentValue()
	static func reduce(value: inout ContentValue, nextValue: () -> ContentValue) {
		// No-op
	}
}

/// Specialized scroll view that observes its content offset (scroll position)
/// and assigns it to the specified Binding.
struct OffsetObservingScrollView<Content: View>: View {
	var axes: Axis.Set = [.vertical]
	var showsIndicators = true
	@Binding var offset: CGPoint
	@ViewBuilder var content: () -> Content

	private let coordinateSpaceName = UUID()

	var body: some View {
		GeometryReader { geometry in
			ScrollView(axes, showsIndicators: showsIndicators) {
				ZStack {
					PositionObservingView(
						coordinateSpace: .named(coordinateSpaceName),
						position: $offset,
						content: content)

					Color.clear.frame(width: geometry.size.width, height: geometry.size.height)

				}
			}
			.coordinateSpace(name: coordinateSpaceName)

			.onPreferenceChange(PreferenceKey.self) { position in
				self.offset = getPosition(position, size: geometry.size)
			}
		}
	}

	/// Method that returns the size and offset of the content from ScrollView.
	///
	/// - Parameters:
	///   - contentValue: The size and offset of the content.
	func getPosition(_ contentValue: ContentValue, size: CGSize) -> CGPoint {
		let value: CGPoint = CGPoint(x: (-contentValue.offset.x / (contentValue.size.width - size.width)), y: (-contentValue.offset.y / (contentValue.size.height - size.height)))
		return value
	}
}

extension Comparable {
	@inlinable @inline(__always)
	public func clamped(to limits: ClosedRange<Self>) -> Self {
		Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
	}
}

/// The size and offset of the content.
public struct ContentValue: Equatable {
	var offset: CGPoint = .zero
	var size: CGSize = .zero
}

public extension GeometryProxy {
	/// A method that returns a value relative to the scroll offset. It is a value between 0 and 1.
	///
	/// - Parameters:
	///   - axes: The scroll view's scrollable axis. The default axis is the vertical axis.
	func scrollerValue(_ axes: Axis.Set = .vertical, coordinateSpaceName: String) -> CGPoint {
		let origin = self.frame(in: .named(coordinateSpaceName)).origin
		let value: CGPoint = CGPoint(x: (-origin.x / self.size.width).clamped(to: 0...1), y: (-origin.y / self.size.height).clamped(to: 0...1))
		return value
	}
}
