//
//  HeatmapView.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 21/08/25.
//

import SwiftUI

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
