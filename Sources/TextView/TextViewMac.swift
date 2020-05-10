#if os(macOS)

import SwiftUI

@available(macOS 10.15, *)
public struct TextView: View {
    public struct Representable: NSViewRepresentable {
        public final class Coordinator: NSObject, NSTextViewDelegate {
            private let parent: Representable
            
            public init(_ parent: Representable) {
                self.parent = parent
            }
            
            private func setIsEditing(to value: Bool) {
                DispatchQueue.main.async {
                    self.parent.isEditing = value
                }
            }
            
            public func textViewDidChange(_ textView: NSTextView) {
                parent.text = textView.string
            }
            
            public func textDidBeginEditing(_ notification: Notification) {
                setIsEditing(to: true)
            }
            
            public func textDidEndEditing(_ notification: Notification) {
                setIsEditing(to: false)
            }
        }
        
        @Binding private var text: String
        @Binding private var isEditing: Bool
        
        private let textAlignment: TextAlignment
        private let font: NSFont?
        private let textColor: NSColor
        private let backgroundColor: NSColor
        private let autocorrection: Autocorrection
        private let isEditable: Bool
        private let isSelectable: Bool
        private let shouldWaitUntilCommit: Bool
        
        public init(
            text: Binding<String>,
            isEditing: Binding<Bool>,
            textAlignment: TextAlignment,
            font: NSFont?,
            textColor: NSColor,
            backgroundColor: NSColor,
            autocorrection: Autocorrection,
            isEditable: Bool,
            isSelectable: Bool,
            shouldWaitUntilCommit: Bool
        ) {
            _text = text
            _isEditing = isEditing
            
            self.textAlignment = textAlignment
            self.font = font
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.autocorrection = autocorrection
            self.isEditable = isEditable
            self.isSelectable = isSelectable
            self.shouldWaitUntilCommit = shouldWaitUntilCommit
        }
        
        public func makeCoordinator() -> Coordinator {
            .init(self)
        }
        
        public func makeNSView(context: Context) -> NSTextView {
            let textView = NSTextView()
            textView.delegate = context.coordinator
            return textView
        }
        
        public func updateNSView(_ textView: NSTextView, context _: Context) {
            if !shouldWaitUntilCommit || !textView.hasMarkedText() {
                textView.string = text
            }
            textView.textStorage?.setAlignment(
                textAlignment,
                range: NSRange(location: 0, length: textView.string.count)
            )
            textView.font = font
            textView.textColor = textColor
            textView.backgroundColor = backgroundColor
            if (autocorrection == .yes) != textView.isAutomaticSpellingCorrectionEnabled {
                textView.toggleAutomaticSpellingCorrection(nil)
            }
            textView.isEditable = isEditable
            textView.isSelectable = isSelectable
            
            DispatchQueue.main.async {
                _ = self.isEditing
                    ? textView.becomeFirstResponder()
                    : textView.resignFirstResponder()
            }
        }
    }
    
    public typealias TextAlignment = NSTextAlignment
    public enum Autocorrection {
        case `default` // NSTextView doesn't support this. Treated as no.
        case yes
        case no
    }
        
    @Binding private var text: String
    @Binding private var isEditing: Bool
    
    private let placeholder: String?
    private let textAlignment: TextAlignment
    private let placeholderAlignment: Alignment
    private let placeholderHorizontalPadding: CGFloat
    private let placeholderVerticalPadding: CGFloat
    private let font: NSFont?
    private let textColor: NSColor
    private let placeholderColor: Color
    private let backgroundColor: NSColor
    private let autocorrection: Autocorrection
    private let isEditable: Bool
    private let isSelectable: Bool
    private let shouldWaitUntilCommit: Bool
    
    public init(
        text: Binding<String>,
        isEditing: Binding<Bool>,
        placeholder: String? = nil,
        textAlignment: TextAlignment = .left,
        placeholderAlignment: Alignment = .topLeading,
        placeholderHorizontalPadding: CGFloat = 4.5,
        placeholderVerticalPadding: CGFloat = 7,
        font: NSFont? = nil,
        textColor: NSColor = .labelColor,
        placeholderColor: Color = .init(NSColor.placeholderTextColor),
        backgroundColor: NSColor = .clear,
        autocorrection: Autocorrection = .default,
        isSecure: Bool = false,
        isEditable: Bool = true,
        isSelectable: Bool = true,
        isScrollingEnabled: Bool = true,
        isUserInteractionEnabled: Bool = true,
        shouldWaitUntilCommit: Bool = true
    ) {
        _text = text
        _isEditing = isEditing
        
        self.placeholder = placeholder
        self.textAlignment = textAlignment
        self.placeholderAlignment = placeholderAlignment
        self.placeholderHorizontalPadding = placeholderHorizontalPadding
        self.placeholderVerticalPadding = placeholderVerticalPadding
        self.font = font
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.backgroundColor = backgroundColor
        self.autocorrection = autocorrection
        self.isEditable = isEditable
        self.isSelectable = isSelectable
        self.shouldWaitUntilCommit = shouldWaitUntilCommit
    }
    
    private var _placeholder: String? {
        text.isEmpty ? placeholder : nil
    }
    
    private var representable: Representable {
        .init(
            text: $text,
            isEditing: $isEditing,
            textAlignment: textAlignment,
            font: font,
            textColor: textColor,
            backgroundColor: backgroundColor,
            autocorrection: autocorrection,
            isEditable: isEditable,
            isSelectable: isSelectable,
            shouldWaitUntilCommit: shouldWaitUntilCommit
        )
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                self.representable
                self._placeholder.map { placeholder in
                    Text(placeholder)
                        .font(self.font != nil ? .init(self.font!) : Font.body)
                        .foregroundColor(self.placeholderColor)
                        .padding(.horizontal, self.placeholderHorizontalPadding)
                        .padding(.vertical, self.placeholderVerticalPadding)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            alignment: self.placeholderAlignment
                    )
                        .onTapGesture {
                            self.isEditing = true
                    }
                }
            }
        }
    }
}

#endif
