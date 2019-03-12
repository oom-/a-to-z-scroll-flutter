import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';

class AtoZSlider extends StatefulWidget {
  var items;
  var callbackitemclick;
  var callbacksearchchange;

  AtoZSlider(items, callbackitemclick, callbacksearchchange) {
    this.items = items;
    this.items.sort((a, b) => removeDiacritics(a.toString().toUpperCase())
        .compareTo(removeDiacritics(b.toString().toUpperCase())));
    this.callbackitemclick = callbackitemclick;
    this.callbacksearchchange = callbacksearchchange;
  } // prend une liste en param
/*
  void setItems(aca) // to easy set new item
  {
    this.items = aca;
    forceSort();
  }

  void forceSort() {
    this.items.sort((a, b) => removeDiacritics(a.toString().toUpperCase())
        .compareTo(removeDiacritics(b.toString().toUpperCase())));
  }
*/ //NOTE: not used
  @override
  _AtoZSlider createState() => new _AtoZSlider();
}

class _AtoZSlider extends State<AtoZSlider> {
  double _offsetContainer;
  double _heightscroller;
  var _itemscache;
  var _text;
  var _searchtext;
  var _oldtext;
  var _alphabet;
  var _customscrollisscrolling;
  var _itemsizeheight;
  var _itemfontsize;
  var _animationcounter; //wait end of all animations
  var _sizeheightcontainer;
  var _sizefirstitem;
  //var _lastoffset; //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER]
  ScrollController _scrollController;
  FocusNode _focusNode;

  void onscrolllistview() {
    if (!_customscrollisscrolling && _animationcounter == 0) {
      var indexFirst =
          ((_scrollController.offset / _itemsizeheight) % _itemscache.length)
              .floor();
      /*if (_scrollController.offset > _lastoffset) //Go downward //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER] (all block)
      {
        var indexLast =
            ((((_heightscroller * _alphabet.length) / _itemsizeheight).floor() +
                        indexFirst) -
                    1) %
                _itemscache.length;
        var fletter = _itemscache[indexLast].toString().toUpperCase()[0];
        var i = _alphabet.indexOf(fletter);
        if (i != -1) {
          setState(() {
            _text = _alphabet[i];
            _offsetContainer = i * _heightscroller;
          });
        }
      } else //Go upward
      {*/
        var fletter = _itemscache[indexFirst].toString().toUpperCase()[0];
        var i = _alphabet.indexOf(fletter);
        if (i != -1) {
          setState(() {
            _text = _alphabet[i];
            _offsetContainer = i * _heightscroller;
          });
        }
      //}
     // _lastoffset = _scrollController.offset; //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER]
    }
  }

  void onsearchtextchange(text)
  {
    if(text.length > 0)
    {
      try{
      RegExp regs = new RegExp(text);
      _itemscache.clear();
      for(var element in widget.items)
      {
        if (regs.hasMatch(element.toString().toLowerCase()))
          _itemscache.add(element);
      }
      setState(() {
        _searchtext = text;
        _scrollController.jumpTo(0.0);
      });
      widget.callbacksearchchange(text);
      }
      catch(e){debugPrint("coucou");} //regex error
    }
    else if (text.length !=_searchtext.length)
    {
      setState(() {
       _searchtext = text; 
       _itemscache = List.from(widget.items);
      });
    }
  }

  void onfocustextfield()
  {
    setState(() {});
  }

  void onItemClick(index)
  {
    setState(() {  FocusScope.of(context).requestFocus(new FocusNode());}); //NOTE: unfocus search when you click on listview
    for(var i = 0; i < widget.items.length; i++)
    {       
      if(widget.items[i] ==_itemscache[index])
        {
          index = i; break;
        }
    }
    widget.callbackitemclick(index);
  }

  @override
  void initState() {
    super.initState();
    _itemscache = List.from(widget.items); //NOTE: copy of original items for search
    _customscrollisscrolling = false;
    _offsetContainer = 0.0;
    _animationcounter = 0;
    _searchtext = "";
    _itemsizeheight = 42.0; //NOTE: size items
    _itemfontsize = 18.0; //NOTE: fontsize items
    _sizefirstitem = 80.0; //NOTE: size of the container above
    //_lastoffset = 0.0; //NOTE: [TO UNCOMMENT TO ADD THE GOING DOWNWARD CHANGING LETTER]
    _sizeheightcontainer = 0.0;
    _focusNode = FocusNode();
    _focusNode.addListener(onfocustextfield);
    _scrollController = ScrollController();
    _scrollController.addListener(onscrolllistview);
    _alphabet = new List<String>();
    for (var i = 0; i < _itemscache.length; i++) {
      if (_itemscache[i].toString().trim().length > 0) {
        var fletter = removeDiacritics(
            _itemscache[i].toString().trim()[0].toUpperCase());
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
       _heightscroller = (contrainsts.biggest.height - _sizefirstitem) / _alphabet.length; //NOTE: Here the contrainsts.biggest.height is the height of the list (height of body)
      _sizeheightcontainer = contrainsts.biggest.height - _sizefirstitem; //NOTE: Here i'm substracting the size of the container above of the listView
      return Column(children:[
        Container(
          padding: EdgeInsets.all(10),
          height: _sizefirstitem, 
          child:TextField(
          focusNode: _focusNode,
          onChanged: onsearchtextchange, 
          decoration: InputDecoration(
              labelText: "Search",
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)))),
        )),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => {
            setState(() {  FocusScope.of(context).requestFocus(new FocusNode());}) //NOTE: unfocus search when you click on scroller
          },
          child:Container(
          height: _sizeheightcontainer, //NOTE: Here is were is set the size of the listview
          child: Stack(alignment: Alignment.topRight, children: [ //NOTE: Here to add some other components (but you need to remove they height from calcs (line above))
        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(8.0),
          itemExtent: _itemsizeheight,
          itemCount: _itemscache.length,
          itemBuilder: (BuildContext context, int index) { //NOTE: How you want to generate your items
            return GestureDetector(
                onTap: () => onItemClick(index),
                child: Text(_itemscache[index].toString(),
                    style: new TextStyle(fontSize: _itemfontsize)));
          },
        ),
        Visibility(
          visible: _focusNode.hasFocus ? false : _searchtext.length > 0 ? false : true,
          child: GestureDetector(
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
                  for (var i = 0; i < _itemscache.length; i++) {
                    if (_itemscache[i].toString().trim().length > 0 &&
                        _itemscache[i].toString().trim().toUpperCase()[0] ==
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
        ),
        )
      ])
      ),
      ),
      ]);
    });
  }
}
