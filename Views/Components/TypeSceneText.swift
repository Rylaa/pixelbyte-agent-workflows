import SwiftUI

/// TypeSceneText component from Figma design
/// File: bt65gbJ6sSdKRP4x3IY151, Node: 10203:16369
/// Features: Page control at top, Angular gradient text, semi-transparent borders, discover section
@available(iOS 15.0, *)
struct TypeSceneText: View {
    var body: some View {
        ZStack {
            // Background with radial gradient overlay
            ZStack {
                Color(hex: "#150200")

                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(hex: "#f02912"), location: 0.0),
                        .init(color: Color(hex: "#150200"), location: 1.0)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
                .opacity(0.2)
            }

            VStack(spacing: 0) {
                // Page control dots at TOP (user's reported issue - was missing)
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)

                // Header area
                HStack(spacing: 8) {
                    Text("Create")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    HStack(spacing: 8) {
                        // Star rating display
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(hex: "#ffd100"))
                                .font(.system(size: 16))

                            Text("10")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(40)

                        // PRO badge
                        Text("PRO")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#007a5a"))
                            .cornerRadius(32)
                    }
                }
                .frame(height: 32)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                // Options row
                HStack(spacing: 16) {
                    // Image to Video button (primary)
                    HStack(spacing: 8) {
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        Text("Image to Video")
                            .font(.custom("Poppins", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#e5bf8e").opacity(0.4),
                                Color(hex: "#e5bf8e").opacity(0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.7),
                                        Color.white.opacity(0.2)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.7
                            )
                    )
                    .cornerRadius(32)

                    // Icon buttons
                    ForEach(["camera", "photo.on.rectangle", "video", "gearshape"], id: \.self) { iconName in
                        Image(systemName: iconName)
                            .foregroundColor(.white.opacity(0.3))
                            .font(.system(size: 20))
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                // Main image placeholder
                VStack {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white.opacity(0.3))
                        .frame(width: 100, height: 100)
                }
                .frame(width: 256, height: 256)
                .background(Color.black.opacity(0.3))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#ffaca9"), lineWidth: 1)
                )
                .overlay(
                    // Image action buttons (top-right)
                    HStack(spacing: 8) {
                        ForEach(["arrow.triangle.2.circlepath", "xmark"], id: \.self) { iconName in
                            Image(systemName: iconName)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .frame(width: 24, height: 24)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(32)
                        }
                    }
                    .padding(4),
                    alignment: .topTrailing
                )
                .padding(.bottom, 12)

                // Text input area with gradient text
                VStack(spacing: 0) {
                    Text("Type a scene to generate your video")
                        .font(.custom("Inter", size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(
                            AngularGradient(
                                stops: [
                                    Gradient.Stop(color: Color(hex: "#bc82f3"), location: 0.1673),
                                    Gradient.Stop(color: Color(hex: "#f4b9ea"), location: 0.2365),
                                    Gradient.Stop(color: Color(hex: "#8d98ff"), location: 0.3518),
                                    Gradient.Stop(color: Color(hex: "#aa6eee"), location: 0.5815),
                                    Gradient.Stop(color: Color(hex: "#ff6777"), location: 0.697),
                                    Gradient.Stop(color: Color(hex: "#ffba71"), location: 0.8095),
                                    Gradient.Stop(color: Color(hex: "#c686ff"), location: 0.9241)
                                ],
                                center: .center
                            )
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 32)

                    // Character count
                    Text("10000")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                }
                .frame(width: 358, height: 120)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.2)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .opacity(0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.2)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.7
                        )
                )
                .cornerRadius(16)
                .padding(.bottom, 12)

                // Veo 3 button
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "sparkles")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                        )
                    Text("Veo 3")
                        .font(.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundColor(.white)
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .frame(width: 358, height: 40)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.2)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .opacity(0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.2)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.7
                        )
                )
                .cornerRadius(12)
                .padding(.bottom, 8)

                // 5s and 720P buttons
                HStack(spacing: 8) {
                    ForEach(["5s", "720P"], id: \.self) { label in
                        HStack(spacing: 2) {
                            Image(systemName: label == "5s" ? "clock" : "rectangle.on.rectangle")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                            Text(label)
                                .font(.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.2)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .opacity(0.1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.7),
                                            Color.white.opacity(0.2)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 0.7
                                )
                        )
                        .cornerRadius(12)
                    }
                }
                .frame(width: 358)
                .padding(.bottom, 24)

                // Generate button (red)
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    Text("Generate")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: 358, height: 48)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#ffae95"),
                            Color(hex: "#ff0800")
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(32)
                .padding(.bottom, 24)

                // Discover section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Discover")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)

                    // 3x2 grid of thumbnails
                    VStack(spacing: 8) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 8) {
                                ForEach(0..<2) { col in
                                    VStack {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.white.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                    }
                                    .frame(width: 175, height: 120)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: Color(hex: "#170d23").opacity(0), location: 0.43),
                                                .init(color: Color(hex: "#170d23"), location: 1.0)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(hex: "#ffaca9"), lineWidth: 1)
                                    )
                                    .overlay(
                                        // Model badge (bottom-left)
                                        HStack(spacing: 2) {
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 16, height: 16)
                                                .overlay(
                                                    Image(systemName: "sparkles")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 8))
                                                )
                                            Text(col == 0 ? "Veo 3" : "Heygen")
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, 2)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.7),
                                                    Color.white.opacity(0.2)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .opacity(0.1)
                                        )
                                        .cornerRadius(32)
                                        .padding(4),
                                        alignment: .bottomLeading
                                    )
                                    .overlay(
                                        // Heart icon (bottom-right)
                                        Image(systemName: "heart")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                            .padding(4)
                                            .rotationEffect(.degrees(180)),
                                        alignment: .bottomTrailing
                                    )
                                }
                            }
                        }
                    }
                }
                .frame(width: 358)
            }
            .padding(.top, 16)
        }
        .frame(width: 390, height: 844)
        .cornerRadius(50.0)
        .clipped()
    }
}

/// Color extension to support hex color strings
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    if #available(iOS 15.0, *) {
        TypeSceneText()
    } else {
        Text("iOS 15.0+ required for AngularGradient")
    }
}
