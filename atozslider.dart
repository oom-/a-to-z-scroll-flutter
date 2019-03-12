import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';

class AtoZSlider extends StatefulWidget {
  var items;
  var callbackitemclick;

  AtoZSlider(items, callbackitemclick) {
    setItems(items);
    this.callbackitemclick = callbackitemclick;
  } // prend une liste en param

  void setItems(aca) // to easy set new item
  {
    this.items = aca;
    forceSort();
  }

  void forceSort() {
    this.items.sort((a, b) => removeDiacritics(a.toString().toUpperCase())
        .compareTo(removeDiacritics(b.toString().toUpperCase())));
  }

  @override
  _AtoZSlider createState() => new _AtoZSlider();
}

class _AtoZSlider extends State<AtoZSlider> {
  double _offsetContainer;
  double _heightscroller;
  var _text;
  var _oldtext;
  var _alphabet;
  var _customscrollisscrolling;
  var _itemsizeheight;
  var _itemfontsize;
  var _animationcounter; //wait end of all animations
  var _lastoffset;
  var _sizeheightcontainer;
  
  ScrollController _scrollController;

  void onscrolllistview() {
    if (!_customscrollisscrolling && _animationcounter == 0) {
      var indexFirst =
          ((_scrollController.offset / _itemsizeheight) % widget.items.length)
              .floor();
      if (_scrollController.offset > _lastoffset) //Go downward
      {
        var indexLast =
            ((((_heightscroller * _alphabet.length) / _itemsizeheight).floor() +
                        indexFirst) -
                    1) %
                widget.items.length;
        var fletter = widget.items[indexLast].toString().toUpperCase()[0];
        var i = _alphabet.indexOf(fletter);
        if (i != -1) {
          setState(() {
            _text = _alphabet[i];
            _offsetContainer = i * _heightscroller;
          });
        }
      } else //Go upward
      {
        var fletter = widget.items[indexFirst].toString().toUpperCase()[0];
        var i = _alphabet.indexOf(fletter);
        if (i != -1) {
          setState(() {
            _text = _alphabet[i];
            _offsetContainer = i * _heightscroller;
          });
        }
      }
      _lastoffset = _scrollController.offset;
    }
  }

  @override
  void initState() {
    super.initState();
    _customscrollisscrolling = false;
    _offsetContainer = 0.0;
    _animationcounter = 0;
    _itemsizeheight = 20.0; //NOTE: size items
    _itemfontsize = 14.0; //NOTE: fontsize items
    _lastoffset = 0.0;
    _sizeheightcontainer = 0.0;
    _scrollController = ScrollController();
    _scrollController.addListener(onscrolllistview);
    _alphabet = new List<String>();
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].toString().trim().length > 0) {
        var fletter = removeDiacritics(
            widget.items[i].toString().trim()[0].toUpperCase());
        if (_alphabet.indexOf(fletter) == -1) {
          _alphabet.add(fletter);
        }
      }
    }
    _text = "*";
    _oldtext = _text;
    if (_alphabet.length > 0) {
      _alphabet.sort();
      _text = _alphabet[0];
      _oldtext = _text;
    } else {
      throw new Exception('-> Zero items in list. <-');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contrainsts) {
      _heightscroller = contrainsts.biggest.height / _alphabet.length; //NOTE: Here the contrainsts.biggest.height is the height of the list (height of body)
      _sizeheightcontainer = contrainsts.biggest.height; //NOTE: substract the height of previous item to adapt the listview height
      return Stack(alignment: Alignment.topRight, children: [ //NOTE: Here to add some other components (but you need to remove they height from calcs (line above))
        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(8.0),
          itemExtent: _itemsizeheight,
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) { //NOTE: How you want to generate your items
            return GestureDetector(
                onTap: () => {
                    widget.callbackitemclick(index)
                },
                child: Text(widget.items[index].toString(),
                    style: new TextStyle(fontSize: _itemfontsize)));
          },
        ),
        GestureDetector(
          child: Container(
              child: Container(//NOTE: this container is the scroll bar it need at least to have height => _heightscroller
                width: _heightscroller,
                decoration: new BoxDecoration(
                  color: Colors.indigo, //NOTE: change color of scroller
                  shape: BoxShape.circle, //NOTE: change this to rectangle
                ),
                child: Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontSize: (_heightscroller - 4),
                      fontWeight: FontWeight.bold,
                      color: Colors.white), //NOTE: white -> color of text of scroller
                ),
              ),
              height: _heightscroller,
              margin: EdgeInsets.only(top: _offsetContainer)),
          onVerticalDragStart: (DragStartDetails details) {
            _customscrollisscrolling = true;
          },
          onVerticalDragEnd: (DragEndDetails details) {
            _customscrollisscrolling = false;
          },
          onVerticalDragUpdate: (DragUpdateDetails details) {
            setState(() {
              if ((_offsetContainer + details.delta.dy) >= 0 &&
                  (_offsetContainer + details.delta.dy) <=
                      (_sizeheightcontainer - _heightscroller)) {
                _offsetContainer += details.delta.dy;
                _text = _alphabet[
                    ((_offsetContainer / _heightscroller) % _alphabet.length)
                        .round()];
                if (_text != _oldtext) {
                  for (var i = 0; i < widget.items.length; i++) {
                    if (widget.items[i].toString().trim().length > 0 &&
                        widget.items[i].toString().trim().toUpperCase()[0] ==
                            _text.toString().toUpperCase()[0]) {
                      _animationcounter++;
                      _scrollController
                          .animateTo(i * _itemsizeheight, //NOTE: To configure the animation
                              duration: new Duration(milliseconds: 500),
                              curve: Curves.ease)
                          .then((x) => {_animationcounter--});
                      break;
                    }
                  }
                  _oldtext = _text;
                }
              }
            });
          },
        )
      ]);
    });
  }
}
