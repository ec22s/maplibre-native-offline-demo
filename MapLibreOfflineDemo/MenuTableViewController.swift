import UIKit

private let TEXT_TITLE = "DEMO : MapLibre + PMTiles offline maps"
private let TEXT_CELLS = [
    TEXT_TITLE,
    "　1　記号/文字はネットから (初回起動時はネット接続必須)",
    "　2　記号/文字なし (完全オフライン)",
    "　3　for dev: open document directory"
]
private let HEIGHT_TITLE: CGFloat = 96
private let HEIGHT_LINK: CGFloat = 64
private let COLOR_TITLE = UIColor.label
private let COLOR_LINK = UIColor.link

struct CellConfig {
    var row: Int
    var text: String
    var isLink: Bool { closure != nil }
    var isTitle: Bool { row == 0 }
    var height: CGFloat { isTitle ? HEIGHT_TITLE: HEIGHT_LINK }
    var color: UIColor { isTitle ? COLOR_TITLE : COLOR_LINK }
    var align: UIListContentConfiguration.TextProperties.TextAlignment {
        isTitle ? .center : .natural
    }
    var closure: (()->())? = nil
}

class MenuTableViewController: UIViewController, UIDocumentPickerDelegate {

    private lazy var cellConfigs = [
        CellConfig(row: 0, text: TEXT_CELLS[0]),
        CellConfig(row: 1, text: TEXT_CELLS[1], closure: {
            self.openMapViewController(tileType: .pmtiles)
            // self.openMapViewController(tileType: .mbtiles) /// style.jsonには使えず
        }),
        CellConfig(row: 2, text: TEXT_CELLS[2], closure: {
            self.openMapViewController(noSpriteGlyphs: true, tileType: .pmtiles)
        }),
        CellConfig(row: 3, text: TEXT_CELLS[3], closure: {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }),
    ]

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
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

    private func openMapViewController(noSpriteGlyphs: Bool = false, tileType: TileType) {
        let vc = DualMapsViewController(noSpriteGlyphs: noSpriteGlyphs, tileType: tileType)
        self.navigationController?.pushViewController(vc, animated: true)
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
        return cellConfigs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let conf: CellConfig = cellConfigs[indexPath.row]
        cell.isUserInteractionEnabled = conf.isLink
        var content = cell.defaultContentConfiguration()
        content.textProperties.color = conf.color
        content.textProperties.alignment = conf.align
        content.text = conf.text
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellConfigs[indexPath.row].height
     }

    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        cellConfigs[indexPath.row].closure?()
    }
}
