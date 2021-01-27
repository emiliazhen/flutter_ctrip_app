import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ctrip/dao/search_dao.dart';
import 'package:flutter_ctrip/model/search_model.dart';
import 'package:flutter_ctrip/widget/search_bar.dart';
import 'package:flutter_ctrip/widget/webview.dart';

const URL = 'https://m.ctrip.com/restapi/h5api/globalsearch/search?source=mobileweb&action=mobileweb&keyword=';
const SEARCH_ITEM_TYPES = [
   'channelgroup',
   'channelgs',
   'channelplane',
   'channeltrain',
   'cruise',
   'district',
   'food',
   'hotel',
   'huodong',
   'shop',
   'sight',
   'ticket',
   'travelgroup',
];
class SearchPage extends StatefulWidget {
  final bool hideLeft;
  final String searchUrl;
  final String keyword;
  final String hint;
  const SearchPage({Key key,this.hideLeft,this.searchUrl = URL,this.keyword,this.hint}):super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchModel _searchModel;
  Timer _timer;
  Duration durationTime = Duration(milliseconds:390);

  void _onTextChange(String text){
    _timer?.cancel();
    _timer = Timer(durationTime,(){
      if(text.length == 0){
        setState(() {
          _searchModel = null;
        });
        return;
      }
      SearchDao.fetch(widget.searchUrl, text).then((SearchModel model){
        if(model.keyword == text){
          setState(() {
            _searchModel = model;
          });
        }
      }).catchError((e){
        print(e);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          _appBar,
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: _searchModel?.data?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                return _item(index);
               },
              ),
            ))
          
        ],
      ),
    );
  }

  Widget get _appBar {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient( 
          colors: [Color(0x66000000),Colors.transparent],
          begin: Alignment.topCenter,
          end:Alignment.bottomCenter
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(top:20),
        height: 80,
        decoration: BoxDecoration(color: Colors.white),
        child: SearchBar(
          hideLeft: widget.hideLeft,
          defaultText: widget.keyword,
          hint: widget.hint,
          leftButtonClick: (){
            Navigator.pop(context);
          },
          onChanged: _onTextChange,
        ),
      ),
    );
  }

  Widget _item(int index){
    if(_searchModel == null || _searchModel.data == null) return null;
    SearchItemModel item = _searchModel.data[index];
    return GestureDetector(
      onTap: (){
        Navigator.push(context,MaterialPageRoute(builder: (context) => WebView(
          url: item.url,
          title: '详情',
        )));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 0.3,
              color: Colors.grey
            )
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(1),
              child: Image(
                height: 26,
                width: 26,
                image: AssetImage(_typeImage(item.type)),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  width: 300,
                  child: _title(item),
                ),
                Container(
                  width: 300,
                  margin: EdgeInsets.only(top:5),
                  child: _subTitle(item)
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String _typeImage(String type){
    if(type == null) return 'images/type_travelgroup.png';
    String path = 'travelgroup';
    for(final key in SEARCH_ITEM_TYPES){
      if(type.contains(key)){
        path = key;
        break;
      }
    }
    return 'images/type_$path.png';
  }

  Widget _title(SearchItemModel item){
    if(item == null) return null;
    List<TextSpan> spans = [];
    spans.addAll(_keywordTextSpans(item.word,_searchModel.keyword));
    spans.add(TextSpan(
      text: ' ' + (item.districtname ?? '') + ' ' + (item.zonename ?? ''),
      style: TextStyle(fontSize: 16, color: Colors.grey)
    ));
    return RichText(text: TextSpan(
      children: spans
    ));
  }

  Widget _subTitle(SearchItemModel item){
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: item.price ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.orange
            )
          ),
          TextSpan(
            text: ' ' + (item.star ?? ''),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey
            )
          )
        ]
      ),
    );
  }

  List<TextSpan> _keywordTextSpans(String word, String keyword){
    List<TextSpan> spans = [];
    if(word == null || word.length ==0) return spans;
    List<String> arr = word.split(keyword);
    TextStyle normalStyle = TextStyle(fontSize: 16, color: Colors.black87);
    TextStyle keywordStyle = TextStyle(fontSize: 16, color: Colors.orange);
    for(int i = 0; i < arr.length; i++){
      if((i+1)%2 == 0){
        spans.add(TextSpan(text: keyword,style: keywordStyle));
      }
      String val = arr[i];
      if(val!=null && val.length > 0){
        spans.add(TextSpan(text: val,style: normalStyle));
      }
    }
    return spans;
  }
}