import SwiftUI

/// Root screen: full-screen AR mirror + a single toggle button that
/// switches the simulated "lens tint" overlay on the eyes on/off.
struct ContentView: View {
    @State private var lensOn: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Live camera + face-tracked eye overlay
            ARFaceMirrorView(lensOn: $lensOn)
                .ignoresSafeArea()

            // Simple control bar
            VStack(spacing: 12) {
                Text(lensOn ? "렌즈 착용 (Blue Tint ON)" : "렌즈 미착용")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())

                Button {
                    withAnimation { lensOn.toggle() }
                } label: {
                    Text(lensOn ? "렌즈 제거" : "렌즈 착용")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(lensOn ? Color.red.opacity(0.85) : Color.teal)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
    }
}
