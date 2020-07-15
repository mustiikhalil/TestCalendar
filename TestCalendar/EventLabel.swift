//
//  EventLabel.swift
//  TestCalendar
//
//  Created by Mustafa Khalil on 7/15/20.
//

import UIKit

final class EventLabel: UILabel {
    
    lazy var stackView = UIStackView(arrangedSubviews: [event1Icon, event2Icon])
    
    lazy var event1Icon: UIView = {
        let icon = UIView()
        icon.isHidden = true
        icon.backgroundColor = .red
        icon.layer.cornerRadius = 10 * 0.5
        return icon
    }()
    
    lazy var event2Icon: UIView = {
        let icon = UIView()
        icon.isHidden = true
        icon.backgroundColor = .green
        icon.layer.cornerRadius = 10 * 0.5
        return icon
    }()
    
    init() {
        super.init(frame: .zero)
        textAlignment = .center
        layer.cornerRadius = 16
        clipsToBounds = true
        font = UIFont.systemFont(ofSize: 18)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.spacing = 4
        stackView.distribution = .equalSpacing
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 10),
            event1Icon.heightAnchor.constraint(equalToConstant: 10),
            event1Icon.widthAnchor.constraint(equalToConstant: 10),
            
            event2Icon.heightAnchor.constraint(equalToConstant: 10),
            event2Icon.widthAnchor.constraint(equalToConstant: 10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hasNoEvents() {
        stackView.arrangedSubviews.forEach { $0.isHidden = true }
    }
    
    func hasEvent1() {
        stackView.arrangedSubviews.first?.isHidden = false
    }
    
    func hasEvent2() {
        print("### here: \(stackView.arrangedSubviews)")
        stackView.arrangedSubviews.last?.isHidden = false
    }
}
