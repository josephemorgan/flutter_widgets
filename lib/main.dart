import 'package:flutter/material.dart';
import 'package:flutter_widgets/circle_chart/circle_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Widget Tester'),
        ),
        body: const CircleChartPage(title: 'Widget Tester'),
      ),
    );
  }
}

class CircleChartPage extends StatelessWidget {
  const CircleChartPage({super.key, required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircleChart(
        config: CircleChartConfig(),
      ),
    );
  }
}
