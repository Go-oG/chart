import 'dart:ui';

import '../model/text.dart';

extension DParagraphExt on Paragraph {
  DynamicText toText() {
    return DynamicText(this);
  }
}
