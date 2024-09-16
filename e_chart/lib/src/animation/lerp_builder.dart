import 'package:e_chart/e_chart.dart';

class LerpBuilder {
  AnimateOption? option;
  List<AnimateType> typeList;

  LerpBuilder(this.option, this.typeList);

  Attrs onStart(DataNode node, DiffType type) {
    return Attrs();
  }

  Attrs onEnd(DataNode node, DiffType type) {
    return Attrs();
  }

  void onLerp(DataNode node, Attrs s, Attrs e, double t, DiffType type) {
    node.fillFromAttr(s.lerp(e, t));
  }
}
