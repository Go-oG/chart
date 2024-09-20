import 'package:flutter/material.dart';

import '../notifier.dart';

class ValueListenableBuilder2<T> extends StatefulWidget {
  const ValueListenableBuilder2({
    super.key,
    required this.valueListenable,
    required this.builder,
    this.child,
  });

  final ValueNotifier2<T> valueListenable;
  final ValueWidgetBuilder<T> builder;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ValueListenableBuilderState2<T>();
}

class _ValueListenableBuilderState2<T> extends State<ValueListenableBuilder2<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ValueListenableBuilder2<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    super.dispose();
  }

  void _valueChanged(T v) {
    setState(() {
      value = widget.valueListenable.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}
