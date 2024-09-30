import 'dart:async';

import 'package:e_chart/e_chart.dart';

extension IterableExt<T> on Iterable<T> {
  List<T> copy() {
    return List.from(this);
  }

  List<List<T>> chunk(int count) {
    checkArgs(count > 0);
    List<List<T>> rl = [];
    List<T> tmpList = [];
    for (var data in this) {
      tmpList.add(data);
      if (tmpList.length >= count) {
        rl.add(tmpList);
        tmpList = [];
      }
    }
    if (tmpList.isNotEmpty) {
      rl.add(tmpList);
    }
    return rl;
  }

  List<T> concat(Iterable<Iterable<T>> iterable) {
    List<T> rl = copy();
    for (var v in iterable) {
      rl.addAll(v);
    }
    return rl;
  }

  void each(void Function(T, int) call) {
    var index = 0;
    for (var item in this) {
      call.call(item, index);
      index += 1;
    }
  }

  void eachRight(void Function(T, int) call) {
    List<T> tl;
    if (this is List<T>) {
      tl = this as List<T>;
    } else {
      tl = List.from(this);
    }

    for (int i = tl.length - 1; i >= 0; i--) {
      call.call(tl[i], i);
    }
  }

  List<K> map2<K>(K Function(T) convert) {
    List<K> rl = [];
    for (var v in this) {
      rl.add(convert.call(v));
    }
    return rl;
  }

  ///分组
  Map<K, List<T>> groupBy<K>(K Function(T) convert) {
    Map<K, List<T>> map = {};
    for (var v in this) {
      K k = convert.call(v);
      if (map.containsKey(k)) {
        map[k]!.add(v);
      } else {
        List<T> rl = [];
        rl.add(v);
        map[k] = rl;
      }
    }
    return map;
  }

  K reduce2<K>(K Function(K, T) call, K initValue) {
    var k = initValue;
    for (var n in this) {
      k = call.call(k, n);
    }
    return k;
  }

  Set<T> toSet([bool copySelf = true]) {
    if (this is Set) {
      if (copySelf) {
        return Set.from(this);
      }
      return this as Set<T>;
    }
    return Set.from(this);
  }

  List<T> toList([bool copySelf = true]) {
    if (this is List) {
      if (copySelf) {
        return List.from(this);
      }
      return this as List<T>;
    }
    return List.from(this);
  }

  ///返回一个按顺序排列的唯一值的List
  List<T> union() {
    return unionBy<T>((p0) => p0);
  }

  List<T> unionBy<K>(K? Function(T) convert) {
    List<T> rl = [];
    Set<K?> set = {};
    for (var v in this) {
      var k = convert(v);
      if (set.contains(k)) {
        continue;
      }
      rl.add(v);
      set.add(k);
    }
    return rl;
  }

  T? find(bool Function(T) call) {
    for (var v in this) {
      if (call.call(v)) {
        return v;
      }
    }
    return null;
  }

  T? findLast(bool Function(T) call) {
    for (var v in toList().reversed) {
      if (call.call(v)) {
        return v;
      }
    }
    return null;
  }

  int findIndex(T? data) {
    int i = 0;
    for (var v in this) {
      if (v == data) {
        return i;
      }
    }
    return -1;
  }
  int findIndexBy(T? data, bool Function(T?,T?) call) {
    int i = 0;
    for (var v in this) {
      if (call.call(data,v)) {
        return i;
      }
    }
    return -1;
  }



}

extension ListExt<T> on List<T> {
  T? removeLastOrNull() {
    if (this.isEmpty) {
      return null;
    }
    return removeLast();
  }

  T? removeFirstOrNull() {
    if (this.isEmpty) {
      return null;
    }
    return removeAt(0);
  }

  void fill(Iterable<T> values, [int start = 0, int? end]) {
    if (start >= length) {
      addAll(values);
      return;
    }
    if (end == null || end > length) {
      end = length;
    }
    replaceRange(start, end, values);
  }

  ///去除该List前n个元素
  void drop(int n) {
    checkArgs(n > 0);

    if (this.isEmpty) {
      return;
    }

    if (n >= length) {
      clear();
      return;
    }
    removeRange(0, n);
  }

  void reverseSelf() {
    List<T> rl = List.from(reversed);
    clear();
    addAll(rl);
  }

  void removeAll(Iterable<T> list) {
    Set<T> dataSet;
    if (list is Set) {
      dataSet = list as Set<T>;
    } else {
      dataSet = Set.from(list);
    }

    removeWhere((t) => dataSet.contains(t));
  }

  int findLastIndex(T? data) {
    for (var i = length - 1; i >= 0; i--) {
      if (this[i] == data) {
        return i;
      }
    }
    return -1;
  }
}

void each<T>(Iterable<T> list, void Function(T, int) call) {
  var index = 0;
  for (var item in list) {
    call.call(item, index);
    index += 1;
  }
}

FutureOr<void> each2<T>(Iterable<T> list, FutureOr<void> Function(T, int) call) async {
  var index = 0;
  for (var item in list) {
    await call.call(item, index);
    index += 1;
  }
}

List<List<T>> chunk<T>(Iterable<T?> list) {
  List<List<T>> rl = [];
  List<T> tmpList = [];
  for (var t in list) {
    if (t != null) {
      tmpList.add(t);
    } else {
      rl.add(tmpList);
      tmpList = [];
    }
  }
  if (tmpList.isNotEmpty) {
    rl.add(tmpList);
  }
  return rl;
}

List<dynamic> toList(dynamic data) {
  if (data == null) {
    return [];
  }
  if (data is List) {
    return data;
  }
  return [data];
}

List<T> concat<T>(Iterable<Iterable<T>> iterable) {
  List<T> rl = [];
  for (var v in iterable) {
    rl.addAll(v);
  }
  return rl;
}

///将给定的嵌套数组全部合并成一层数组
List<T> flatten<T>(Iterable<dynamic> list) {
  List<T> rl = [];
  for (var v in list) {
    if (v is T) {
      rl.add(v);
    } else if (v is Iterable<T>) {
      rl.addAll(flatten(v));
    } else {
      throw ChartError('List 中只能存放一种数据');
    }
  }
  return rl;
}

bool equalList<T>(List<T?> s, List<T?> e) {
  if (s.length != e.length) {
    return false;
  }
  if (s.isEmpty) {
    return true;
  }
  for (int i = 0; i < s.length; i++) {
    var sv = s[i];
    var ev = e[i];
    if (sv != ev) {
      return false;
    }
  }
  return true;
}

bool equalSet<T>(Iterable<T>? s, Iterable<T>? e) {
  int ls = s?.length ?? 0;
  int le = e?.length ?? 0;
  if (ls != le) {
    return false;
  }
  if (ls == 0) {
    return true;
  }

  Set<T> tmpSet;
  if (e is Set) {
    tmpSet = e as Set<T>;
  } else {
    tmpSet = Set.from(e!);
  }

  for (var data in s!) {
    if (data == null) {
      continue;
    }
    if (!tmpSet.contains(data)) {
      return false;
    }
  }
  return true;
}
