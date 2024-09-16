import '../event.dart';

interface class Bucket {
  void selectInto(List<Event> result) {
    throw Error();
  }

  void add(Event e) {
    throw Error();
  }
}
