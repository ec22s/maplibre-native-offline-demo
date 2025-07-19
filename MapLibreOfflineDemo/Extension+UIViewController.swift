import UIKit

extension UIViewController {
    func fitView(_ targetView: UIView) {
        targetView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            targetView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0),
            targetView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0),
            targetView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            targetView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
        ])
    }
}
