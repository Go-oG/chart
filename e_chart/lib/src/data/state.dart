import 'package:flutter/rendering.dart';

enum NodeState {
  disabled,
  selected,
  hover,
  focused,
  activated,
  pressed,
  dragged;
}

enum ViewVisibility {
  visible,
  invisible,
  gone;

  bool get isGone {
    return this == ViewVisibility.gone;
  }

  bool get isVisible {
    return this == ViewVisibility.visible;
  }

  bool get isInVisible {
    return this == ViewVisibility.invisible;
  }

  bool get isShow {
    return this == ViewVisibility.visible;
  }

  bool get isHide {
    return !isShow;
  }

  bool get needSize {
    return this == ViewVisibility.invisible;
  }
}

///状态管理
mixin StateMix {
  late Set<NodeState> _stateSet = {};

  bool get isEnabled => !_stateSet.contains(NodeState.disabled);

  bool get isDisabled => _stateSet.contains(NodeState.disabled);

  bool get isHover => _stateSet.contains(NodeState.hover);

  bool get isFocused => _stateSet.contains(NodeState.focused);

  bool get isActivated => _stateSet.contains(NodeState.activated);

  bool get isPressed => _stateSet.contains(NodeState.pressed);

  bool get isDragged => _stateSet.contains(NodeState.dragged);

  bool get isSelected => _stateSet.contains(NodeState.selected);

  bool _changed = false;

  bool get changed {
    var r = _changed;
    _changed = false;
    return r;
  }

  bool addState(NodeState s) {
    return _changed = _stateSet.add(s);
  }

  bool addStates(Iterable<NodeState> states) {
    if (states.isEmpty) {
      return false;
    }
    if (_stateSet.isEmpty) {
      _stateSet.addAll(states);
      return true;
    }
    bool result = false;
    for (var s in states) {
      if (addState(s)) {
        result = true;
      }
    }
    return _changed = result;
  }

  bool removeState(NodeState s) {
    if (_stateSet.isEmpty) {
      return false;
    }
    return _changed = _stateSet.remove(s);
  }

  bool removeStates(Iterable<NodeState> states) {
    if (_stateSet.isEmpty) {
      return false;
    }
    bool result = false;
    for (var s in states) {
      if (removeState(s)) {
        result = true;
      }
    }
    return _changed = result;
  }

  bool cleanState() {
    if (_stateSet.isEmpty) {
      return _changed = false;
    }
    _stateSet = {};
    return _changed = true;
  }

  Set<NodeState> get status => _stateSet;
}

abstract class StateResolver<T> {
  T? resolve(Set<NodeState>? states);
}

class ColorResolver extends StateResolver<Color> {
  Color overlay;

  ColorResolver(this.overlay);

  @override
  Color? resolve(Set<NodeState>? states) {
    states ??= {};
    if (states.isEmpty) {
      return overlay;
    }

    if (states.contains(NodeState.disabled)) {
      HSVColor hsv = HSVColor.fromColor(overlay);
      return hsv.withSaturation(0).withValue(0.5).toColor();
    }

    if (states.contains(NodeState.hover)) {
      HSVColor hsv = HSVColor.fromColor(overlay);
      double v = hsv.value;
      v += 0.16;
      if (v > 1) {
        v = 1;
      }
      return hsv.withValue(v).toColor();
    }

    if (states.contains(NodeState.focused) || states.contains(NodeState.pressed)) {
      HSVColor hsv = HSVColor.fromColor(overlay);
      double v = hsv.value;
      v += 0.24;
      if (v > 1) {
        v = 1;
      }
      return hsv.withValue(v).toColor();
    }

    if (states.contains(NodeState.dragged)) {
      HSVColor hsv = HSVColor.fromColor(overlay);
      return hsv.withValue(0.16).toColor();
    }

    return overlay;
  }
}
