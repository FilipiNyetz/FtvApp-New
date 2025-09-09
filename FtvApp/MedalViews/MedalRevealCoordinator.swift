//
//  MedalRevealCoordinator.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 02/09/25.
//

import UIKit

class MedalRevealCoordinator {
    static func showMedal(_ medalName: String, on viewController: UIViewController) {
        guard let medalImage = UIImage(named: medalName) else { return }
        
        let medalView = MedalRevealView(medalImage: medalImage)
        medalView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(medalView)
        
        NSLayoutConstraint.activate([
            medalView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            medalView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
            medalView.widthAnchor.constraint(equalToConstant: 200),
            medalView.heightAnchor.constraint(equalTo: medalView.widthAnchor)
        ])
        
        medalView.reveal()
        
        // Remover medalha após a animação (opcional)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            medalView.removeFromSuperview()
        }
    }
}

