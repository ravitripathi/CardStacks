//
//  ViewController.swift
//  CardStacks
//
//  Created by Ravi Tripathi on 11/06/21.
//
//  Note: This is the implementation. Check `CardStackManager.swift` for the card management logic.
//

import UIKit

class ViewController: UIViewController {

    var cardStackDisplay: CardStackManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        let cards = [CardContainerView(withView: getView(withText: "First View", color: .red)),
                     CardContainerView(withView: getView(withText: "Second View", color: .blue)),
                     CardContainerView(withView: getView(withText: "Third View", color: .orange)),
                     CardContainerView(withView: getView(withText: "Fourth View", color: .green))]
        cardStackDisplay = try? CardStackManager(parent: self.view,
                                                 children: cards)
        cards.forEach {
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:))))
            $0.isUserInteractionEnabled = true
        }
        cardStackDisplay?.show()
    }
    
    func getView(withText text: String, color: UIColor) -> UIView {
        let v = UIView()
        let label = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = text
        v.addSubview(label)
        label.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        return v
    }
    
    @objc func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        if let child = gestureRecognizer.view as? CardContainerView {
            cardStackDisplay?.toggle(card: child)
        }
    }
}
