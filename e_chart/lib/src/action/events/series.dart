import 'package:e_chart/e_chart.dart';

class ViewScaleEvent extends ChartEvent {
  Geom? _geom;

  Geom? get geom => _geom;
  final String viewId;
  double zoom;
  double originX;
  double originY;

  ViewScaleEvent(Geom geom, this.viewId, this.zoom, this.originX, this.originY) {
    _geom = geom;
  }

  @override
  EventType get eventType => EventType.viewScale;

  @override
  void dispose() {
    super.dispose();
    _geom = null;
  }
}

class ViewTranslationEvent extends ChartEvent {
  Geom? _series;

  Geom? get series => _series;

  final String viewId;
  double translationX;
  double translationY;

  ViewTranslationEvent(Geom series, this.viewId, this.translationX, this.translationY) {
    _series = series;
  }

  @override
  EventType get eventType => EventType.viewTranslation;

  @override
  void dispose() {
    super.dispose();
    _series = null;
  }
}
