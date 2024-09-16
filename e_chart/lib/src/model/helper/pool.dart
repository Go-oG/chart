import 'package:e_chart/e_chart.dart';

class Pool<T> with Disposable {
  final Fun1<T> builder;
  final void Function(T obj, Map<String, dynamic> fields) filler;
  List<T> _poolList = [];
  late int _maxPoolSize;

  Pool(this.builder, this.filler, [int maxCount = 10]) {
    checkArgs(maxCount > 0);
    _maxPoolSize = maxCount;
  }

  T get([Map<String, dynamic>? fields]) {
    T? first = _poolList.removeFirstOrNull();
    first ??= builder.call();
    if (fields != null) {
      filler.call(first as T, fields);
    }
    return first as T;
  }

  void recycle(dynamic data) {
    if (data == null) {
      return;
    }
    if (data! is T) {
      return;
    }
    if (_poolList.length < _maxPoolSize) {
      _poolList.add(data);
      if (data is Disposable) {
        data.dispose();
        return;
      }
      try {
        data?.dispose();
      } catch (e) {
        Logger.i(e);
      }
    }
  }

  void setMaxCount(int size) {
    checkArgs(size > 0);
    if (_maxPoolSize == size) {
      return;
    }
    _maxPoolSize = size;
    if (_poolList.length > size) {
      _poolList.removeRange(0, size);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _poolList = [];
  }
}
