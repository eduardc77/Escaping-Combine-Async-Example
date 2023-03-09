//
//  ScaleButtonStyle.swift
//  
//
//  Created by Eduard Caziuc on 05.03.2023.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
	 func makeBody(configuration: Configuration) -> some View {
		  configuration.label
				.scaleEffect(configuration.isPressed ? 0.96 : 1)
				.animation(.easeInOut, value: configuration.isPressed)
	 }
}

extension ButtonStyle where Self == ScaleButtonStyle {
	static var scale: ScaleButtonStyle { .init() }
}
