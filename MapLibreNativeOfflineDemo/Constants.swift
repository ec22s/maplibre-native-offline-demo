import Foundation
import CoreLocation
import UIKit

let BACKGROUND_ONLY_STYLE_JSON = Bundle.main.url(
    forResource: "background-only-style",
    withExtension: "json"
)
let LOCAL_MBTILES_ARRAY = [
    LocalMbtiles(fileName: "shikoku-latest-6-10.osm", minZoom: 6, maxZoom: 10),
    LocalMbtiles(fileName: "kyushu-latest-6-10.osm", minZoom: 6, maxZoom: 10)
]
let MAP_INIT_CENTER = CLLocationCoordinate2D(latitude: 33, longitude: 130)
let MAP_INIT_ZOOM: Double = 6
let MAP_LINE_COLOR = UIColor.brown
let NAVIGATION_TITLE = "Demo : MapLibre Native + Local MBTiles"
