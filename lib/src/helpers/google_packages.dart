import 'package:http/http.dart' as http;

import '../models/search_results_model.dart';
import '../pub_api_client_base.dart';

/// List of Google publishers on pub.dev
const _publishers = [
  'flutter.dev',
  'dart.dev',
  'material.io',
  'firebase.google.com',
  'google.dev',
  'tools.dart.dev ',
];

/// Retrieves all Google packages from pub.dev
/// Mostly used as an internal tool to generate
/// google_packages_list.dart
/// You should probably use that instead
Future<List<String>> getGooglePackages() async {
  final futures = <Future<List<PackageResult>>>[];
  for (var publisher in _publishers) {
    futures.add(getPublisherPackages(publisher));
  }
  final results = await Future.wait(futures);
  final flatResults = results.expand((r) => r).toList();
  return flatResults.map((r) => r.package).toList();
}

Future<List<PackageResult>> fetchGooglePackages() async {
  final packages = await http.get(Uri(
    host:
        'https://github.com/leoafarias/pub_api_client/blob/main/static/google_deps.json?raw=true',
  ));
}

Future<List<PackageResult>> getPublisherPackages(String publisherName) async {
  final results = await PubClient().search('', publisher: publisherName);
  return _recursivePaging(results);
}

Future<List<PackageResult>> _recursivePaging(SearchResults prevResults) async {
  final packages = prevResults.packages;
  if (prevResults.next != null) {
    // TODO: Check why linting not working for nullable and remove ?? ''
    final results = await PubClient().nextPage(prevResults.next ?? '');
    final nextResults = await _recursivePaging(results);
    packages.addAll(nextResults);
  }

  return packages;
}
