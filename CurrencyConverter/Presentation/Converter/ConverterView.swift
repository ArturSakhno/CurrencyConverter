import SwiftUI

struct ConverterView: View {
    let dependencies: DependencyContainer
    let coordinator: AppCoordinator
    
    @State var textField = "- $"

    var body: some View {
        VStack(alignment: .leading) {
            Text("Exchange calculator")
                .padding(.horizontal, 16)
                .font(.system(size: 32))
                .fontWeight(.medium)
                
            buildTop
            
            HStack {
                SwapButton {}
                
                ExchangeRateView()
            }
        }
        
        .padding(.top, 126)
        .ignoresSafeArea(edges: .top)
        .background(.red)
        Spacer()
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
}

#Preview {
    ConverterView(
        dependencies: .init(),
        coordinator: .init()
    )
}
