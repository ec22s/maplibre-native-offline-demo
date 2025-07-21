# MapLibre Native - Offline Demo

- [HAKATA.swift feat. Japan-\(region).swift #1](https://hakata-swift.connpass.com/event/353191/) (Jul 19 2025) で発表したデモのソースです

- [スライドPDF](https://github.com/user-attachments/files/21342497/20250719-hakata-swift.pdf) <!--https://ec22s.github.io/maplibre-native-offline-demo/20250719-hakata-swift.pdf-->
  - 発表後、説明を追加しました

- デモ動画
  - [その1 (5.4MB)](https://github.com/user-attachments/assets/8862faa6-ddaa-4e3b-a744-1766fa2af21b) 発表時に流したものの短縮版
  - [その2 (5.0MB)](https://github.com/user-attachments/assets/c90b040d-d575-45b6-b0cc-6f3ed8854aa8) オンライン時の様子

<br>

### 開発/検証環境
- macOS Sequoia 15.5

- Xcode 16.4

- 実機 : iPad 10th generation (OS 18.2.1)

- シミュレータ : 同上 (OS 18.5)

<br>

### ライブラリについて
- Swift Package Managerで設定済みですが、自動でインストールされない時は `MapLibre Native` 6.17.1以降を追加して下さい

- 他の使用ライブラリはありません

<br>

### 地図のスタイルとデータについて
- スタイルは https://maps.protomaps.com/#flavorName=light を用いました

- データも同じサイトから以下のコマンドで取得し、ビルド時にResourcesディレクトリに追加しました。容量が大きいため本ソースにはありません
```sh
brew install pmtiles
pmtiles extract --maxzoom=11 --bbox=125,25,150,50 https://demo-bucket.protomaps.com/v4.pmtiles protomaps-v4-japan-maxzoom-11.pmtiles
```

<br>

---

<br>

- 以下、[Geeks Who Drink in Fukuoka](https://nulab.connpass.com/event/339775/) (Dec 23 2024) でデモした時の情報です

- [その時のスライド](https://github.com/user-attachments/files/21342571/20241223_Fukuoka.pdf) <!--https://ec22s.github.io/maplibre-native-offline-demo/20241223_Fukuoka.pdf-->

- [MapLibre Native](https://github.com/maplibre/maplibre-native) とiOSでローカルのMBTilesファイルを読み込めたので、オフラインファーストな地図アプリに向けた実験をしてみました

- 今後、MBTilesを任意のタイミングでダウンロードするなど実用性を備えたいです

<br>

### 動作検証環境
- Xcode 16.2

- 実機 : iPad 10th generation (OS 18.1.1)

- シミュレータ : 同上 (OS 18.2)

<br>

### ライブラリについて
- Swift Package Managerで設定済みですが、自動でインストールされない時は `MapLibre Native` 6.9.0以降を追加して下さい

- 他の使用ライブラリはありません

<br>

### 地図データについて
容量が大きいためソースから外しました。下記の手順で追加して下さい🙇

1. [GEOFABRIK downloads - Japan](https://download.geofabrik.de/asia/japan.html) 以下二つをダウンロード

    - [Shikoku [.osm.pbf]](https://download.geofabrik.de/asia/japan/shikoku-latest.osm.pbf)

    - [Kyushu [.osm.pbf]](https://download.geofabrik.de/asia/japan/kyushu-latest.osm.pbf)

<br>

2. MBTiles形式に変換

    - 例として gdal の ogr2ogr を使う場合のコマンドを載せます

      ```sh
      brew install gdal
      ogr2ogr -f MBTILES shikoku-latest-6-10.osm.mbtiles -dsco MINZOOM=6 -dsco MAXZOOM=10 "shikoku-latest.osm.pbf"
      ogr2ogr -f MBTILES kyushu-latest-6-10.osm.mbtiles -dsco MINZOOM=6 -dsco MAXZOOM=10 "kyushu-latest.osm.pbf"
      ```
    - ズーム範囲は任意に設定できますが、広過ぎるとファイルサイズが増え、アプリの動作に影響が出るかもしれません

    - アプリのズーム範囲を地図データに合わせるため、ソースの `LOCAL_MBTILES_ARRAY` で設定しています

      https://github.com/ec22s/maplibre-native-offline-demo/blob/17746dff68e527870bd8865b02e8f927345e36c5/MapLibreNativeOfflineDemo/Constants.swift#L9-L12

<br>

3. MBTilesファイルをソースに追加

    - ディレクトリ `Resources` に入れる想定ですが、実際はどこでも可能です（Xcodeがリソースと認識できれば）

<br>

4. ソースにMBTilesファイルがなければメニュー画面から先に遷移せず、Xcodeのデバッグエリアに警告が出ます

<br>

5. 他の地図データを使う場合

    - ソースレイヤー名 `lines` の線を全て単純表示しています。同じソースレイヤー名の線がある地図なら同様に使えると思います

      https://github.com/ec22s/maplibre-native-offline-demo/blob/17746dff68e527870bd8865b02e8f927345e36c5/MapLibreNativeOfflineDemo/MapViewController.swift#L52-L55

    - 任意のファイル名でソースに追加し、2. で書いた `LOCAL_MBTILES_ARRAY` にファイル名とズーム範囲を設定して下さい

<br>

### 補足
- 当日の発表後、最初のメニュー画面から不要な項目を削除しました

- アプリにはズームボタンのUIを設置していません。ズームはピンチイン・アウトでできます

- 実行時にXcodeのデバッグエリアに下記の警告が出る場合がありますが、アプリの中身によらずよくある現象のようです

  - `Failed to send CA Event for app launch measurements for ca_event_type: (以下略)`

    参考 : https://qiita.com/sakurarunea/items/45afa803522eabebe39e

  - `fopen failed for data file: errno = 2 (No such file or directory)`
    `Errors found! Invalidating cache...`

    参考 : https://zenn.dev/moutend/articles/49e479ab68147b

<br>

以上
