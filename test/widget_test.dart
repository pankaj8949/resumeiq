import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumeiq/main.dart';

void main() {
  test('ResumeIQApp class exists and can be instantiated', () {
    // Verify that ResumeIQApp exists and can be created
    // This fixes the original error: "The name 'MyApp' isn't a class"
    const app = ResumeIQApp();
    expect(app, isA<StatelessWidget>());
  });
}
