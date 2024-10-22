class LinkedYList {
  late int index;
  late double y;
  LinkedYList? next;

  LinkedYList(this.index, this.y, this.next);

  double get bottom => y;

  LinkedYList update(int index, double y) {
    var node = this;
    while (node.y <= y) {
      var next = this.next;
      if (next != null) {
        node = next;
      } else {
        return LinkedYList(index, y, null);
      }
    }
    return LinkedYList(index, y, node);
  }

  LinkedYList? pop() {
    var old = next;
    next = null;
    return old;
  }
}
