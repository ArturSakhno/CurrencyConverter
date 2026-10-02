import DesignSystem
import SwiftUI

struct SelectionIndicator: View {
    let isSelected: Bool

    var body: some View {
        root
            .frame(width: DS.Size.icon, height: DS.Size.icon)
    }

    @ViewBuilder var root: some View {
        if isSelected {
            ZStack {
                DS.Color.interactivePrimary
                    .clipShape(.circle)

                DS.Icon.checkmark
                    .resizable()
                    .foregroundStyle(DS.Color.bgPrimary)
            }
        } else {
            Circle()
                .stroke(
                    DS.Color.selectorUnselectedBorder,
                    lineWidth: DS.BorderWidth.selector
                )
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: DS.Spacing.m) {
        SelectionIndicator(isSelected: true)
        SelectionIndicator(isSelected: false)
    }
    .padding(DS.Spacing.m)
}
#endif
