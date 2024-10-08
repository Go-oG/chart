
enum SelectedMode { single, group }

///触发类型
enum Trigger {
  ///什么都不触发
  none,

  ///坐标轴触发，主要在柱状图，折线图等会使用类目轴的图表中使用
  axis,

  ///数据项图形触发，主要在散点图，饼图等无类目轴的图表中使用
  item,
}

enum TriggerOn {
  mouseMove,
  click,
  moveAndClick,
  none,
}
