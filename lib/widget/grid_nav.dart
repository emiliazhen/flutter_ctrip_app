import 'package:flutter/material.dart';
import 'package:flutter_ctrip/model/grid_nav_model.dart';
class GridNav extends StatelessWidget {
  final GridNavModel gridNavModel;
  const GridNav({Key key,@required this.gridNavModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Grid'),
    );
  }
}