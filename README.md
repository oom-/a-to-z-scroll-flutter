# AtoZscrollflutter - Alphabet indexable scrollbar
A simple alphabet indexed scrollbar for flutter "EZ TO USE"

![demo.gif](https://github.com/oom-/AtoZscrollflutter-/raw/master/demo.gif)

## Only one dependency: 
* `diacritic: ^0.1.1`
to put in your pubspec.yaml file in `dependencies:`

The index scrollbar is generated with all the first letter in uppercase that it can found in the data list passed as parameter.
The sort of the list dont take in consideration the diacritics.

## Features
* Generate index list on input data list
* Jump automatically to the first word starting by the letter when you are scrolling with the Alphabet indexing (with some animation)
* When you scroll directly in the list view set the Scroller to the correct Alphabet letter (or char)
* Take in consideration to go UP or DOWN
  * Take the first item on display of the list for updating the scroller index when you are going UPWARD
  * Take the last item on display of the list for updating the scroller index when you are going DOWNARD

## Ez to install
1. **Add** `diacritic: ^0.1.1` to your pubspec.yaml file in `dependencies:`
2. **Copy** (take care of the include when you copy) and pastle the code of the AtoZSlider class from this file of this repo : 
3. **Use** it like this: 
```dart
body: new AtoZSlider(exampleList, (i) => {
        debugPrint("Click on : (" + i.toString() + ") -> " + exampleList[i])
      }),
```

* first param a List<String>
* second param a callback function when the user click on one item of the list

## EZ customisable
Just take a look of the "NOTE:" flage in the code for simple changes.

```dart
_itemsizeheight = 20.0; //NOTE: size items
_itemfontsize = 14.0; //NOTE: fontsize items
_heightscroller = contrainsts.biggest.height / _alphabet.length; //NOTE: Here the contrainsts.biggest.height is the height of the list (height of body)
_sizeheightcontainer = contrainsts.biggest.height; //NOTE: substract the height of previous item to adapt the listview height
return Stack(alignment: Alignment.topRight, children: [ //NOTE: Here to add some other components (but you need to remove they height from calcs (line above))
itemBuilder: (BuildContext context, int index) { //NOTE: How you want to generate your items
child: Container( //NOTE: this container is the scroll bar it need at least to have height => _heightscroller
color: Colors.indigo, //NOTE: change color of scroller
shape: BoxShape.circle, //NOTE: change this to rectangle
color: Colors.white), //NOTE: white -> color of text of scroller
.animateTo(i * _itemsizeheight, //NOTE: To configure the animation
```

## PS:
This stuff didn't got a lot of tests then it's probably some cases that i didnt took in consideration. Be nice plz.

## PPS:
A little amount of data is needed because the size of the scroller is calculated on the number of items `keys`it mean the number of differents first letters in your data list.
This AtoZlist is working only if you let it fill the body of your main widget. If you want to add some other widget above or below you should probably substract the *widget.height* to `contrainsts.biggest.height` when `_heightscroller` is calculated. (I will probably make an exemple soon.)

You can find exactly how it work explained by steps here: https://github.com/oom-/AtoZscrollflutter-/blob/master/tutorialsample.md

## Exemple of too little data:

![tonotreproduce.gif](https://github.com/oom-/AtoZscrollflutter-/raw/master/tonotreproduce.gif)

Please dont reproduce at home.
