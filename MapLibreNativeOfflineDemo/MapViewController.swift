import MapLibre

class MapViewController: UIViewController, MLNMapViewDelegate {
    var localMbtiles: LocalMbtiles?
    var mapView: MLNMapView!

    init(localMbtiles: LocalMbtiles?) {
        self.localMbtiles = localMbtiles
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }

    private func setupMap() {
        mapView = MLNMapView(frame: view.bounds, styleURL: BACKGROUND_ONLY_STYLE_JSON)
        mapView.showsUserLocation = false
        mapView.setCenter(MAP_INIT_CENTER, zoomLevel: MAP_INIT_ZOOM, animated: false)
        view.addSubview(mapView)
        mapView.delegate = self
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func mapView(_: MLNMapView, didFinishLoading style: MLNStyle) {
        addLocalMbtilesToStyle(style)
    }

    private func addLocalMbtilesToStyle(_ style: MLNStyle) {
        guard let localMbtiles = self.localMbtiles else {
            print("unexpected nil: localMbtiles")
            return
        }
        let localFileURL = Bundle.main.url(
            forResource: localMbtiles.fileName,
            withExtension: "mbtiles"
        )
        guard let tileUrlString = localFileURL?.absoluteString else {
            print("unexpected nil: tileUrlString", localMbtiles)
            return
        }
        let source = MLNVectorTileSource(
            identifier: "addedSource1",
            tileURLTemplates: [ "mbtiles://\(tileUrlString)" ]
        )
        style.addSource(source)
        let layer = MLNLineStyleLayer(identifier: "addedLayer1", source: source)
        layer.sourceLayerIdentifier = "lines"
        layer.lineColor = NSExpression(forConstantValue: MAP_LINE_COLOR)
        style.addLayer(layer)

        mapView.minimumZoomLevel = localMbtiles.minZoom
        mapView.maximumZoomLevel = localMbtiles.maxZoom
    }
}
