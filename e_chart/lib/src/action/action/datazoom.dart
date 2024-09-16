import '../../coord/coord.dart';
import '../action.dart';

class DataZoomAction extends ChartAction {
  final Coord coord;
  final num start;
  final num end;

  DataZoomAction(this.coord, this.start, this.end, {super.fromUser});
}
