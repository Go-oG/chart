interface class Event {
  int getTime() {
    throw Error();
  }

  double getValue() {
    throw Error();
  }
}
