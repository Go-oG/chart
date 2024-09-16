import 'package:e_chart/e_chart.dart';

///负责创建所有的视图
class ViewManager extends Disposable {
  ///坐标系
  Map<String, CoordView> _coordMap = {};

  Map<String, Coord> _coordMap2 = {};

  ChartViewGroup? rootView;

  void parse(Context context, ChartOption option) {
    Map<String, CoordView> coordMap = {};
    Map<String, Coord> coordMap2 = {};

    ///创建坐标系组件
    List<Coord> coordList = [
      ...option.gridList,
      ...option.polarList,
      ...option.radarList,
      ...option.calendarList,
      ...option.parallelList,
    ];
    for (var coord in coordList) {
      coordMap2[coord.id] = coord;
      var c = coordFactory.convert(context, coord) ?? coord.toCoord(context);
      if (c == null) {
        throw ChartError('无法转换对应的坐标系:$coord');
      }
      coordMap[coord.id] = c;
    }

    ///创建渲染视图
    var viewMap = _createRenderView(context, option);
    _bindViewWithCoord(context, viewMap, coordMap);

    ChartViewGroup rootView = FrameLayout(context);
    for (var coord in coordList) {
      rootView.addView(coordMap[coord.id]!);
    }
    _coordMap = coordMap;
    _coordMap2 = coordMap2;
    this.rootView = rootView;
  }

  ///创建渲染视图
  Map<Geom, ChartView> _createRenderView(Context context, ChartOption option) {
    Map<Geom, ChartView> seriesViewMap = {};

    ///转换Series到View
    each(option.geoms, (geom, i) {
      ChartView? view = geomFactory.convert(context, geom) ?? geom.toView(context);
      if (view == null) {
        throw ChartError('${geom.runtimeType} init fail,you must provide series convert');
      }
      seriesViewMap[geom] = view;
    });

    return seriesViewMap;
  }

  void _bindViewWithCoord(Context context, Map<Geom, ChartView> viewMap, Map<String, CoordView> coordMap) {
    ///将指定了坐标系的View和坐标系绑定
    viewMap.forEach((key, view) {
      var layout = findCoord(key.coordId, coordMap);
      if (layout == null) {
        layout = SingleCoord(context, key.coordId);
        coordMap[key.coordId] = layout;
      }
      layout.addView(view);
    });
  }

  CoordView? findCoord(String coordId, [Map<String, CoordView>? coordMap]) {
    var map = coordMap ?? _coordMap;
    return map[coordId];
  }

  Coord? findCoord2(String coordId) {
    return _coordMap2[coordId];
  }

  @override
  void dispose() {
    _coordMap = {};
    rootView?.dispose();
    rootView = null;
    super.dispose();
  }
}
