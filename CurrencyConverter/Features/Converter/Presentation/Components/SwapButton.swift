import DesignSystem
import SwiftUI

struct SwapButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                DS.Color.interactivePrimary
                    .clipShape(.circle)
                DS.Icon.arrowDown
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(DS.Color.onInteractivePrimary)
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

#if DEBUG
#Preview {
    SwapButton {}
}
#endif
