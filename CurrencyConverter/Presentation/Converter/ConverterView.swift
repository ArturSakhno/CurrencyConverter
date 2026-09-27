import SwiftUI

struct ConverterView: View {
    let dependencies: DependencyContainer
    let coordinator: AppCoordinator
    
    @State var textField = "- $"

    @State private var status = "Loading…"

    var body: some View {
        VStack {
            Text("Exchange calculator")
            
            buildTop
            
            
            
            exchangeRate
            
            HStack {
                convertButton
                
                exchangeRate
            }
        }
    }
    
    var buildTop: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text("USDC")
                    .frame(alignment: .leading)
                    
                Spacer(minLength: 0)
                TextField("", text: $textField)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "0.circle")
                    .resizable()
                    .frame(width: 11, height: 11)
                Text("Digital dollars")
            }
        }
    }
    
    var convertButton: some View {
        ZStack {
            Circle()
                .fill(.green)
            Image("arrow.down")
                .resizable()
                .frame(width: 24, height: 24)
        }
        .frame(width: 40, height: 40)
    }
    
    var exchangeRate: some View {
        Text("1 USDc = 18.4097 MXN")
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .cornerRadius(20) /// make the background rounded
            .overlay( /// apply a rounded border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "#F5F5F4"), lineWidth: 1.5)
            )
    }
}

#Preview {
    ConverterView(
        dependencies: .init(),
        coordinator: .init()
    )
}
