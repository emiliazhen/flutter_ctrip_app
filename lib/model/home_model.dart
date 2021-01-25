import 'package:flutter_ctrip/model/common_model.dart';
import 'package:flutter_ctrip/model/config_model.dart';
import 'package:flutter_ctrip/model/grid_nav_model.dart';
import 'package:flutter_ctrip/model/sales_box_model.dart';

class HomeModel {
  final ConfigModel config;
  final List<CommonModel> bannerList;
  final List<CommonModel> localNavList;
  final GridNavModel gridNav;
  final List<CommonModel> subNavList;
  final SalesBoxModel salesBox;
  HomeModel({this.config,this.bannerList,this.localNavList,this.gridNav,this.subNavList,this.salesBox});
  factory HomeModel.fromJson(Map<String,dynamic>json){
    var bannerJson = json['bannerList'] as List;
    var localNavJson = json['localNavList'] as List;
    var subNavJson = json['subNavList'] as List;
    List<CommonModel> bannerList = bannerJson.map((item) => CommonModel.fromJson(item)).toList();
    List<CommonModel> localNavList = localNavJson.map((item) => CommonModel.fromJson(item)).toList();
    List<CommonModel> subNavList = subNavJson.map((item) => CommonModel.fromJson(item)).toList();
    return HomeModel(
      config: ConfigModel.fromJson(json['config']),
      bannerList: bannerList,
      localNavList: localNavList,
      gridNav: GridNavModel.fromJson(json['gridNav']),
      subNavList: subNavList,
      salesBox: SalesBoxModel.fromJson(json['salesBox']),
    );
  }
}