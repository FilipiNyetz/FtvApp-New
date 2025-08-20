//
//  ComFundo.swift
//  FtvApp
//
//  Created by Cauê Carneiro on 20/08/25.
//


import SwiftUI
import UniformTypeIdentifiers

// MARK: - Modelo vindo do watch
struct SessionData {
    var points: Int
    var score: Int
    var elapsed: TimeInterval
    var maxHeightCM: Int
    var avgBPM: Int
    var maxSpeedKMH: Int
    var athleteName: String
    var sport: String
}

// MARK: - Helpers

// MARK: - Heatmap
struct HeatmapView: View {
    let points: [CGPoint]
    let grid: Int
    
    var body: some View {
        GeometryReader { _ in
            Canvas { ctx, size in
                guard !points.isEmpty else { return }
                
                var bins = Array(repeating: 0.0, count: grid*grid)
                for p in points {
                    let x = max(0, min(1, p.x))
                    let y = max(0, min(1, p.y))
                    let i = Int(x * CGFloat(grid - 1))
                    let j = Int(y * CGFloat(grid - 1))
                    bins[j*grid + i] += 1.0
                }
                if let maxBin = bins.max(), maxBin > 0 {
                    let cw = size.width / CGFloat(grid)
                    let ch = size.height / CGFloat(grid)
                    for j in 0..<grid {
                        for i in 0..<grid {
                            let v = bins[j*grid + i] / maxBin
                            if v <= 0 { continue }
                            let rect = CGRect(x: CGFloat(i)*cw, y: CGFloat(j)*ch, width: cw, height: ch)
                        }
                    }
                }
            }
        }
        .drawingGroup()
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Compartilhamento
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: - Poster / Template
struct SessionPosterView: View {
    @State private var showShare = false
    @State private var renderedImage: UIImage?
    
    var data: SessionData
    
    private let neon = Color.brandGreen
    private let card = Color.white.opacity(0.06)
    private let stroke = Color.white.opacity(0.16)
    private let textSecondary = Color.white.opacity(0.7)
    
    var body: some View {
        let base = posterBody
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(Color.black) // fixado com fundo
        
        VStack(spacing: 12) {
            base
                .cornerRadius(24)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    exportImage(of: base)
                } label: {
                    Label("Exportar", systemImage: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShare) {
            if let image = renderedImage {
                ShareSheet(items: [image])
            }
        }
    }
    
    private var posterBody: some View {
        VStack(spacing: 16) {
            // Top bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(neon)
                    Text("\(data.points)")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .semibold))
                }
                Spacer()
                VStack(spacing: 4) {
                    Text("TEMPO")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(textSecondary)
                    Text(data.elapsed.mmssSS)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "shield.checkerboard")
                        .foregroundStyle(neon)
                    Text("\(data.score)")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            
            // Card com heatmap
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(card)
                    VStack(spacing: 0) {
                        Rectangle().fill(stroke).frame(height: 1)
                            .opacity(0.6).padding(.top, 48)
                        Spacer()
                        Rectangle().fill(stroke).frame(height: 1)
                            .opacity(0.6).padding(.bottom, 48)
                    }
                    HStack {
                        Spacer()
                        Rectangle().fill(stroke).frame(width: 1).opacity(0.6)
                        Spacer()
                    }
                }
                .frame(height: 360)
                Rectangle()
                    .fill(stroke)
                    .frame(height: 1)
                    .opacity(0.6)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            
            // Métricas
            HStack {
                metric(icon: "arrow.up.arrow.down", value: "\(data.maxHeightCM)", unit: "cm", label: "ALTURA MÁX")
                Spacer()
                metric(icon: "heart.fill", value: "\(data.avgBPM)", unit: "bpm", label: "BATIMENTO")
                Spacer()
                metric(icon: "wind", value: "\(data.maxSpeedKMH)", unit: "km/h", label: "VELOCIDADE MÁX")
            }
            .padding(.top, 4)
            
            // Nome
            VStack(spacing: 4) {
                Text(data.athleteName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(neon)
                Text(data.sport.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(textSecondary)
                    .tracking(1.2)
            }
            .padding(.top, 8)
        }
    }
    
    @ViewBuilder
    private func metric(icon: String, value: String, unit: String, label: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(neon)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value).font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text(unit).font(.system(size: 12, weight: .semibold)).foregroundStyle(textSecondary)
                }
            }
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(textSecondary)
        }
    }
    
    private func exportImage(of view: some View) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = true  // sempre com fundo
        if let uiImage = renderer.uiImage {
            self.renderedImage = uiImage
            self.showShare = true
        }
    }
}

// Preview
struct SessionPosterView_Previews: PreviewProvider {
    static var previews: some View {
        let data = SessionData(
            points: 0,
            score: 0,
            elapsed: 0,
            maxHeightCM: 0,
            avgBPM: 0,
            maxSpeedKMH: 0,
            athleteName: "Se7e",
            sport: "FUTVÔLEI"
        )
        NavigationStack {
            SessionPosterView(data: data)
                .preferredColorScheme(.dark)
                .padding()
        }
    }
}
