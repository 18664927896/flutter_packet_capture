import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_packet_capture/flutter_packet_capture.dart';

void main() {
  test('adds one to input values', () {
    Packetcapture.setConfig();
    expect(Packetcapture.setConfig(), 3);
    expect(Packetcapture.setConfig(), -6);
    expect(Packetcapture.setConfig(), 1);
    expect(() => Packetcapture.setConfig(), throwsNoSuchMethodError);
  });
}
