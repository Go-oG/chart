import 'package:e_chart/e_chart.dart';

///线条视图
///通常会进行排序等操作
class LineView extends PathView<LineGeom> {
  LineView(super.context, super.series);

  @override
  Attrs onBuildAnimateStarAttrs(DataNode node, DiffType type) {
    var attr = {Attr.x: node.x, Attr.y: node.y};
    if (type == DiffType.add) {
      attr[Attr.y] = height;
    }
    return attr;
  }

  @override
  Attrs onBuildAnimateEndAttrs(DataNode node, DiffType type) {
    var attr = {Attr.x: node.x, Attr.y: node.y};
    if (type == DiffType.remove) {
      attr[Attr.y] = height * 2;
    }
    return attr;
  }

  @override
  void sortGroupList(List<DataNode> list) {
    var y = context.dataManager.getAxisScale2(geom.coordId, geom.yPos);
    Dim dim;
    if (y.isCategory) {
      dim = Dim.y;
    } else {
      dim = Dim.x;
    }
    list.sort((a, b) {
      return a.normalize.get(dim).first.compareTo(b.normalize.get(dim).first);
    });
  }
}
