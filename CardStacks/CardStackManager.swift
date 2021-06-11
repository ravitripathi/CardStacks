//
//  CardStackManager.swift
//  CardStacks
//
//  Created by Ravi Tripathi on 11/06/21.
//

import UIKit

enum CardStackDisplayException: Error {
    // Thrown when number of cards are lesser than 2
    case tooFew(String)
    // Thrown when number of cards are greater than 2
    case tooMany(String)
}

class CardStackManager {
    private var parent: UIView
    private var children: [CardContainerView]
    private var cardHiddenConstraints = [NSLayoutConstraint]()
    private var cardVisibleConstraints = [NSLayoutConstraint]()
    
    
    /// Initialises the CardStackManager. After this, call `show()` to display the cards
    /// - Parameters:
    ///   - parent: The view on top of which the card stacks need to be shown. The first card will be displayed at an offset of 50 pts from the top of this view
    ///   - children: An array of `CardContainerView`s, which would be displayed in the order they are present in this array
    /// - Throws: An exception is thrown if the `children` array passed contains fewer than 2 or more than 4 children.
    public init(parent: UIView, children: [CardContainerView]) throws {
        self.parent = parent
        self.children = children
        if children.count < 2 {
            throw CardStackDisplayException.tooFew("Minimum 2 children need to be passed")
        } else if children.count > 4 {
            throw CardStackDisplayException.tooMany("A maximum of 4 children are supported")
        }
    }
    
    /// Displays the card stack
    public func show() {
        self.children.forEach{ self.parent.addSubview($0) }

        for (index, child) in children.enumerated() {
            cardHiddenConstraints.append(child.topAnchor.constraint(equalTo: parent.bottomAnchor, constant: -50))
            
            if (index == 0) { // first child
                cardVisibleConstraints.append(child.topAnchor.constraint(equalTo: parent.topAnchor, constant: 50))
                child.heightAnchor.constraint(equalTo: parent.heightAnchor).isActive = true
                child.isHidden = false
            } else {
                cardVisibleConstraints.append(child.topAnchor.constraint(equalTo: children[index - 1].topAnchor, constant: 50))
                child.heightAnchor.constraint(equalTo: parent.heightAnchor).isActive = true // exp
                child.isHidden = true
            }
            child.tag = index
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor).isActive = true
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor).isActive = true
        }
        cardHiddenConstraints[0].isActive = true
        self.parent.layoutIfNeeded()
    }
    
    
    /// Toggles the card shown between `.collapsed` or `.expanded` states. If the passed card is currently
    /// expanded, and contains another child while is also exanded, both cards are collapsed
    /// - Parameter card: The `CardContainerView` which needs to be toggled
    public func toggle(card child: CardContainerView) {
        guard let parent = child.superview else { return }
        if let parentContainer = parent as? CardContainerView, parentContainer.state == .collapsed {
            return
        }
        if child.state == .expanded,
           let nextChild = child.subviews.first as? CardContainerView,
           nextChild.state == .expanded {
            return
        }
        let currentState = child.state
        child.toggleState()
        let frameAnimator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1) {
            if currentState == .expanded {
                self.cardVisibleConstraints[child.tag].isActive = false
                self.cardHiddenConstraints[child.tag].isActive = true
                // Collapse each card
                self.children.forEach {
                    if $0.tag > child.tag {
                        $0.isHidden = true
                        $0.state = .collapsed
                        $0.layer.opacity = 1
                        self.cardVisibleConstraints[$0.tag].isActive = false
                        self.cardHiddenConstraints[$0.tag].isActive = true
                    }
                }
                
            } else{
                self.cardVisibleConstraints[child.tag].isActive = true
                self.cardHiddenConstraints[child.tag].isActive = false
            }
            self.parent.layoutIfNeeded()
        }
        frameAnimator.addCompletion { _ in
            guard child.state == .expanded else { return }
            if child.tag + 1 < self.children.count {
                self.children[child.tag + 1].isHidden = false

                self.cardHiddenConstraints[child.tag + 1].isActive = true
                self.parent.bringSubviewToFront(self.children[child.tag + 1])
                child.layoutIfNeeded()
                self.parent.layoutIfNeeded()
            }
        }
        frameAnimator.startAnimation()
        handleOpacityChange(forChild: child)
    }
    
    
    private func handleOpacityChange(forChild child: CardContainerView) {
        guard child.tag - 1 >= 0 else {
            child.layer.opacity = 1.0
            return
        }
        let previousCard = self.children[child.tag - 1]
        if child.state == .expanded {
            previousCard.layer.opacity = 0.38
        } else {
            previousCard.layer.opacity = 1
            child.layer.opacity = 1
        }
    }
}

