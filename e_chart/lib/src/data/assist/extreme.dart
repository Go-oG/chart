import 'package:e_chart/e_chart.dart';

class DataExtreme {
  List<num> numExtreme;
  List<String> strExtreme;
  List<DateTime> timeExtreme;

  late List<dynamic> _info;

  DataExtreme(
    this.numExtreme,
    this.strExtreme,
    this.timeExtreme,
  ) {
    _info = [...numExtreme, ...strExtreme, ...timeExtreme];
  }

  void addData(dynamic data) {
    if (data == null) {
      return;
    }

    if (data is List) {
      for (var d2 in data) {
        addData(d2);
      }
      return;
    }

    if (data is num) {
      numExtreme.add(data);
      return;
    }
    if (data is String) {
      strExtreme.add(data);
      return;
    }
    if (data is DateTime) {
      timeExtreme.add(data);
      return;
    }

    Logger.w("mapping Fail only support num String DateTime current type is: ${data.runtimeType}");

    //  throw ChartError("mapping Fail only support num String DateTime");
  }

  void merge() {
    if (numExtreme.length > 1) {
      numExtreme = extremes<num>(numExtreme, (a) {
        return a;
      });
      if (numExtreme.length >= 2) {
        var first = numExtreme.first;
        var end = numExtreme.last;
        if (first == end) {
          numExtreme.removeAt(numExtreme.length - 1);
        }
      }
    }
    if (strExtreme.length > 1) {
      strExtreme = strExtreme.union();
    }
    if (timeExtreme.length > 1) {
      timeExtreme = timeExtreme.union();
      timeExtreme.sort((a, b) {
        return a.millisecondsSinceEpoch.compareTo(b.millisecondsSinceEpoch);
      });
    }
  }

  double computeRatio(dynamic data) {
    if (data == null) {
      return 0;
    }

    if (data is num) {
      if (numExtreme.isEmpty) {
        return 0;
      }
      var first = numExtreme.first;
      var last = numExtreme.last;
      var sub = last - first;
      if (sub <= 1e-6) {
        return 0;
      }
      return (data - numExtreme.first) / sub;
    }

    if (data is String) {
      var index = strExtreme.indexOf(data);
      if (index == -1 || strExtreme.length <= 1) {
        return 0;
      }
      return index / (strExtreme.length.toDouble());
    }

    if (data is DateTime) {
      var index = timeExtreme.indexOf(data);
      if (index == -1 || timeExtreme.length <= 1) {
        return 0;
      }
      return index / (timeExtreme.length).toDouble();
    }

    throw ChartError("un support");
  }

  void syncData() {
    _info = [...numExtreme, ...strExtreme, ...timeExtreme];
  }

  List<dynamic> getExtreme(AxisType type) {
    if (type == AxisType.category) {
      return strExtreme;
    }
    if (type == AxisType.time) {
      return timeExtreme;
    }

    return numExtreme;
  }

  List<dynamic> getAllExtreme() {
    return _info;
  }
}
