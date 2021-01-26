import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ctrip/dao/home_dao.dart';
import 'package:flutter_ctrip/model/common_model.dart';
import 'package:flutter_ctrip/model/grid_nav_model.dart';
import 'package:flutter_ctrip/model/home_model.dart';
import 'package:flutter_ctrip/model/sales_box_model.dart';
import 'package:flutter_ctrip/widget/grid_nav.dart';
import 'package:flutter_ctrip/widget/loading_container.dart';
import 'package:flutter_ctrip/widget/local_nav.dart';
import 'package:flutter_ctrip/widget/sales_box.dart';
import 'package:flutter_ctrip/widget/sub_nav.dart';
import 'package:flutter_ctrip/widget/webview.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
const APPBAR_SCROLL_OFFSET = 100;
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _appBarAlpha = 0.0;
  bool _isLoading = true;
  void _onScroll(offset){
    double alpha = offset / APPBAR_SCROLL_OFFSET;
    if(alpha < 0){
      alpha = 0;
    }else if(alpha > 1){
      alpha = 1;
    }
    setState(() {
      _appBarAlpha = alpha;
    });
  }

  List<CommonModel> bannerList = [];
  List<CommonModel> localNavList = [];
  GridNavModel gridNavModel;
  List<CommonModel> subNavList = [];
  SalesBoxModel salesBox;

  Future<Null> _handelRefresh() async{
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        _isLoading = false;
        bannerList = model.bannerList;
        localNavList = model.localNavList;
        gridNavModel = model.gridNav;
        subNavList = model.subNavList;
        salesBox = model.salesBox;
      });
    } catch (e) {
      _isLoading = false;
      print(e);
    }
    return null;
  }

  @override
  void initState() { 
    super.initState();
    _handelRefresh();
  }

  @override
  Widget build(BuildContext context) { 
    return  Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: LoadingContainer(
        isLoading: _isLoading,
        child: Stack(
          children: <Widget>[
            MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: RefreshIndicator(
                onRefresh: _handelRefresh,
                child: NotificationListener(
                  onNotification: (scrollNotification){
                    if(scrollNotification is ScrollUpdateNotification && scrollNotification.depth == 0){
                      _onScroll(scrollNotification.metrics.pixels);
                    }
                    return false;
                  },
                  child: _listView
                ),
              )
            ),
            _appBar
          ],
        )
      ),
    );
  }

  Widget get _listView {
    return ListView(
      children: <Widget>[
        _banner,
        Padding(
          padding: EdgeInsets.fromLTRB(7,4,7,4),
          child: LocalNav(localNavList: localNavList),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7,0,7,4),
          child: GridNav(gridNavModel: gridNavModel),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7,0,7,4),
          child: SubNav(subNavList: subNavList),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7,0,7,4),
          child: SalesBox(salesBox: salesBox),
        ),
      ],
    );
  }

  Widget get _banner {
    return Container(
      height: 180,
      child: Swiper(
        itemCount: bannerList.length,
        autoplay: true,
        pagination: SwiperPagination(),
        itemBuilder: (BuildContext context,int index){
          CommonModel _bannerItem = bannerList[index];
          return GestureDetector(
            onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => WebView(
                  url:_bannerItem.url,
                  statusBarColor: _bannerItem.statusBarColor,
                  hideAppBar: _bannerItem.hideAppBar,
                ))
              );
            },
            child: Image.network(
              _bannerItem.icon,
              fit:BoxFit.fill,
            ),
          );
        },
      ),
    );
  }

  Widget get _appBar {
    return Opacity(
      opacity: _appBarAlpha,
      child: Container(
        padding: EdgeInsets.only(
          top: 20,
        ),
        child: Center(
          child: Text('首页'),
        ),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
      ),
    );
  }
}