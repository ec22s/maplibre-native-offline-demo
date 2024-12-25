import UIKit

class MenuTableViewController: UIViewController {
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func fitView(_ tableView: UITableView) {
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }

    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        fitView(tableView)
    }
}

extension MenuTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LOCAL_MBTILES_ARRAY.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        switch indexPath.row {
        case 0:
            cell.isUserInteractionEnabled = false
            content.textProperties.color = .black
            content.textProperties.alignment = .center
            content.text = "☆ \(NAVIGATION_TITLE) ☆"
        default:
            content.text = "» \(LOCAL_MBTILES_ARRAY[indexPath.row - 1].fileName)"
        }
        cell.contentConfiguration = content
        return cell
    }
    
    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            return
        default:
            let vc: UIViewController = MapViewController(localMbtiles: LOCAL_MBTILES_ARRAY[indexPath.row - 1])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
