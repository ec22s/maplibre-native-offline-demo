import MapLibre

class DualMapsViewController: UIViewController, MLNMapViewDelegate {
    let noSpriteGlyphs: Bool
    let tileType: TileType
    let buttonStackView = UIStackView()
    let mapStackView = UIStackView()
    var styleURLs = [URL]()
    var mapViews = [MLNMapView]()

    init(noSpriteGlyphs: Bool, tileType: TileType) {
        self.noSpriteGlyphs = noSpriteGlyphs
        self.tileType = tileType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupStackView()
        setupStyleURLs()
        setupMaps()
        setupButtons()
    }
    
    override func viewDidLayoutSubviews()
    {
       super.viewDidLayoutSubviews()
       DispatchQueue.main.async {
           if self.view.frame.height > self.view.frame.width {
               self.mapStackView.axis = .vertical
               self.buttonStackView.axis = .horizontal
           } else {
               self.mapStackView.axis = .horizontal
               self.buttonStackView.axis = .vertical
           }
       }
    }

    func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
        syncPositionFromMapView(mapView)
    }

    func mapView(_: MLNMapView, didFinishLoading style: MLNStyle) {
        // Do nothing so far.
    }
    
    private func setupButtons() {
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.spacing = MAPS_BUTTON_SPACING
        view.addSubview(buttonStackView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
        ])
        for btn in [
            createButton(imageName: "plus.circle.fill", zoomParam: 1),
            createButton(imageName: "minus.circle.fill", zoomParam: -1),
            createButton(imageName: "house.circle.fill", toHome: true),
            createButton(imageName: "location.circle.fill", toPosition: true),
        ] {
            buttonStackView.addArrangedSubview(btn)
            NSLayoutConstraint.activate([
                btn.heightAnchor.constraint(equalToConstant: MAPS_BUTTON_SIZE),
                btn.widthAnchor.constraint(equalToConstant: MAPS_BUTTON_SIZE)
            ])
        }
    }

    private func createButton(
        imageName: String,
        zoomParam: Double = Double.nan,
        toHome: Bool = false,
        toPosition: Bool = false
    ) -> UIButton {
        let button = UIButton(frame: .zero, primaryAction: UIAction { _ in
            let targetMapView = self.mapViews[0]
            if zoomParam.isFinite {
                targetMapView.zoomLevel += zoomParam
                return
            }
            if toHome {
                self.setMapCenter(with: targetMapView)
                return
            }
            if toPosition {
                guard let userLocation = targetMapView.userLocation else {
                   print("User location is currently not available.")
                   return
                }
                targetMapView.setCenter(
                    userLocation.coordinate,
                    zoomLevel: MAP_POSITION_ZOOM,
                    animated: MAP_ANIMATED
                )
                return
            }
        })
        var btnConf = UIButton.Configuration.filled()
        btnConf.baseBackgroundColor = MAPS_BUTTON_BACKGROUND
        btnConf.baseForegroundColor = MAPS_BUTTON_FOREGROUND
        btnConf.image = UIImage(systemName: imageName)
        button.configuration = btnConf
        return button
    }
    
    private func setupStyleURLs() {
        styleURLs.removeAll()
        if let originalStyleURL = Bundle.main.url(
            forResource: LOCAL_STYLE_ORIGINAL_BASENAME,
            withExtension: "json"
        ) {
            styleURLs.append(originalStyleURL)
        }
        if let generatedStyleURL = generateStyleURL {
            styleURLs.append(generatedStyleURL)
        }
    }
    
    private var templateStyleData: Data? {
        guard let templateStyleURL: URL = Bundle.main.url(
            forResource:
                noSpriteGlyphs
                    ? LOCAL_STYLE_NO_SPRITE_GLYPHS_BASENAME
                    : LOCAL_STYLE_ORIGINAL_BASENAME,
            withExtension: "json"
        ) else {
            print("unexpected nil: originalFileURL")
            return nil
        }
        guard
            let templateStyleContent: String = try? String(contentsOf: templateStyleURL)
        else {
            print("unexpectedly failed to get: originalStyleJsonContent")
            return nil
        }
        return templateStyleContent.data(using: .utf8)
    }
    
    private var templateJSONObject: [String: Any]? {
        guard
            let templateStyleData: Data = templateStyleData
        else {
            print("unexpectedly failed to get: originalStyleJsonData")
            return nil
        }
        do {
            return try JSONSerialization.jsonObject(with: templateStyleData, options: []) as? [String: Any]
        } catch {
            print("unexpectedly failed to get templateJSONObject. Check JSON validity.")
            return nil
        }
    }
    
    private var templateSources: [String: Any]? {
        return templateJSONObject?["sources"] as? [String: Any]
    }
    
    private var updatedJSONObject: [String: Any]? {
        guard
            var jsonObject = templateJSONObject,
            var sources = templateSources,
            var sourceToUpdate = templateSources?[TARGET_SOURCE_ID] as? [String: String]
        else {
            print("unexpectedly failed to get sourceToUpdate")
            return nil
        }

        // style.jsonのタイルをローカルパスに差替, 新規ローカルファイルの中身として返す
        let tileTypeString: String = tileType.rawValue
        sourceToUpdate.updateValue("\(tileTypeString)://" + (Bundle.main.url(
            forResource: LOCAL_TILES_BASENAME,
            withExtension: tileTypeString
        )?.absoluteString ?? ""), forKey: "url")
        sources.updateValue(sourceToUpdate, forKey: TARGET_SOURCE_ID)
        jsonObject.updateValue(sources, forKey: "sources")
        return jsonObject
    }
    
    private var generateStyleURL: URL? {
        guard let jsonObject = updatedJSONObject else {
            print("unexpectedly failed to get updatedJSONObject")
            return nil
        }
        // 確認用
        // print("dev", ((jsonObject["sources"] as? [String: Any])?[TARGET_SOURCE_ID] as? [String: String])?["url"] ?? "")

        let updatedJSONData = try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
        let dir = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let newStyleJsonURL = dir.appendingPathComponent("\(LOCAL_STYLE_GENERATED_BASENAME).json")
        if !FileManager.default.createFile(
            atPath: newStyleJsonURL.path,
            contents: updatedJSONData,
            attributes: nil
        ) {
            print("unexpectedly failed to create: \(newStyleJsonURL.path)")
        }
        return newStyleJsonURL
    }

    private func setMapLabel(with index: Int, to view: UIView) {
        let online: Bool = index == 0
        let label = UILabel()
        label.backgroundColor = MAPS_LABEL_BACKGROUND
        label.textAlignment = .center
        label.text = online ? "Normal" : "Offline"
        label.textColor = MAPS_LABEL_FOREGROUND
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.heightAnchor.constraint(equalToConstant: MAPS_LABEL_HEIGHT),
            label.widthAnchor.constraint(equalToConstant: MAPS_LABEL_WIDTH),
            (online
                ? label.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                : label.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            ),
        ])
    }
    
    private func setMapCenter(with mapView: MLNMapView) {
        mapView.setCenter(
            MAP_INIT_CENTER,
            zoomLevel: MAP_INIT_ZOOM,
            animated: MAP_ANIMATED
        )
    }

    private func setupMaps() {
        styleURLs.enumerated().forEach { (index, url) in
            let mapView = MLNMapView(frame: view.bounds, styleURL: url)
            mapView.allowsRotating = false
            mapView.allowsTilting = false
            mapView.showsUserLocation = true
            setMapCenter(with: mapView)
            mapView.delegate = self
            mapStackView.addArrangedSubview(mapView)
            mapViews.append(mapView)
            setMapLabel(with: index, to: mapView)
            
        }
    }

    private func setupStackView() {
        mapStackView.distribution = .fillEqually
        mapStackView.translatesAutoresizingMaskIntoConstraints = false
        mapStackView.backgroundColor = MAPS_DELIM_COLOR
        mapStackView.spacing = MAPS_DELIM_WIDTH
        view.addSubview(mapStackView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mapStackView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mapStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            mapStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mapStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
        ])
    }
    
    private func syncPositionFromMapView(_ mv: MLNMapView) {
        for mapView in mapViews {
            if ObjectIdentifier(mapView) == ObjectIdentifier(mv) { continue }
            mapView.setCenter(mv.centerCoordinate, zoomLevel: mv.zoomLevel, animated: MAP_ANIMATED)
        }
    }
}
