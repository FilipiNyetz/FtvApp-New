//
//  MedalReviewView.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 02/09/25.
//

import UIKit

final class MedalRevealView: UIView {

    private let imageView = UIImageView()
    private var sparkleEmitter: CAEmitterLayer?

    init(medalImage: UIImage?) {
        super.init(frame: .zero)
        imageView.image = medalImage
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .clear
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        // Sombra para dar profundidade
        imageView.layer.shadowColor = UIColor.yellow.cgColor
        imageView.layer.shadowOpacity = 0.8
        imageView.layer.shadowRadius = 10
        imageView.layer.shadowOffset = .zero
        imageView.alpha = 0
    }

    func reveal(withDelay delay: TimeInterval = 0) {
        self.imageView.layer.removeAllAnimations()
        sparkleEmitter?.removeFromSuperlayer()
        
        guard let superview = self.superview else { return }
        
        let verticalOffset = (superview.bounds.height / 2) + (self.bounds.height / 2)
        var initialTransform = CATransform3DIdentity
        initialTransform.m34 = -1.0 / 500.0
        initialTransform = CATransform3DRotate(initialTransform, .pi, 0, 1, 0)
        initialTransform = CATransform3DTranslate(initialTransform, 0, verticalOffset, 0)

        self.imageView.layer.transform = initialTransform
        self.imageView.alpha = 0

        UIView.animate(
            withDuration: 1.2,
            delay: delay,
            options: [.curveEaseOut],
            animations: {
                var finalTransform = CATransform3DIdentity
                finalTransform.m34 = -1.0 / 500.0
                self.imageView.layer.transform = finalTransform
                self.imageView.alpha = 1
            },
            completion: { finished in
                if finished {
                    self.startSparkleAnimation()
                    self.startPulsingAnimation()
                }
            }
        )
    }

    private func createSparkleImage() -> CGImage? {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { _ in
            if let sparkleImage = UIImage(
                systemName: "sparkle"
            )?.withRenderingMode(.alwaysOriginal).withTintColor(.systemYellow) {
                sparkleImage.draw(in: CGRect(origin: .zero, size: size))
            }
        }

        return image.cgImage
    }

    private func startSparkleAnimation() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
        emitter.emitterSize = imageView.bounds.size
        emitter.emitterShape = .rectangle
        emitter.renderMode = .additive
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = createSparkleImage()
        
        // Sem filtro de cor, a imagem será exibida com sua cor original amarela
        
        emitterCell.birthRate = 5
        emitterCell.lifetime = 1.0
        emitterCell.velocity = 0
        emitterCell.scale = 0.6
        emitterCell.scaleRange = 0.3
        emitterCell.spin = 1.0
        emitterCell.spinRange = 1.5
        emitterCell.alphaSpeed = -1.0
        
        emitter.emitterCells = [emitterCell]
        
        let maskLayer = CALayer()
        maskLayer.frame = imageView.bounds
        maskLayer.contents = imageView.image?.cgImage
        emitter.mask = maskLayer
        
        imageView.layer.addSublayer(emitter)
        self.sparkleEmitter = emitter
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            emitter.birthRate = 0
        }
    }
    
    private func startPulsingAnimation() {
        let pulse = CABasicAnimation(keyPath: "position.y")
        pulse.fromValue = imageView.layer.position.y - 10 // sobe 5 pontos
        pulse.toValue = imageView.layer.position.y + 10    // desce 5 pontos
        pulse.duration = 0.8
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        imageView.layer.add(pulse, forKey: "pulseAnimation")
    }
}
