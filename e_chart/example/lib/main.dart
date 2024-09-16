import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chart Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ChartOption option;

  @override
  void initState() {
    super.initState();
    option = _funnel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Chart"),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Chart(option),
      ),
    );
  }

  ChartOption _pie() {
    PieGeom geom = PieGeom([]);
    for (var i = 0; i < 10; i++) {
      geom.dataSet.add(RawData.fromValue(5));
    }
    geom.addPos(const PosMap("value", 0, Dim.x));
    return ChartOption(geoms: [geom]);
  }

  ChartOption _funnel() {
    var grid = Grid();
    // grid.xAxisList.first.type = AxisType.category;
    // grid.yAxisList.first.type = AxisType.value;
    IntervalGeom geom = IntervalGeom([], grid.id);
    // geom.addTransform(StackX());

    var option = ChartOption(geoms: [geom], gridList: [grid]);
    for (int i = 1; i <= 5; i++) {
      var data = RawData(id: "[$i]");
      data.put("x", 'X->$i');
      data.put("y", i * 20);
      // data.put("stackId", '1');
      geom.dataSet.add(data);
    }
    geom.addPos(const PosMap("x", 0, Dim.x));
    geom.addPos(const PosMap("y", 0, Dim.y));
    return option;
  }
}
