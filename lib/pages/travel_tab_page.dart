import 'package:flutter/material.dart';
import 'package:flutter_ctrip/dao/travel_,dao.dart';
import 'package:flutter_ctrip/model/travel_model.dart';
import 'package:flutter_ctrip/widget/loading_container.dart';
import 'package:flutter_ctrip/widget/webview.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

const _TRAVEL_URL =
    'https://m.ctrip.com/restapi/soa2/16189/json/searchTripShootListForHomePageV2?_fxpcqlniredt=09031014111431397988&__gw_appid=99999999&__gw_ver=1.0&__gw_from=10650013707&__gw_platform=H5';
const _PAGE_SIZE = 20;
class TravelTabPage extends StatefulWidget {
  final String travelUrl;
  final Map params;
  final String groupChannelCode;
  const TravelTabPage({Key key,this.travelUrl,this.params,this.groupChannelCode}):super(key:key);

  @override
  _TravelTabPageState createState() => _TravelTabPageState();
}

class _TravelTabPageState extends State<TravelTabPage> with AutomaticKeepAliveClientMixin{
  List<TravelItemModel> _travelItems;
  int _pageIndex = 1;
  ScrollController _scrollController = ScrollController();
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() { 
    super.initState();
    _loadData();
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        _loadData();
      }
     });
  }

  void _loadData({ loadMore = false}){
    if(loadMore){
      _pageIndex++;
    }else {
      _pageIndex = 1;
    }
    TravelDao.fetch(widget.travelUrl ?? _TRAVEL_URL,widget.params,widget.groupChannelCode,_pageIndex,_PAGE_SIZE).then((TravelModel model){
      _loading = false;
      setState(() {
        List<TravelItemModel> items = _filterItems(model.resultList);
        if(_travelItems != null){
          _travelItems.addAll(items);
        }else {
          _travelItems = items;
        }
      });
    }).catchError((e){
      _loading = false;
      print(e);
    });
  }

  Future<Null> _handelRefresh() async{
    _loadData();
    return null;
  }

  List<TravelItemModel> _filterItems(List<TravelItemModel> resultList){
    if(resultList == null) return [];
    List<TravelItemModel> filterItems = [];
    resultList.forEach((item) { 
      if(item.article != null ){
        filterItems.add(item);
      }
    });
    return filterItems;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: LoadingContainer(
        isLoading: _loading,
        child: RefreshIndicator(
          onRefresh: _handelRefresh,
          child: MediaQuery.removePadding(
            context: context, 
            removeTop: true,
            child: StaggeredGridView.countBuilder(
              controller: _scrollController,
              crossAxisCount: 4,
              itemCount: _travelItems?.length ?? 0,
              itemBuilder: (BuildContext context, int index) => _TravelItem(
                index: index,
                item: _travelItems[index]
              ),
              staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
            ),
          ),
        )
      ) 
    );
  }
}

class _TravelItem extends StatelessWidget {
  final int index;
  final TravelItemModel item;
  const _TravelItem({Key key,this.index,this.item}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(item.article.urls != null && item.article.urls.length > 0){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => WebView(
              url: item.article.urls[0].h5Url,
              title: '详情',
            )
          ));
        }
      },
      child: Card(
        child: PhysicalModel(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _itemImage(),
              Container(
                padding: EdgeInsets.all(4),
                child: Text(
                  item.article.articleTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14
                  ),
                ),
              ),
              _infoText()
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemImage() {
    return Stack(
      children: <Widget>[
        Image.network(item.article.images[0]?.dynamicUrl),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right:3),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                LimitedBox(
                  maxWidth: 130,
                  child: Text(
                    item.article.pois == null || item.article.pois.length == 0 ? '未知': item.article.pois[0]?.poiName ?? '未知',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _infoText() {
    return Container(
      padding: EdgeInsets.fromLTRB(6, 0, 6, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              PhysicalModel(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.article.author?.coverImage?.dynamicUrl,
                  width: 24,
                  height: 24,
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                width: 90,
                child: Text(
                  item.article.author?.nickName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Icon(Icons.thumb_up,size:14,color: Colors.grey),
              Padding(
                padding: EdgeInsets.only(left:3),
                child: Text(
                  item.article.likeCount.toString(),
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}