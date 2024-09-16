import 'event.dart';

interface class DownSamplingAlgorithm {
  List<Event> process(List<Event> data, int threshold) {
    throw Error();
  }
}
