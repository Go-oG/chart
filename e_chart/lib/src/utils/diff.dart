import 'dart:async';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///Diff 比较工具类
///用于在布局中实现动画
class DiffUtil {
  ///给定前后的数据集
  ///按更新内别返回数据
  ///[updateUseOld] 为true 表示当数据类型为update时 保留原有数据， false则使用现有数据
  static DiffResult<N> diffData<N>(Iterable<N> oldList, Iterable<N> newList) {
    checkRef(oldList, newList, '在Diff中传入数据集引用不能相等');
    Set<N> oldSet = oldList.toSet();
    Set<N> newSet = newList.toSet();

    Set<N> addSet = {};
    Set<N> removeSet = {};
    Set<N> oldUpdateSet = {};
    Set<N> newUpdateSet = {};

    for (var data in newList) {
      if (!oldSet.contains(data)) {
        addSet.add(data);
      } else {
        newUpdateSet.add(data);
      }
    }

    for (var data in oldList) {
      if (!newSet.contains(data)) {
        removeSet.add(data);
      } else {
        oldUpdateSet.add(data);
      }
    }

    return DiffResult(addSet, removeSet, oldUpdateSet, newUpdateSet);
  }

  ///执行Diff动画相关
  static Future<List<AnimationNode>> diff<D extends DataNode>(
    AnimateOption? option,
    Iterable<D> oldList,
    Iterable<D> newList,
    FutureOr<void> Function(List<D> dataList) layoutFun,
    Attrs Function(D data, DiffType type) startFun,
    Attrs Function(D data, DiffType type) endFun,
    void Function(D data, Attrs s, Attrs e, double t, DiffType type) lerpFun,
    void Function(List<D> dataList, double t) updateCall, {
    VoidCallback? onStart,
    VoidCallback? onEnd,
    void Function(List<D> removeList)? removeDataCall,
    void Function(DiffResult<D> diffInfo)? diffInfoCall,
    bool forceUseUpdate = false,
  }) async {
    if (oldList.isEmpty && newList.isEmpty) {
      onStart?.call();
      updateCall.call([], 1);
      onEnd?.call();
      removeDataCall?.call([]);
      return [];
    }
    final List<D> newList2 = newList.toList();
    newList2.sort((a, b) {
      return a.dataIndex.compareTo(b.dataIndex);
    });

    if (option == null) {
      await layoutFun.call(newList2);
      onStart?.call();
      updateCall.call(newList2, 1);
      onEnd?.call();
      removeDataCall?.call(List.from(oldList));
      return [];
    }

    ///保留旧的数据
    var diffResult = diffData(oldList, newList);
    diffInfoCall?.call(diffResult);

    var newLen = diffResult.newUpdateSet.length;
    var oldLen = diffResult.oldUpdateSet.length;
    if (newLen != oldLen) {
      throw ChartError("Diff 状态异常 newLen:$newLen oldLen:$oldLen");
    }

    ///存储动画前后状态
    final Map<D, Attrs> startMap = {};
    final Map<D, Attrs> endMap = {};
    diffResult.oldUpdateSet.each((data, p1) {
      startMap[data] = startFun.call(data, DiffType.update);
    });
    diffResult.removeSet.each((data, p1) {
      startMap[data] = startFun.call(data, DiffType.remove);
      endMap[data] = endFun.call(data, DiffType.remove);
    });

    ///布局
    final List<D> layoutData = [...diffResult.addSet, ...diffResult.newUpdateSet];
    layoutData.sort((a, b) {
      return a.dataIndex.compareTo(b.dataIndex);
    });
    await layoutFun.call(layoutData);

    ///再次存储相关动画属性
    diffResult.addSet.each((data, p1) {
      startMap[data] = startFun.call(data, DiffType.add);
      endMap[data] = endFun.call(data, DiffType.add);
    });
    diffResult.newUpdateSet.each((data, p1) {
      endMap[data] = endFun.call(data, DiffType.update);
    });

    ///还原需要布局数据的初始状态
    diffResult.addSet.each((data, p1) {
      var s = startMap[data]!;
      var e = endMap[data]!;
      lerpFun.call(data, s, e, 0, DiffType.add);
    });
    diffResult.newUpdateSet.each((data, p1) {
      var s = startMap[data]!;
      var e = endMap[data]!;
      lerpFun.call(data, s, e, 0, DiffType.update);
    });

    final List<D> animatorList = [...diffResult.addSet, ...diffResult.newUpdateSet, ...diffResult.removeSet];
    List<D> updateCallList = animatorList;

    List<TweenWrap> tweenList = [];
    var addAnimate = Animate(0.0, 1.0, option: option);
    addAnimate.addListener((t) {
      for (var key in diffResult.addSet) {
        var s = startMap[key]!;
        var e = endMap[key]!;
        lerpFun.call(key, s, e, t, DiffType.add);
      }
      updateCall.call(updateCallList, t);
    });
    tweenList.add(TweenWrap(addAnimate, forceUseUpdate ? DiffType.update : DiffType.add));
    var removeAnimate = Animate(0.0, 1.0, option: option);
    removeAnimate.addListener((t) {
      for (var key in diffResult.removeSet) {
        var s = startMap[key]!;
        var e = endMap[key]!;
        lerpFun.call(key, s, e, t, DiffType.remove);
      }
      updateCall.call(updateCallList, t);
    });
    removeAnimate.addEndListener(() {
      updateCallList = newList2;
    });
    tweenList.add(TweenWrap(removeAnimate, forceUseUpdate ? DiffType.update : DiffType.remove));
    var updateAnimate = Animate(0.0, 1.0, option: option);
    updateAnimate.addListener((t) {
      for (var key in diffResult.newUpdateSet) {
        var s = startMap[key]!;
        var e = endMap[key]!;
        lerpFun.call(key, s, e, t, DiffType.update);
      }
      updateCall.call(updateCallList, t);
    });
    tweenList.add(TweenWrap(updateAnimate, DiffType.update));

    if (onStart != null) {
      tweenList.first.tween.addStartListener(() {
        onStart.call();
      });
    }

    if (onEnd != null || removeDataCall != null) {
      var endTween =
          option.duration.inMilliseconds >= option.updateDuration.inMilliseconds ? addAnimate : updateAnimate;
      endTween.addEndListener(() {
        onEnd?.call();
        removeDataCall?.call(List.from(diffResult.removeSet));
      });
    }

    List<AnimationNode> nl = [];
    for (var wrap in tweenList) {
      var type = wrap.type;
      if (type == DiffType.update || type == DiffType.remove) {
        nl.add(AnimationNode(wrap.tween, option, LayoutType.update));
      } else {
        nl.add(AnimationNode(wrap.tween, option, LayoutType.layout));
      }
    }
    return nl;
  }

  ///用于在点击或者hover触发时执行diff动画
  static List<AnimationNode> diffUpdate<N extends DataNode>(
    AnimateOption? attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    Attrs Function(N data, bool isOld) builder,
    Attrs Function(Attrs s, Attrs e, double t) lerpFun,
    void Function(N node, Attrs attr) callback,
    VoidCallback endCall,
  ) {
    if (identical(oldList, newList)) {
      throw ChartError("传入的前后引用不能相等");
    }
    Map<N, Attrs> startMap = {};
    Map<N, Attrs> endMap = {};

    oldList.each((p0, p1) {
      startMap[p0] = builder.call(p0, true);
      endMap[p0] = builder.call(p0, true);
    });
    newList.each((p0, p1) {
      startMap[p0] = builder.call(p0, false);
      endMap[p0] = builder.call(p0, false);
    });
    final List<N> nodeList = [...oldList, ...newList];

    if (attrs == null || !attrs.check(LayoutType.update, oldList.length + newList.length)) {
      for (var n in nodeList) {
        Attrs s = startMap[n] as Attrs;
        Attrs e = endMap[n] as Attrs;
        callback.call(n, lerpFun.call(s, e, 1));
      }
      endCall.call();
      return [];
    }

    var updateAnimate = Animate(0.0, 1.0, option: attrs);
    updateAnimate.addEndListener(() {
      endCall.call();
    });
    updateAnimate.addListener((t) {
      for (var n in nodeList) {
        var s = startMap[n] as Attrs;
        var e = endMap[n] as Attrs;
        callback.call(n, lerpFun(s, e, t));
      }
      endCall.call();
    });
    return [AnimationNode(updateAnimate, attrs, LayoutType.update)];
  }
}

enum DiffType {
  add,
  remove,
  update,
}

class DiffResult<N> {
  final Set<N> removeSet;
  final Set<N> addSet;
  final Set<N> oldUpdateSet;
  final Set<N> newUpdateSet;

  DiffResult(
    this.addSet,
    this.removeSet,
    this.oldUpdateSet,
    this.newUpdateSet,
  );

  String countInfo() {
    return "[add:${addSet.length},update:${newUpdateSet.length},remove:${removeSet.length},all:${addSet.length + newUpdateSet.length}] ";
  }
}

class TweenWrap {
  final Animate tween;
  final DiffType type;

  TweenWrap(this.tween, this.type);
}
