<p align="center"><img src="https://github.com/bubelov/btcmap-android/blob/master/fastlane/metadata/android/en-US/images/icon.png" width="100"></p> 
<h2 align="center"><b>BTC Map</b></h2>
<h4 align="center">See where you can spend your bitcoins</h4>

## Build

### Initial Elements

Run `elements.sh` to download initial elements to `elements.json`.

## Elements Statistics

Run `elements.js` to calculate statistics about elements and tags.

## Support

bc1qng60mcufjnmz6330gze5yt4m6enzra7lywns2d

<img src="https://github.com/teambtcmap/btcmap-android/raw/master/app/src/main/res/drawable-nodpi/btc_address.png" width="273">

## FAQ

### Where does BTC Map take its data from?

The data is provided by Open Street Map:

https://www.openstreetmap.org

### Can I add or edit places?

Absolutely, you are very welcome to do that. This is a good place to start: 

[Tagging Instructions](https://github.com/teambtcmap/btcmap.org/wiki/Tagging-Instructions)

### BTC Map shows a place which doesn't exist, how can I delete it?

You can delete such places from Open Street Map and BTC Map will pick up all your changes within 24 hours

### I've found a place on BTC Map but it doesn't accept bitcoins

Open Street Map might have outdated information about some places, you can delete the following tags to remove this place from BTC Map:

```
currency:XBT
currency:BTC
payment:bitcoin
```

---

![Untitled](https://user-images.githubusercontent.com/85003930/194117128-2f96bafd-2379-407a-a584-6c03396a42cc.png)
