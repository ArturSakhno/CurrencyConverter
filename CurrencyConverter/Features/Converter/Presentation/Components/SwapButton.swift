import DesignSystem
import SwiftUI

struct SwapButton: View {
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(.interactivePrimary)
                DS.Icon.arrowDown
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.onInteractivePrimary)
                    .frame(
                        width: DS.Size.icon,
                        height: DS.Size.icon
                    )
            }
            .frame(
                width: DS.Size.swapButton,
                height: DS.Size.swapButton
            )
        }
    }
}

#Preview {
    SwapButton {}
}
