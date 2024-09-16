import 'dart:math' as m;
import 'package:flutter/widgets.dart';
import 'package:e_chart/e_chart.dart';

import 'g_transform.dart';
///网格布局
class GGridTransform extends GTransform {
  ///左上角开始位置
  List<SNumber> begin;

  ///为true时最大化占用画布空间
  bool fullCanvas;

  ///指定行列数
  int? rows;
  int? cols;

  ///是否防止重叠(当为true时，才会使用nodeSize进行碰撞检查)
  bool preventOverlap;

  ///位置函数(可用于固定位置)
  Fun4<GraphNode, int, int, m.Point<int>?>? positionFun;

  GGridTransform(
    super.childFun, {
    this.rows,
    this.cols,
    this.begin = const [SNumber.number(0), SNumber.number(0)],
    this.fullCanvas = true,
    this.preventOverlap = false,
    super.nodeSpaceFun,
    super.sort,
  });

  @override
  void transform(Context context, double width, double height, Graph? graph) {
    if (graph == null) {
      return;
    }
    int nodeCount = graph.nodes.length;
    if (nodeCount == 0) {
      return;
    }

    _Attr props = _Attr();
    props.begin = Offset(begin[0].convert(width), begin[1].convert(height));
    if (nodeCount == 1) {
      graph.nodes[0].x = props.begin.dx;
      graph.nodes[0].y = props.begin.dy;
      notifyLayoutEnd();
      return;
    }

    List<GraphNode> layoutNodes = [...graph.nodes];

    ///排序
    sortNode(graph, layoutNodes);

    ///计算 实际的行列数并赋值
    _computeRowAndCol(props, nodeCount, width, height);

    if (props.rows <= 0 || props.cols <= 0) {
      throw FlutterError('内部异常 行列计算值<=0');
    }

    ///修正 row col
    if (props.cols * props.rows > props.cells) {
      int sm = _small(props, null)!;
      int lg = _large(props, null)!;
      if ((sm - 1) * lg >= props.cells) {
        _small(props, sm - 1);
      } else if ((lg - 1) * sm >= props.cells) {
        _large(props, lg - 1);
      }
    } else {
      while (props.cols * props.rows < props.cells) {
        int sm = _small(props, null)!;
        int lg = _large(props, null)!;
        if ((lg + 1) * sm >= props.cells) {
          _large(props, lg + 1);
        } else {
          _small(props, sm + 1);
        }
      }
    }

    ///计算单元格大小
    props.cellWidth = width / props.cols;
    props.cellHeight = height / props.rows;
    if (!fullCanvas) {
      props.cellWidth = 0;
      props.cellHeight = 0;
    }

    // 防重叠处理(重新计算格子宽度)
    if (preventOverlap || nodeSpaceFun != null) {
      Fun2<GraphNode, num> spaceFun = nodeSpaceFun ?? (a) => 10;
      for (var node in layoutNodes) {
        Size res = node.size;
        num nodeW;
        num nodeH;
        nodeW = res.width;
        nodeH = res.height;
        num p = spaceFun.call(node);
        var w = nodeW + p;
        var h = nodeH + p;
        props.cellWidth = m.max(props.cellWidth, w);
        props.cellHeight = m.max(props.cellHeight, h);
      }
    }

    props.rowIndex = 0;
    props.colIndex = 0;
    props.id2manPos = {};

    for (var node in layoutNodes) {
      m.Point<int>? rcPos;

      ///固定位置处理
      if (positionFun != null) {
        rcPos = positionFun!.call(node, props.rows, props.cols);
      }
      if (rcPos != null) {
        _InnerPos pos = _InnerPos(rcPos.x, rcPos.y);
        props.id2manPos[node.id] = pos;
        _setUsed(props, pos.row, pos.col);
      }
      _computePosition(props, node);
    }
  }

  int? _small(_Attr props, int? val) {
    int? res;
    int rows = jsOr(props.rows, 5);
    int cols = jsOr(props.cols, 5);
    if (val == null) {
      res = m.min(rows, cols);
    } else {
      var minV = m.min(rows, cols);
      if (minV == props.rows) {
        props.rows = val;
      } else {
        props.cols = val;
      }
    }
    return res;
  }

  int? _large(_Attr props, int? val) {
    int? res;
    int rows = jsOr(props.rows, 5);
    int cols = jsOr(props.cols, 5);
    if (val == null) {
      res = m.max(rows, cols);
    } else {
      var maxV = m.max(rows, cols);
      if (maxV == props.rows) {
        props.rows = val.toInt();
      } else {
        props.cols = val.toInt();
      }
    }
    return res;
  }

  bool _hasUsed(_Attr props, int? row, int? col) {
    return jsTrue(jsOr(props.cellUsed['c-$row-$col'], false));
  }

  void _setUsed(_Attr props, int row, int col) {
    props.cellUsed['c-$row-$col'] = true;
  }

  void _moveToNextCell(_Attr props) {
    var cols = jsOr(props.cols, 5);
    props.colIndex += 1;
    if (props.colIndex >= cols) {
      props.colIndex = 0;
      props.rowIndex += 1;
    }
  }

  void _computePosition(_Attr props, GraphNode node) {
    num x;
    num y;
    var rcPos = props.id2manPos[node.id];
    if (rcPos != null) {
      x = rcPos.col * props.cellWidth + props.cellWidth / 2 + props.begin.dx;
      y = rcPos.row * props.cellHeight + props.cellHeight / 2 + props.begin.dy;
    } else {
      while (_hasUsed(props, props.rowIndex, props.colIndex)) {
        _moveToNextCell(props);
      }
      x = props.colIndex * props.cellWidth + props.cellWidth / 2 + props.begin.dx;
      y = props.rowIndex * props.cellHeight + props.cellHeight / 2 + props.begin.dy;
      _setUsed(props, props.rowIndex, props.colIndex);
      _moveToNextCell(props);
    }
    node.x = x.toDouble();
    node.y = y.toDouble();
  }

  ///计算行 列数
  void _computeRowAndCol(_Attr props, int nodeCount, num width, num height) {
    int? oRows = rows;
    int? oCols = cols;
    props.cells = nodeCount;

    if (oRows != null && oRows > 0 && oCols != null && oCols > 0) {
      props.rows = oRows;
      props.cols = oCols;
    } else if (oRows != null && oRows > 0 && (oCols == null || oCols <= 0)) {
      props.rows = oRows;
      props.cols = (props.cells / rows!).ceil();
    } else if ((oRows == null || oRows <= 0) && oCols != null && oCols > 0) {
      props.cols = oCols;
      props.rows = (props.cells / cols!).ceil();
    } else {
      props.splits = m.sqrt((props.cells * height) / width);
      rows = props.splits.round();
      cols = ((width / height) * props.splits).round();
    }
    props.rows = m.max(props.rows, 1);
    props.cols = m.max(props.cols, 1);
  }
}

class _InnerPos {
  final int row;
  final int col;

  _InnerPos(this.row, this.col);
}

class _Attr {
  Offset begin = Offset.zero;

  ///记录实际的row 和行数
  int rows = 0;
  int cols = 0;
  num cells = 0;

  //单元格的大小
  num cellWidth = 0;
  num cellHeight = 0;

  ///记录当前访问的行和列索引
  int rowIndex = 0;
  int colIndex = 0;

  ///分割数
  late num splits;

  ///存放已经使用的单元格
  Map<String, bool> cellUsed = {};

  ///存放位置映射
  Map<String, _InnerPos> id2manPos = {};
}
