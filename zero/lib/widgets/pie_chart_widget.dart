// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categoryStats;
  final double size;

  const PieChartWidget({
    super.key,
    required this.categoryStats,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryStats.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: const Center(
          child: Text(
            'Нет данных',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: PieChart(
        PieChartData(
          sections: _buildSections(),
          centerSpaceRadius: size * 0.3,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return categoryStats.map((stat) {
      final value = stat['total'].toDouble();
      final color = stat['color'] as Color;
      final category = stat['category'] as String;
      final total = stat['total'] as int;
      final percentage = (value / _getTotal() * 100).round();

      return PieChartSectionData(
        value: value,
        color: color,
        title: '$percentage%',
        radius: size * 0.4,
        titleStyle: TextStyle(
          fontSize: size * 0.07,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Text(
            total.toString(),
            style: TextStyle(
              fontSize: size * 0.05,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  double _getTotal() {
    return categoryStats
        .map((stat) => stat['total'] as int)
        .fold(0, (a, b) => a + b)
        .toDouble();
  }
}
