//
//  LazyStack.swift
//  
//
//  Created by Eduard Caziuc on 05.03.2023.
//

import SwiftUI

struct LazyStack<Content>: View where Content: View {

	/// The scroll view's scrollable axis. The default axis is the vertical axis.
	private var axes: Axis.Set = .vertical

	/// The distance between adjacent subviews, or `nil` if you want the stack to choose a default
	/// distance for each pair of subviews.
	private var spacing: CGFloat?

	/// The view builder that creates the scrollable view, Pass a view that conforms to ScrollerContent.
	@ViewBuilder private var content: () -> Content

	/// Initializes `LazyStack`
	///
	/// - Parameters:
	///   - axes: The scroll view's scrollable axis. The default axis is the vertical axis.
	///   - spacing: The distance between adjacent subviews, or `nil` if you want the stack to choose a default
	///     distance for each pair of subviews.
	///   - content: The view builder that creates the scrollable view, Pass a view that conforms to ScrollerContent.
	public init(_ axes: Axis.Set = .vertical, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
		self.axes = axes
		self.spacing = spacing
		self.content = content
	}

	var body: some View {
		if axes == .vertical {
			LazyVStack(alignment: .leading, spacing: spacing) {
				content()
			}
		} else {
			LazyHStack(alignment: .top, spacing: spacing) {
				content()
			}
		}
	}
}

struct SwiftUIView_Previews: PreviewProvider {
	static var previews: some View {
		VStack(spacing: 16) {
			LazyStack(.horizontal, spacing: 16) {
				Text("Horizontal 1")
				Text("Horizontal 2")
			}
			LazyStack(.vertical, spacing: 16) {
				Text("Vertical 1")
				Text("Vertical 2")
			}
		}
		.padding()
	}
}
