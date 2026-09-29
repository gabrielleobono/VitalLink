import 'dart:io';

import 'prescription_scan.dart';

abstract class PrescriptionScanner {
  Future<PrescriptionScan> scan(File imageFile);
}
