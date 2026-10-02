import DesignSystem
import SwiftUI

struct SelectionIndicator: View {
    let isSelected: Bool

    var body: some View {
        Group {
            if isSelected {
                ZStack {
                    Circle()
                        .fill(DS.Color.interactivePrimary)

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
        .frame(width: DS.Size.icon, height: DS.Size.icon)
    }
}

#Preview {
    HStack(spacing: DS.Spacing.m) {
        SelectionIndicator(isSelected: true)
        SelectionIndicator(isSelected: false)
    }
    .padding(DS.Spacing.m)
}
