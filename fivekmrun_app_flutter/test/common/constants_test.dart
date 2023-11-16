import 'package:fivekmrun_flutter/common/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('test common constants', () {
    test('validate DATE_FORMAT', () {
      expect(Constants.DATE_FORMAT, 'dd.MM.yyyy');
    });
  });
}
