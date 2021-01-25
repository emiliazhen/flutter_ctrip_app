import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ctrip/dao/home_dao.dart';
import 'package:flutter_ctrip/model/common_model.dart';
import 'package:flutter_ctrip/model/home_model.dart';
import 'package:flutter_ctrip/widget/local_nav.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
const APPBAR_SCROLL_OFFSET = 100;
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _bannerImages = [
    'https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=1844709045,2593352203&fm=26&gp=0.jpg',
    'https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3149511958,3285107878&fm=26&gp=0.jpg',
    'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=4271488344,3038983431&fm=26&gp=0.jpg',
  ];
  double _appBarAlpha = 0.0;
  
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

  String resultString = '';
  List<CommonModel> localNavList = [];

  loadData() async{
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        localNavList = model.localNavList;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() { 
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: Stack(
          children: <Widget>[
            NotificationListener(
              onNotification: (scrollNotification){
                if(scrollNotification is ScrollUpdateNotification && scrollNotification.depth == 0){
                  _onScroll(scrollNotification.metrics.pixels);
                }
                return false;
              },
              child: ListView(
                children: <Widget>[
                  Container(
                    height: 180,
                    child: Swiper(
                      itemCount: 3,
                      autoplay: true,
                      pagination: SwiperPagination(),
                      itemBuilder: (BuildContext context,int index){
                        return Image.network(
                          _bannerImages[index],
                          fit:BoxFit.fill,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(7,4,7,4),
                    child: LocalNav(localNavList: localNavList),
                  ),
                  Container(
                    child: Column(
                      children: List.generate(50, (index){
                        return Text('A$index');
                      }),
                    ),
                  ),
                  Container(
                    child: Text(resultString)
                  )
                ],
              ),
            ),
            Opacity(
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
            )
          ],
        )
      ),
    );
  }
}