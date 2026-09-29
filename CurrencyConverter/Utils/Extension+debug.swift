import SwiftUI

struct Debug: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.quaternary, in: Capsule())
    }
}

extension View {
    func debug() -> some View {
        self.background(.red)
    }
}

#Preview {
    Text("Hello, world!")
        .modifier(Debug())
}
