import 'dart:core';

import 'package:e_chart/e_chart.dart';
import 'package:statistics/statistics.dart';

///统计处理(所有的操作方法都是针对数值操作)
class AggregateTransform extends BaseDataTransform {
  //<rawField,Method,asField>
  List<FixPair2<String, AggregateMethod, String>> fields;
  List<String> groupBy;

  AggregateTransform(
    this.fields, [
    this.groupBy = const [],
  ]);

  @override
  List<RawData> transform(List<RawData> input) {
    var gd = groupData(input, groupBy);
    for (var entry in gd.first.entries) {
      _aggregateGroup(entry.value);
    }

    List<RawData> resultList = [];
    for (var key in gd.second) {
      resultList.addAll(gd.first[key]!);
    }

    return resultList;
  }

  void _aggregateGroup(List<RawData> input) {
    ///存储每个数据对应字段的值
    ///<asField,<id,num>>
    Map<String, Map<String, num>> numMap = {};
    Map<String, RawData> dataMap = {};
    for (var item in input) {
      dataMap[item.id] = item;

      fields.each((field, p1) {
        var childMap = numMap.get2(field.third, {});
        var v = item.get2(field.first);
        if (v is num) {
          childMap[item.id] = v;
        }
      });
    }

    Map<String, Statistics<num>> staticsMap = {};
    Map<String, num> productMap = {};

    ///方差
    Map<String, num> varianceMap = {};

    ///样本方差
    Map<String, num> sdMap = {};

    for (var item in input) {
      fields.each((asField, index) {
        var operation = asField.second;
        var rawList = numMap.get2(asField.third, {}).values;
        if (operation == AggregateMethod.count) {
          item[asField.third] = rawList.length;
          return;
        }
        if (rawList.isEmpty) {
          item[asField.third] = null;
          return;
        }

        var statistics = staticsMap.get2(asField.third, rawList.statistics);

        if (operation == AggregateMethod.center) {
          item[asField.third] = statistics.center;
          return;
        }
        if (operation == AggregateMethod.min) {
          item[asField.third] = statistics.min;
          return;
        }
        if (operation == AggregateMethod.max) {
          item[asField.third] = statistics.max;
          return;
        }
        if (operation == AggregateMethod.sum) {
          item[asField.third] = statistics.sum;
          return;
        }
        if (operation == AggregateMethod.mean) {
          item[asField.third] = statistics.mean;
          return;
        }
        if (operation == AggregateMethod.median) {
          item[asField.third] = statistics.median;
          return;
        }
        if (operation == AggregateMethod.product) {
          var product = productMap.get2(asField.third, rawList.reduce((value, ele) {
            return value * ele;
          }));
          item[asField.third] = product;
          return;
        }
        if (operation == AggregateMethod.standardDeviation) {
          item[asField.third] = statistics.standardDeviation;
          return;
        }
        if (operation == AggregateMethod.variance) {
          var rawSum = statistics.sum;
          var value = varianceMap.get3(asField.third, () {
            return reduce(rawList, (p0, p1) {
                  var v2 = (p1 - rawSum).abs();
                  return p0 + v2 * v2;
                }) /
                rawList.length;
          });
          item[asField.third] = value;
          return;
        }
        if (operation == AggregateMethod.sampleVariance) {
          //样本方差
          var rawSum = statistics.sum;
          var value = sdMap.get3(asField.third, () {
            if (rawList.length - 1 <= 0) {
              return 0;
            }
            num v = reduce(rawList, (p0, p1) {
              var v2 = (p1 - rawSum).abs();
              return p0 + v2 * v2;
            });
            v /= (rawList.length - 1);
            return v;
          });
          item[asField.third] = value;
        }
      });
    }
  }
}

enum AggregateMethod {
  count,
  max,
  min,
  sum,
  mean,
  median,
  mode,
  product,
  standardDeviation,
  variance,
  center,
  sampleVariance;
}
