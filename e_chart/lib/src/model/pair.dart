class Pair<F, S> {
  F first;
  S second;

  Pair(this.first, this.second);
}

class FixPair<F, S> {
  final F first;
  final S second;

  const FixPair(this.first, this.second);
}

class FixPair2<F, S, T> {
  final F first;
  final S second;
  final T third;

  const FixPair2(this.first, this.second, this.third);
}
