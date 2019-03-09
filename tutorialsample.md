To have something like this: 

[![Exemple][1]][1]

## Initial part
To solve this problem you need to create a custom widget that will return a `LayoutBuilder` who contain a `Stack` who contain a `ListView` at first layer and a `Container` at second layer (as scroller) on right (to put your scroller on right add `alignment: Alignment.topRight` to your `Stack`).

## Make move the scroller
To move the scroller add a `GestureDetector` and catch the `onVerticalDragUpdate` add use a custom property `_offsetContainer` to the one you will add the `details.delta.dy` (from the event) to make your scroller going down and up.

## Make move the ListView from the scroller

### First part
After that you need to add a `ScrollController` to your `ListView` to control it's vertical movement (as `controller` property).

Ok now you need to know multiples stuff to continue:

 - Your alphabet array lenght
 - The height size of your `ListView`
 - The height size of scroller
 - Have an item collection sorted (logic)
 - The height size of one item of your `ListView` (that we will call `_itemsizeheight`)

The goal to reach now is to make move your `ListView`at the first item in the list starting with the alphabet letter selected.

For that you need some maths and some tricks.

To calculate your `ListView` height you need to take the body height and remove the heigth of other widget. But to simplify here we will say that your `ListView` take all the body height. Then it correspond to `contrainsts.biggest.height`(Thanks to the `LayoutBuilder`).

To calculate your scroller height you can do it efficiently and divide the body height by the number of letter in your alphabet array.
`_heightscroller = contrainsts.biggest.height / _alphabet.length;`

### Second part

We will first make the scroller show the letter index with a `Text` widget. Then add a `Text` widget to your controller and add a `_text` property in your custom widget to allow you to change it with the `setState` function.

In your `onVerticalDragUpdate` you have your `_offset` value that correspond to your scroller position. Then you need to make a 'simple' calc to find to witch index of your alphabet array it correspond.

```dart
_text = _alphabet[((_offsetContainer / _heightscroller) % _alphabet.length).round()];
```

### Third part

Now you know the letter then it will be easy to make move your `ListView`.
First get the index in your list of the first element that correspond to the letter selected.

Example:
```dart
var index = 0;
for (var i = 0; i < widget.items.length; i++) {
   if (widget.items[i].toString().trim().length > 0 &&
       widget.items[i].toString().trim().toUpperCase()[0] ==
       _text.toString().toUpperCase()[0]) {
      index = i;
      break;
   }
}
```

Now that you have your index just use your `ScrollController` to move your `ListView`.
```dart
_scrollController.animateTo(index * _itemsizeheight,                         
   duration: new Duration(milliseconds: 500),
   curve: Curves.ease);
```

## Make move the scroller from the ListView
Ok now it's working but we need to make move the scroller too isen't ? I mean i dont want that it stay on the  `V` letter when the `ListView` will display me `A` letter items.

How to do this ?

In your init function just after that you set your `ScrollController` add an 
`_scrollController.addListener(onscrolllistview);` to know when the user will scroll directly in the `ListView`.

In your `onscrolllistview`function you need some calculation to get the first item displayed and the last item displayed.
```dart
var indexFirst = ((_scrollController.offset / _itemsizeheight) % widget.items.length).floor();
var indexLast = ((((_heightscroller * _alphabet.length) / _itemsizeheight).floor() + indexFirst) - 1) % widget.items.length;
```

Perfect now you can easly know witch letter you need to display on your scroller and then know where it need to be (change it's offset).

```dart
var i = _alphabet.indexOf(fletter);
        if (i != -1) {
          setState(() {
            _text = _alphabet[i];
            _offsetContainer = i * _heightscroller;
          });
```

The `fletter` var will depend of the direction of the scroll.

If you are going downward it will be :

`var fletter = widget.items[indexLast].toString().toUpperCase()[0];`

If you are going upward it will be :

`var fletter = widget.items[indexFirst].toString().toUpperCase()[0];`

## Fix the scroller animation
Ok now if you put a `debugPrint` you will can see that the `onscrolllistview` function is called all time even when we are using the scroller. This is a problem. Then how to fix that ?

You need to know when you finished to move when all your animations are finished.

Then just add a `_animationcounter` property in your class.
You will increment it when you are moving your scroller and decrement it when one animation is finished.
Like this:
```dart
for (var i = 0; i < widget.items.length; i++) {
   if (widget.items[i].toString().trim().length > 0 &&
       widget.items[i].toString().trim().toUpperCase()[0] ==
       _text.toString().toUpperCase()[0]) {
     _animationcounter++;
     _scrollController.animateTo(i * _itemsizeheight,
             duration: new Duration(milliseconds: 500),
             curve: Curves.ease) .then((x) => {_animationcounter--});
             break;
        }
   }
```
Now just surround your code of scroller moving in `onscrolllistview` by
```dart
if (_animationcounter == 0) {/*...your code...*/}
```

### PS

You need to take care of you `_offsetContainer` to not go out of bound.
You cand do it like this by exemple:
```dart
if ((_offsetContainer + details.delta.dy) >= 0 &&
                  (_offsetContainer + details.delta.dy) <=
                      (context.size.height - _heightscroller)) {
                _offsetContainer += details.delta.dy;
    }
```

This solution can be probably optimized (not send multiple animation, add var make less calcs). You can find a complete implementation here :
[AtoZscrollflutter][2]


  [1]: https://i.stack.imgur.com/qvY2x.jpg
  [2]: https://github.com/oom-/AtoZscrollflutter-
