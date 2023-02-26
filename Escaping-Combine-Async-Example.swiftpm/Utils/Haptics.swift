//
//  Haptics.swift
//  Escaping-Combine-Async-Example
//
//  Created by Eduard Caziuc on 25.02.2023.
//

import SwiftUI

enum HapticOption: String, CaseIterable {
	case success, error, warning, selection, light, medium, heavy, soft, rigid, none
}

struct Haptics {
	static let notificationGenerator = UINotificationFeedbackGenerator()
	static let selectionGenerator = UISelectionFeedbackGenerator()
	static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
	static let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
	static let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
	static let softGenerator = UIImpactFeedbackGenerator(style: .soft)
	static let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)

	/// Prepare the appropriate haptic generator prior to haptic occurrence.
	///
	/// Call prepare() before the event that triggers feedback. The system needs time to prepare the Taptic Engine for minimal latency.
	/// Calling prepare() and then immediately triggering feedback (without any time in between) does not improve latency.
	///
	/// - Parameter option: If providing an option, only prepare that option. If nil, prepare all options.
	static func prepare(option: HapticOption? = nil) {
		guard let option = option else {
			notificationGenerator.prepare()
			selectionGenerator.prepare()
			lightGenerator.prepare()
			mediumGenerator.prepare()
			heavyGenerator.prepare()
			softGenerator.prepare()
			rigidGenerator.prepare()
			return
		}

		switch option {
		case .success, .error, .warning: notificationGenerator.prepare()
		case .selection: selectionGenerator.prepare()
		case .light: lightGenerator.prepare()
		case .medium: mediumGenerator.prepare()
		case .heavy: heavyGenerator.prepare()
		case .soft: softGenerator.prepare()
		case .rigid: rigidGenerator.prepare()
		case .none: break
		}
	}

	/// Immediately cause haptic occurrence.
	/// - Warning: It is recommended to call 'Haptics.prepare' prior to 'occurred' to remove latency issues. However, haptic feedback will occur regardless.
	static func occurred(with option: HapticOption) {
		switch option {
		case .success: notificationGenerator.notificationOccurred(.success)
		case .error: notificationGenerator.notificationOccurred(.error)
		case .warning: notificationGenerator.notificationOccurred(.warning)
		case .selection: selectionGenerator.selectionChanged()
		case .light: lightGenerator.impactOccurred()
		case .medium: mediumGenerator.impactOccurred()
		case .heavy: heavyGenerator.impactOccurred()
		case .soft: softGenerator.impactOccurred()
		case .rigid: rigidGenerator.impactOccurred()
		case .none: break
		}
	}
}

struct HapticViewModifier: ViewModifier {
	let option: HapticOption
	@Binding var impactOccurred: Bool

	func body(content: Content) -> some View {
		content
			.onAppear {
				Haptics.prepare(option: option)
			}
			.onChange(of: impactOccurred) { impactOccurred in
				if impactOccurred {
					Haptics.occurred(with: option)
				}
				self.impactOccurred = false
			}
	}
}

extension View {
	/// Add Haptic support to a View.
	///
	/// A vibration will occur every onChangeOf the parameter. The generator will be automatically prepared when the view Appears.
	func withHaptic(option: HapticOption = .selection, onChangeOf impactOccurred: Binding<Bool>) -> some View {
		modifier(HapticViewModifier(option: option, impactOccurred: impactOccurred))
	}
}

struct HapticViewModifier_Previews: PreviewProvider {
	struct PreviewView: View {
		@State private var isOn: Bool = false

		var body: some View {
			Color.red
				.ignoresSafeArea()
				.withHaptic(onChangeOf: $isOn)
		}
	}

	static var previews: some View {
		PreviewView()
	}
}
