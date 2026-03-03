import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:tools/tools.dart';

Future<void> runApiStressTester() async {
  printSection('🛡️ API Stress Tester (Elite Load)');

  final url = ask('Enter Target API URL (e.g., https://api.example.com/data)');
  if (url == null) return;

  final method =
      selectOption('Select HTTP Method', [
        'GET',
        'POST',
        'PUT',
        'DELETE',
      ], showBack: false) ??
      '1';
  final String methodStr = [
    'GET',
    'POST',
    'PUT',
    'DELETE',
  ][int.parse(method) - 1];

  final requestCountInput =
      ask('Number of total requests (default: 50)') ?? '50';
  final concurrencyInput =
      ask('Concurrency level (simultaneous requests, default: 5)') ?? '5';

  final int totalRequests = int.tryParse(requestCountInput) ?? 50;
  final int concurrency = int.tryParse(concurrencyInput) ?? 5;

  String? payload;
  if (methodStr != 'GET') {
    payload = ask('Enter JSON Payload (leave empty for none)');
  }

  final headersInput = ask(
    'Enter Headers JSON (e.g. {"Authorization": "Bearer ..."}, leave empty for none)',
  );
  Map<String, String>? headers;
  if (headersInput != null) {
    try {
      headers = Map<String, String>.from(json.decode(headersInput));
    } catch (e) {
      printError('Invalid headers JSON. Proceeding without custom headers.');
    }
  }

  printInfo('Starting stress test: $methodStr $url');
  printInfo(
    'Configuration: $totalRequests total requests, $concurrency concurrent.',
  );

  final List<double> latencies = [];
  int successCount = 0;
  int failureCount = 0;

  final stopwatch = Stopwatch()..start();

  await loadingSpinner('Running load test', () async {
    final List<Future<void>> workers = [];
    int remaining = totalRequests;

    Future<void> worker() async {
      while (remaining > 0) {
        remaining--;
        final requestStopwatch = Stopwatch()..start();
        try {
          http.Response response;
          final uri = Uri.parse(url);

          switch (methodStr) {
            case 'POST':
              response = await http.post(uri, headers: headers, body: payload);
              break;
            case 'PUT':
              response = await http.put(uri, headers: headers, body: payload);
              break;
            case 'DELETE':
              response = await http.delete(
                uri,
                headers: headers,
                body: payload,
              );
              break;
            default:
              response = await http.get(uri, headers: headers);
          }

          requestStopwatch.stop();
          latencies.add(requestStopwatch.elapsedMilliseconds.toDouble());

          if (response.statusCode >= 200 && response.statusCode < 300) {
            successCount++;
          } else {
            failureCount++;
          }
        } catch (e) {
          requestStopwatch.stop();
          failureCount++;
        }
      }
    }

    for (int i = 0; i < concurrency; i++) {
      workers.add(worker());
    }

    await Future.wait(workers);
  });

  stopwatch.stop();
  final totalTime = stopwatch.elapsedMilliseconds;

  if (latencies.isEmpty) {
    printError('No requests were completed.');
    return;
  }

  latencies.sort();
  final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
  final minLatency = latencies.first;
  final maxLatency = latencies.last;
  final p95Latency = latencies[(latencies.length * 0.95).floor()];

  print('\n$blue$bold📊 STRESS TEST RESULTS$reset');
  printTable(
    ['Metric', 'Value'],
    [
      ['Target URL', url],
      ['Method', methodStr],
      ['Total Time', '${(totalTime / 1000).toStringAsFixed(2)}s'],
      ['Total Requests', totalRequests.toString()],
      [
        'Success Rate',
        '${((successCount / totalRequests) * 100).toStringAsFixed(1)}% ($successCount)',
      ],
      [
        'Failure Rate',
        '${((failureCount / totalRequests) * 100).toStringAsFixed(1)}% ($failureCount)',
      ],
      ['Avg Latency', '${avgLatency.toStringAsFixed(0)}ms'],
      ['Min Latency', '${minLatency.toStringAsFixed(0)}ms'],
      ['Max Latency', '${maxLatency.toStringAsFixed(0)}ms'],
      ['95th Percentile', '${p95Latency.toStringAsFixed(0)}ms'],
      ['Req/Second', (totalRequests / (totalTime / 1000)).toStringAsFixed(2)],
    ],
  );

  printSuccess('Stress test complete!');
  ask('Press Enter to return');
}
