import 'dart:convert';

import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/config.dart';
import 'core/weather_service.dart';

void main() => runApp(const TestApp());

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherTestPage(),
    );
  }
}

class WeatherTestPage extends StatefulWidget {
  const WeatherTestPage({super.key});

  @override
  State<WeatherTestPage> createState() => _WeatherTestPageState();
}

class _WeatherTestPageState extends State<WeatherTestPage> {
  final _service = WeatherService();
  String _hasil = 'Tekan tombol untuk mengetes koneksi ke Docker.';
  bool _loading = false;

  Future<void> _ambil() async {
    setState(() {
      _loading = true;
      _hasil = 'Memuat...';
    });
    try {
      final data = await _service.fetchWeather(-7.25, 112.75);
      final pretty = const JsonEncoder.withIndent('  ').convert(data);
      setState(() => _hasil = 'BERHASIL\n\n$pretty');
    } on ApiException catch (e) {
      setState(() => _hasil = 'GAGAL: ${e.detail}\n(status: ${e.statusCode})');
    } catch (e) {
      setState(() => _hasil = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Koneksi Docker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Server: ${AppConfig.baseUrl}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _ambil,
              child: const Text('Ambil Cuaca'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(child: SelectableText(_hasil)),
            ),
          ],
        ),
      ),
    );
  }
}