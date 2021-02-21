import 'package:flutter/material.dart';
import 'package:flutter_ctrip/dao/travel_params_dao.dart';
import 'package:flutter_ctrip/dao/travel_tab_dao.dart';
import 'package:flutter_ctrip/model/travel_params_model.dart';
import 'package:flutter_ctrip/model/travel_tab_model.dart';
import 'package:flutter_ctrip/pages/travel_tab_page.dart';

class TravelPage extends StatefulWidget {
  @override
  _TravelPageState createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> with TickerProviderStateMixin{
  TabController _tabController;
  TravelParamsModel _travelParamsModel;
  List<Groups> tabs = [];

  void _loadTab (){
    TravelTabDao.fetch().then((TravelTabModel model){
      setState(() {
        _tabController = TabController(length:model.district.groups.length, vsync: this);
        tabs = model.district.groups;
      });
    }).catchError((e){
      print(e);
    });
  }

  void _loadParams(){
    TravelParamsDao.fetch().then((TravelParamsModel model){
      setState(() {
        _travelParamsModel = model;
      });
    }).catchError((e){
      print(e);
    });
  }

  @override
  void initState() { 
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    _loadParams();
    _loadTab();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _paddomgTop = MediaQuery.of(context).padding.top;
    return Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top:_paddomgTop),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              labelPadding: EdgeInsets.fromLTRB(20, 0, 10, 5),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Color(0xff2fcfbb),
                  width: 3,
                ),
                insets: EdgeInsets.only(bottom:10)
              ),
              tabs: tabs.map((Groups tab){
                return Tab(text: tab.name);
              }).toList(),
            ),
          ),
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((Groups tab){
                  return TravelTabPage(
                    travelUrl: _travelParamsModel?.url,
                    params: _travelParamsModel?.params,
                    groupChannelCode: tab?.code,
                  );
                }).toList(),
            ),
          )
      ],
    );
  }
}