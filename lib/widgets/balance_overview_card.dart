import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class BalanceOverviewCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final double goalAmount;
  final List<FlSpot> balanceSpots;
  final String currency;
  final String userName;

  const BalanceOverviewCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.goalAmount,
    required this.balanceSpots,
    required this.currency,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savings = totalIncome - totalExpenses;
    final progress = (savings / goalAmount).clamp(0.0, 1.0);
    final insight = _generateInsight(totalIncome, totalExpenses, savings);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            "Good Morning, $userName 😍",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Balance Row
          Row(
            children: [
              const CircleAvatar(
                radius: 22,

              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$currency ${totalBalance.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Income / Expense / Savings Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Income', totalIncome, Colors.greenAccent),
              _buildStat('Expenses', totalExpenses, Colors.redAccent),
              _buildStat('Savings', savings, Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 16),

          // Sparkline chart
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: balanceSpots,
                    isCurved: true,
                    color: Colors.tealAccent,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.tealAccent.withOpacity(0.3),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar (Goal)
          Text(
            "Savings Goal Progress",
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade800,
              color: Colors.tealAccent,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),

          // Insight message
          Text(
            insight,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),

          // Details button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to details page
              },
              child: const Text(
                "View Details →",
                style: TextStyle(color: Colors.tealAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _generateInsight(double income, double expenses, double savings) {
    if (savings > 0) {
      return "You saved \$${savings.toStringAsFixed(0)} this week — nice work 💪";
    } else if (expenses > income) {
      return "You spent more than you earned 😬 try adjusting your budget.";
    } else {
      return "You're doing great — keep tracking your spending 👏";
    }
  }
}
