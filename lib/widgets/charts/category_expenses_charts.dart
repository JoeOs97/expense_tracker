import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryExpensesPieChart extends StatefulWidget {
  final Map<String, double> categoryExpenses;
  final Map<String, Color> categoryColors;

  const CategoryExpensesPieChart({
    super.key,
    required this.categoryExpenses,
    required this.categoryColors,
  });

  @override
  State<CategoryExpensesPieChart> createState() =>
      _CategoryExpensesPieChartState();
}

class _CategoryExpensesPieChartState extends State<CategoryExpensesPieChart> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final categories = widget.categoryExpenses.keys.toList();
    final values = widget.categoryExpenses.values.toList();
    final total = values.fold(0.0, (sum, item) => sum + item);

    final data = List.generate(
      categories.length,
          (i) => _CategoryData(
        name: categories[i],
        value: values[i],
        color: widget.categoryColors[categories[i]] ?? Colors.grey,
        percent: (values[i] / total) * 100,
      ),
    );

    return Column(
      children: [
        Container(
          height: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SfCircularChart(
                margin: EdgeInsets.zero,
                legend: const Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries<_CategoryData, String>>[
                  DoughnutSeries<_CategoryData, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.name,
                    yValueMapper: (d, _) => d.value,
                    pointColorMapper: (d, _) => d.color,
                    dataLabelMapper: (d, _) =>
                    "${d.percent.toStringAsFixed(1)}%",
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    radius: '90%',
                    innerRadius: '60%',
                    explode: true,
                    explodeGesture: ActivationMode.singleTap,
                    onPointTap: (pointInteractionDetails) {
                      setState(() {
                        final index = pointInteractionDetails.pointIndex!;
                        selectedCategory = data[index].name;
                      });
                    },
                  ),
                ],
              ),
              // ✅ Center Text — Shows “Expenses” or selected category
              Positioned.fill(
                child: Center(
                  child: Text(
                    selectedCategory != null
                        ? "$selectedCategory\n${data.firstWhere((d) => d.name == selectedCategory!).percent.toStringAsFixed(1)}%"
                        : "Expenses",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ✅ Custom Legend (like your old version)
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: data.map((d) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: d.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${d.name}: ${d.percent.toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategoryData {
  final String name;
  final double value;
  final Color color;
  final double percent;

  _CategoryData({
    required this.name,
    required this.value,
    required this.color,
    required this.percent,
  });
}
