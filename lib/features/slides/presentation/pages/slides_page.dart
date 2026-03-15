import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SlidesPage extends StatelessWidget {
  const SlidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('Q1', 35, Colors.blue),
      ChartData('Q2', 28, Colors.green),
      ChartData('Q3', 34, Colors.orange),
      ChartData('Q4', 32, Colors.red),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NextOffice Slides'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        color: const Color(0xFF1E293B), // Dark slide background
        child: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Card(
              color: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Quarterly Performance Analysis',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        title: ChartTitle(text: 'Sales Growth 2026'),
                        legend: Legend(isVisible: true),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <CartesianSeries<ChartData, String>>[
                          ColumnSeries<ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            pointColorMapper: (ChartData data, _) => data.color,
                            name: 'Sales',
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        child: const Icon(Icons.play_arrow, color: Colors.white),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
