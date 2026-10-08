// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;
  final double height;

  const BarChartWidget({
    Key? key,
    required this.weeklyData,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          barGroups: _buildBarGroups(),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < weeklyData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        weeklyData[index]['day'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(weeklyData.length, (index) {
      final data = weeklyData[index];
      final completed = data['completed'] as int;
      final total = data['total'] as int;
      final completionRate = data['completionRate'] as int;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total.toDouble(),
            color: Colors.grey[300],
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: completed.toDouble(),
            color: _getBarColor(completionRate),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Color _getBarColor(int completionRate) {
    if (completionRate >= 80) return Colors.green;
    if (completionRate >= 50) return Colors.orange;
    return Colors.red;
  }
}
