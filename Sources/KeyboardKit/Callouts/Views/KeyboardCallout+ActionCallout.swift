//
//  KeyboardCallout+ActionCallout.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension KeyboardCallout {

    /// This callout can show secondary callout actions when
    /// long pressing input keys with secondary actions.
    ///
    /// This callout will adjust the button corner radius to
    /// fit the style's or the keyboard layout configuration.
    struct ActionCallout: View {
        
        /// Create an action callout.
        ///
        /// - Parameters:
        ///   - calloutContext: The callout context to use.
        ///   - keyboardContext: The keyboard context to use.
        public init(
            calloutContext: KeyboardCalloutContext,
            keyboardContext: KeyboardContext
        ) {
            self._calloutContext = .init(wrappedValue: calloutContext)
            self._keyboardContext = .init(wrappedValue: keyboardContext)
        }

        @ObservedObject
        private var calloutContext: KeyboardCalloutContext

        @ObservedObject
        private var keyboardContext: KeyboardContext

        @Environment(\.emojiKeyboardStyle)
        private var emojiStyle

        @Environment(\.keyboardCalloutStyle)
        private var style

        public var body: some View {
            Button(action: calloutContext.resetSecondaryActions) {
                VStack(alignment: alignment, spacing: 0) {
                    calloutBubble
                    calloutButton
                }
            }
            .buttonStyle(.plain)
            .compositingGroup()
            .opacity(isActive ? 1 : 0)
            .keyboardCalloutShadow(style: style)
            .position(position)
            .offset(y: verticalOffset)
        }
    }
}

private extension KeyboardCallout.ActionCallout {

    var calloutBubble: some View {
        HStack(spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.offset) {
                calloutItem(for: $0.element)
                    .frame(width: itemSize.width, height: itemSize.height)
                    .background(isSelected($0.offset) ? style.selectedBackgroundColor : .clear)
                    .foregroundColor(isSelected($0.offset) ? style.selectedForegroundColor : style.foregroundColor)
                    .cornerRadius(style.cornerRadius)
                    .padding(.horizontal, style.actionItemPadding.width)
                    .padding(.vertical, style.actionItemPadding.height)
            }
        }
        .padding(.horizontal, style.curveSize.width)
        .background(style.backgroundColor)
        .cornerRadius(style.cornerRadius)
    }

    var calloutButton: some View {
        ButtonArea(
            frame: buttonFrame,
            buttonCornerRadius: style.buttonCornerRadius(for: keyboardContext)
        )
        .opacity(isPad ? 0 : 1)
        .rotation3DEffect(isLeading ? .zero : .degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
    }

    @ViewBuilder
    func calloutItem(for action: KeyboardAction) -> some View {
        switch action {
        case .character(let char): calloutItem(for: char)
        case .emoji(let emoji): calloutItem(for: emoji)
        default: EmptyView()
        }
    }

    func calloutItem(for char: String) -> some View {
        Text(char)
            .font(style.actionItemFont.font)
    }

    func calloutItem(for emoji: Emoji) -> some View {
        let style = emojiStyle(keyboardContext)
        return Text(emoji.char)
            .font(style.itemFont)
            .scaleEffect(style.itemScaleFactor)
            .frame(
                width: style.itemSize,
                height: style.itemSize,
                alignment: .center
            )
    }
}

private extension KeyboardCallout.ActionCallout {

    var actions: [KeyboardAction] {
        calloutContext.secondaryActions
    }

    var isActive: Bool {
        !actions.isEmpty
    }

    var isEmojiCallout: Bool {
        actions.first?.isEmojiAction ?? false
    }

    var isLeading: Bool {
        calloutContext.secondaryActionsAlignment == .leading
    }

    var isPad: Bool {
        keyboardContext.deviceTypeForKeyboard == .pad
    }

    func isSelected(_ offset: Int) -> Bool {
        calloutContext.secondaryActionsIndex == offset
    }
}

private extension KeyboardCallout.ActionCallout {

    var alignment: HorizontalAlignment {
        calloutContext.secondaryActionsAlignment
    }

    var buttonSize: CGSize {
        buttonFrame.size
    }

    var buttonFrame: CGRect {
        isEmojiCallout ? calloutContext.buttonFrame : buttonFrameForCharacters
    }

    var buttonFrameForCharacters: CGRect {
        let inset = style.buttonOverlayInset
        return calloutContext.buttonFrame
            .insetBy(dx: inset.width, dy: inset.height)
    }

    var itemSize: CGSize {
        let frameSize = buttonSize
        let widthScale = (actions.count == 1) ? 1.2 : 1
        let buttonSize = CGSize(width: frameSize.width * widthScale, height: frameSize.height)
        return buttonSize.limited(to: style.actionItemMaxSize)
    }

    var verticalOffset: CGFloat {
        style.offset?.y ?? style.standardVerticalOffset(for: keyboardContext.deviceTypeForKeyboard)
    }

    var position: CGPoint {
        CGPoint(x: positionX, y: positionY)
    }

    var positionX: CGFloat {
        let buttonWidth = itemSize.width
        let adjustment = (CGFloat(actions.count) * buttonWidth)/2
        let widthDiff = buttonWidth - buttonFrame.size.width
        let signedAdjustment = isLeading ? adjustment : -adjustment + buttonWidth - widthDiff
        return buttonFrame.origin.x + signedAdjustment
    }

    var positionY: CGFloat {
        buttonFrame.origin.y - style.actionItemPadding.height
    }
}

private extension KeyboardAction {
    
    var input: String? {
        switch self {
        case .character(let char): char
        default: nil
        }
    }
}

#Preview {

    let keyboardContext = KeyboardContext()
    let calloutContext1 = KeyboardCalloutContext()
    let calloutContext2 = KeyboardCalloutContext()

    func previewGroup<ButtonView: View>(
        view: ButtonView,
        context: KeyboardCalloutContext,
        alignment: HorizontalAlignment
    ) -> some View {
        keyboardContext.deviceTypeForKeyboard = .phone
        context.calloutService = .preview
        return view.overlay(
            GeometryReader { geo in
                Color.clear.onAppear {
                    context.updateSecondaryActions(
                        for: .character("a"),
                        in: geo,
                        alignment: alignment
                    )
                }
            }
        )
        .keyboardActionCalloutContainer(
            calloutContext: context,
            keyboardContext: keyboardContext
        )
    }

    return ZStack {
        Color.red
        VStack(spacing: 100) {
            previewGroup(
                view: Color.blue.frame(width: 40, height: 50),
                context: calloutContext1,
                alignment: .leading
            )
            previewGroup(
                view: Color.blue.frame(width: 40, height: 50),
                context: calloutContext2,
                alignment: .trailing
            )
        }
    }
    .keyboardCalloutStyle(.init(
        // callout: .preview2,
        selectedBackgroundColor: .purple
    ))
}
