import DesignSystem
import SwiftUI

struct CurrencyCodeButton: View {
    let code: String
    let showsChevron: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: .zero) {
                Text(code)
                    .textStyle(.h3)
                    .foregroundStyle(DS.Color.textPrimary)
                if showsChevron {
                    DS.Icon.chevronDown
                        .resizable()
                        .foregroundStyle(DS.Color.iconPrimary)
                        .frame(width: DS.Size.icon, height: DS.Size.icon)
                }
            }
            .fixedSize()
        }
        .disabled(!showsChevron)
    }
}

#Preview("Selectable") {
    CurrencyCodeButton(code: "MXN", showsChevron: true) {}
}

#Preview("Base currency") {
    CurrencyCodeButton(code: "USDc", showsChevron: false) {}
}
