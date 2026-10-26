import 'dart:convert';
import 'dart:io';
import 'package:smart_panel_bmt/data/mock/mock_repositories.dart';
import 'package:smart_panel_bmt/domain/models.dart';

MockHomeStore createStore() {
  final j =
      jsonDecode(File('assets/mock/profiles.json').readAsStringSync())
          as Map<String, dynamic>;
  return MockHomeStore(
    (j['profiles'] as List)
        .map((p) => HomeProfile.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}
