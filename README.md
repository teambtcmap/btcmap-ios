<p align="center"><img src="https://github.com/bubelov/btcmap-android/blob/master/fastlane/metadata/android/en-US/images/icon.png" width="100"></p> 
<h2 align="center"><b>BTC Map</b></h2>
<h4 align="center">See where you can spend your bitcoins</h4>

## Build

### Initial Elements

Run `elements.sh` to download initial elements to `elements.json`.

## Elements Statistics

Run `elements.js` to calculate statistics about elements and tags.

## Support

[btcmap.org/support-us](https://btcmap.org/support-us)

## FAQ

### Where does BTC Map take its data from?

The data is provided by Open Street Map:

https://www.openstreetmap.org

### Can I add or edit places?

Absolutely, you are very welcome to do that. This is a good place to start: 

[Tagging Instructions](https://github.com/teambtcmap/btcmap-data/wiki/Tagging-Instructions)

### BTC Map shows a place which doesn't exist, how can I delete it?

You can delete such places from Open Street Map and BTC Map will pick up all your changes within 10 minutes.

### I've found a place on BTC Map but it doesn't accept bitcoins

Open Street Map might have outdated information about some places, you can delete the following tags to remove this place from BTC Map:

```
currency:XBT
currency:BTC
payment:bitcoin
```

## TODO

## MAP PERFORMANCE
- [ ] Biggest issue right now is we have a very naive implementation of the map annotations. We are adding all of them on viewDidLoad of MapVC. This becomes a problem as user zooms out to world view, as MapKit is surprisingly bad with their clustering logic and UI pauses for a bit. Biggest win might be using this 3rd party clustering framework: https://github.com/efremidze/Cluster

## ELEMENT
- [ ] If "type": "way", then the Element json returns a bounding box instead of a single coordinate. 
Either:
(1) Find the center of the bounding box and use that as a single coordinate for an annotation.
(2) Draw the bounding box as a polyline. Both Android and web currently just do (1).


### ELEMENT DETAIL MODAL
- [ ] Finish adding rows to match Android. For sure Instagram and Pouch, need to verify what else
- [ ] Phone number parsing isn't working for all formats. Can mimic Android repo implementation

### MAIN OPTIONS BUTTON
- [ ] All of the options in the main options button are NOT implemented. Communities Main is partially implemented, but unfinished

### REFACTOR
- [ ] Initial startup logic (initial loading of Elements) could use a refactor. Local vs Remote persistence is a bit mixed up

### TESTS
- [ ] There are currently no tests. Start with API mocks

---

![Untitled](https://user-images.githubusercontent.com/85003930/194117128-2f96bafd-2379-407a-a584-6c03396a42cc.png)
