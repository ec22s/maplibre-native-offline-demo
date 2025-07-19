import CoreLocation
import UIKit

let LOCAL_STYLE_GENERATED_BASENAME = "generated-style"
let LOCAL_STYLE_ORIGINAL_BASENAME = "protomaps-style-original"
let LOCAL_STYLE_NO_SPRITE_GLYPHS_BASENAME = "protomaps-style-no-sprite-glyphs"
let LOCAL_TILES_BASENAME = "protomaps-v4-japan-maxzoom-11"
let TARGET_SOURCE_ID = "protomaps"

let MAP_ANIMATED: Bool = false // trueにすると2地図の位置連動が無限ループになってしまう
let MAP_INIT_CENTER = CLLocationCoordinate2D(latitude: 33.6, longitude: 130.4)
let MAP_INIT_ZOOM: Double = 6
let MAP_POSITION_ZOOM: Double = 11

let MAPS_BUTTON_BACKGROUND = UIColor.black
let MAPS_BUTTON_FOREGROUND = UIColor.white
let MAPS_BUTTON_SIZE: Double = 32
let MAPS_BUTTON_SPACING: Double = 32
let MAPS_DELIM_COLOR = UIColor.black
let MAPS_DELIM_WIDTH: Double = 40
let MAPS_LABEL_BACKGROUND = UIColor.black
let MAPS_LABEL_FOREGROUND = UIColor.white
let MAPS_LABEL_HEIGHT: Double = 32
let MAPS_LABEL_WIDTH: Double = 96

enum TileType: String {
    // case mbtiles // style.jsonには使えず
    case pmtiles
}
