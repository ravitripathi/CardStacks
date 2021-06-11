//
//  CardContainerView.swift
//  CardStacks
//
//  Created by Ravi Tripathi on 11/06/21.
//

import UIKit


/// Denotes the states supported by a card
public enum CardState {
    case expanded
    case collapsed
}

protocol CardProtocol {
    var state: CardState { get set }
}

class CardContainerView: UIView, CardProtocol {
    
    let imageView = UIImageView()
    var state: CardState = .collapsed {
        didSet {
            imageView.image = getImageForCurrentState()
        }
    }
    
    /// Initializes a `CardContainerView`. Pass your own view over here. This container would pick up the background color of the passed view, and add an arrow on the top left which indicates its state (collapsed/expanded)
    /// - Parameter view: Custom View to be displayed
    convenience init(withView view: UIView) {
        self.init()
        self.state = .collapsed
        self.backgroundColor = view.backgroundColor
        self.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 8.0
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = getImageForCurrentState()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.white
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
        ])
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    func toggleState() {
        if state == .collapsed {
            state = .expanded
        } else {
            state = .collapsed
        }
    }
    
    func getImageForCurrentState() -> UIImage? {
        if state == .collapsed {
            return UIImage(systemName: "arrowtriangle.up.circle.fill")
        } else {
            return UIImage(systemName: "arrowtriangle.down.circle.fill")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.cornerRadius = 8.0
    }
}
