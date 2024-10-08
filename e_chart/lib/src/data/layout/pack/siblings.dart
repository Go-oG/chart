import 'dart:core';
import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';

import 'enclose.dart';

class Siblings {
  static List<TreeNode> siblings(List<TreeNode> circles) {
    packSiblingsRandom(circles, DefaultLCG());
    return circles;
  }

  static void _place(TreeNode b, TreeNode a, TreeNode c) {
    num dx = b.x - a.x, x, a2, dy = b.y - a.y, y, b2, d2 = dx * dx + dy * dy;
    if (d2 != 0) {
      a2 = a.r + c.r;
      a2 *= a2;
      b2 = b.r + c.r;
      b2 *= b2;
      if (a2 > b2) {
        x = (d2 + b2 - a2) / (2 * d2);
        y = m.sqrt(m.max(0, b2 / d2 - x * x));
        c.x = b.x - x * dx - y * dy;
        c.y = b.y - x * dy + y * dx;
      } else {
        x = (d2 + a2 - b2) / (2 * d2);
        y = m.sqrt(m.max(0, a2 / d2 - x * x));
        c.x = a.x + x * dx - y * dy;
        c.y = a.y + x * dy + y * dx;
      }
    } else {
      c.x = a.x + c.r;
      c.y = a.y;
    }
  }

  static bool _intersects(TreeNode a, TreeNode b) {
    var dr = a.r + b.r - 1e-6, dx = b.x - a.x, dy = b.y - a.y;
    return dr > 0 && dr * dr > dx * dx + dy * dy;
  }

  static num _score(_InnerNode node) {
    var a = node.node;
    var b = node.next!.node;
    num ab = a.r + b.r, dx = (a.x * b.r + b.x * a.r) / ab, dy = (a.y * b.r + b.y * a.r) / ab;
    return dx * dx + dy * dy;
  }

  static num packSiblingsRandom(List<TreeNode> circles, LCG random) {
    int n = circles.length;
    if (n == 0) return 0;

    TreeNode? an, bn, cn;

    var aa, ca, sj, sk;

    // Place the first circle.
    an = circles[0];
    an.x = 0;
    an.y = 0;
    if (n <= 1) return an.r;

    // Place the second circle.
    bn = circles[1];
    an.x = -bn.r;
    bn.x = an.r;
    bn.y = 0;
    if (n <= 2) return an.r + bn.r;

    // Place the third circle.
    _place(bn, an, cn = circles[2]);

    _InnerNode? a, b, c, j, k;

    // Initialize the front-chain using the first three circles a, b and c.
    a = _InnerNode(an);
    b = _InnerNode(bn);
    c = _InnerNode(cn);
    a.next = c.previous = b;
    b.next = a.previous = c;
    c.next = b.previous = a;

    // Attempt to place each remaining circle…
    pack:
    for (int i = 3; i < n; ++i) {
      _place(a!.node, b!.node, cn = circles[i]);
      c = _InnerNode(cn);
      j = b.next;
      k = a.previous;
      sj = b.node.r;
      sk = a.node.r;
      do {
        if (sj <= sk) {
          if (_intersects(j!.node, c.node)) {
            b = j;
            a!.next = b;
            b.previous = a;
            --i;
            continue pack;
          }
          sj += j.node.r;
          j = j.next;
        } else {
          if (_intersects(k!.node, c.node)) {
            a = k;
            a.next = b;
            b!.previous = a;
            --i;
            continue pack;
          }
          sk += k.node.r;
          k = k.previous;
        }
      } while (j != k?.next);

      // Success! Insert the new circle c between a and b.
      c.previous = a;
      c.next = b;
      a!.next = b!.previous = b = c;

      // Compute the new closest circle pair to the centroid.
      aa = _score(a);
      while ((c = c?.next) != b) {
        if ((ca = _score(c!)) < aa) {
          a = c;
          aa = ca;
        }
      }
      b = a!.next;
    }

    // Compute the enclosing circle of the front chain.
    List<TreeNode> cl = [b!.node];
    c = b;
    while ((c = c?.next) != b) {
      cl.add(c!.node);
    }

    var cr = packEncloseRandom(cl, random);
    // Translate the circles to put the enclosing circle around the origin.
    for (int i = 0; i < n; ++i) {
      an = circles[i];
      an.x -= cr.x;
      an.y -= cr.y;
    }
    return cr.r;
  }
}

class _InnerNode {
  TreeNode node;
  _InnerNode? next;
  _InnerNode? previous;

  _InnerNode(this.node);
}
