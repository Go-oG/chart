import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///Chord 布局
class ChordTransform extends EdgeTransform {
  ///是否为一个圆
  bool circle = true;
  SNumber radius;
  List<SNumber> center;
  SNumber chordWidth;
  SNumber gap;
  double startAngle;
  GraphSort? nodeSort;
  EdgeSort? edgeSort;

  ChordTransform(
    super.childFun, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radius = const SNumber.percent(95),
    this.startAngle = 0,
    this.gap = const SNumber.percent(0.01),
    this.chordWidth = const SNumber.number(16),
    this.circle = true,
  });

  ///存储布局参数
  final _Attr _attr = _Attr();

  @override
  void transform(Context context, double width, double height, Graph? graph) {
    if (graph == null) {
      return;
    }

    _computeAttr(width, height);

    var helper = ChordHelper(graph, false, sortFun: nodeSort, edgeSort: edgeSort);
    helper.handle(graph.edges);

    List<Edge> links = graph.edges;

    List<GraphNode> dataList = helper.dataList;

    final double allSize = circle ? 360 : _attr.radius * 2;
    int n = dataList.length;
    double allPad = 0;
    if (n > 1) {
      allPad = _attr.gap * n;
    }
    double remainSize = allSize - allPad;

    double k = remainSize / sumBy<GraphNode>(dataList, (p0) => p0.value);

    ///记录偏移量
    Map<GraphNode, double> offsetMap = {};
    double startOffset = circle ? startAngle : 0;
    each(dataList, (data, p1) {
      double sw = k * data.value;
      data.center = _attr.center;
      if (circle) {
        data.startAngle = startOffset;
        data.sweepAngle = sw;
        data.inRadius = _attr.radius - _attr.chordWidth;
        data.outRadius = _attr.radius;
        data.cornerRadius = 0;
        data.pad = _attr.gap;
        data.maxRadius = _attr.radius;
        startOffset += sw + _attr.gap;
      } else {
        var asw = sw.abs();
        data.x = startOffset + asw / 2;
        data.y = height - _attr.chordWidth / 2;
        data.width = asw;
        data.height = _attr.chordWidth;
        startOffset += _attr.gap + asw;
      }
      offsetMap[data] = startOffset;
    });

    ///计算每个link的位置
    each(links, (p0, p1) {
      var source = p0.source;
      var so = offsetMap[source]!;
      var sw = k * p0.value;

      p0.extra1 = so.toDouble();
      p0.extra2 = so + sw;
      offsetMap[source] = so + sw;

      var target = p0.target;
      so = offsetMap[target]!;
      p0.extra3 = so.toDouble();
      p0.extra4 = so + sw;
      offsetMap[target] = so + sw;
    });

    ///构建Shape
    each(dataList, (data, p1) {
      data.shape = buildShape(context, data);
    });

    each(links, (link, p1) {
      if (circle) {
        link.shape = buildPathFromLink(context, link);
      } else {
        link.shape = buildPathFromLink2(context, link);
      }
    });
  }

  void _computeAttr(double width, double height) {
    _attr.center = Offset(center.first.convert(width), center.last.convert(height));
    _attr.radius = radius.convert(min(width, height) / 2);
    _attr.chordWidth = chordWidth.convert(min(width, height) / 2);
    _attr.gap = gap.convert(circle ? 360 : min(width, height) / 2);
    _attr.startAngle = startAngle;
    _attr.chordRadius = _attr.radius - _attr.chordWidth;
  }

  PathShape buildPathFromLink(Context context, Edge link) {
    var center = _attr.center;
    double sourceRadius = link.source.inRadius;
    double sourceStartAngle = link.extra1 * angleUnit;
    double sourceEndAngle = link.extra2 * angleUnit;
    double targetRadius = link.target.inRadius;
    double targetStartAngle = link.extra3 * angleUnit;
    double targetEndAngle = link.extra4 * angleUnit;

    Path path = Path();
    Offset sourceStart = circlePointRadian(sourceRadius, sourceStartAngle, center);
    path.moveTo2(sourceStart);
    Rect rect = Rect.fromCircle(center: center, radius: sourceRadius);
    path.arcTo(rect, sourceStartAngle, sourceEndAngle - sourceStartAngle, false);

    Offset c2 = circlePointRadian(targetRadius, targetStartAngle, center);
    path.quadraticBezierTo(center.dx, center.dy, c2.dx, c2.dy);
    rect = Rect.fromCircle(center: center, radius: targetRadius);
    path.arcTo(rect, targetStartAngle, targetEndAngle - targetStartAngle, false);
    path.quadraticBezierTo(center.dx, center.dy, sourceStart.dx, sourceStart.dy);
    path.close();
    return PathShape(path);
  }

  CShape buildPathFromLink2(Context context, Edge link) {
    double starSX = link.extra1;
    double starEX = link.extra2;
    double endSX = link.extra3;
    double endEX = link.extra4;

    var radius = ((endEX - starEX) / 2).abs();
    var center = Offset(starSX + radius, link.source.y);

    Path path = Path();
    path.moveTo((starSX + starEX) / 2, link.source.y);
    var endOff = Offset((endSX + endEX) / 2, link.source.y);

    var cr = (endOff.dx - center.dx);
    path.arcToPoint(endOff, radius: Radius.circular(cr), largeArc: true, clockwise: true);
    return PathShape(path);
  }

  CShape buildShape(Context context, GraphNode node) {
    if (circle) {
      return Arc(
          center: node.center,
          startAngle: node.startAngle,
          sweepAngle: node.sweepAngle,
          innerRadius: node.inRadius,
          outRadius: node.outRadius,
          cornerRadius: node.cornerRadius,
          padAngle: node.pad,
          maxRadius: node.maxRadius!);
    }
    var l = node.x - node.width / 2;
    var t = node.y - node.height / 2;
    var r = node.x - node.width / 2;
    var b = node.y - node.height / 2;
    return CRect(left: l, top: t, right: r, bottom: b);
  }
}

class ChordHelper {
  ///标识是否为有向
  final bool direction;
  late Map<GraphNode, List<Edge>> outMap = {};
  late Map<GraphNode, List<Edge>> innerMap = {};
  late List<GraphNode> dataList = [];

  GraphSort? sortFun;
  EdgeSort? edgeSort;

  ChordHelper(
    Graph graph,
    this.direction, {
    this.sortFun,
    this.edgeSort,
  });

  void handle(List<Edge> data) {
    Map<GraphNode, List<Edge>> outMap = {};
    Map<GraphNode, List<Edge>> innerMap = {};
    each(data, (link, p1) {
      var source = link.source;
      var target = link.target;
      //source-outer
      List<Edge> list = outMap[source] ?? [];
      outMap[source] = list;
      list.add(link);

      //target-inner
      list = innerMap[target] ?? [];
      innerMap[target] = list;
      list.add(link);

      if (!direction) {
        //source-inner
        list = innerMap[source] ?? [];
        innerMap[source] = list;
        list.add(link);

        //target-outer
        list = outMap[target] ?? [];
        outMap[target] = list;
        list.add(link);
      }
    });

    each(outMap.keys, (p0, p1) {
      p0.value = 0;
    });

    ///统计值
    each(data, (link, p1) {
      var source = link.source;
      var target = link.target;
      source.value += link.value;
      target.value += link.value;
    });

    var linkFun = edgeSort;
    if (linkFun != null) {
      outMap.forEach((key, value) {
        linkFun.sort(value);
      });
    }
    List<GraphNode> list = List.from(outMap.keys);
    var sortFun = this.sortFun;
    if (sortFun != null) {
      sortFun.sort(list);
    }

    this.outMap = outMap;
    this.innerMap = innerMap;
    dataList = list;
  }
}

class _Attr {
  Offset center = Offset.zero;
  double radius = 0;
  double chordWidth = 0;
  double gap = 0;
  double startAngle = 0;
  double chordRadius = 0;
}
