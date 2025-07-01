import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../data/models/order_item.dart'; // Assuming this path is correct
import '../../data/services/order_item_repo.dart'; // Assuming this path is correct

class MonthlySalesChart extends StatefulWidget {
  final String sellerId;
  const MonthlySalesChart({super.key, required this.sellerId});

  @override
  State<MonthlySalesChart> createState() => _MonthlySalesChartState();
}

class _MonthlySalesChartState extends State<MonthlySalesChart> {
  // Map to store unique item names and their assigned colors
  final Map<String, Color> _itemColorMap = {};
  int _colorIndex = 0;
  final List<Color> _chartColors = [
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.deepOrangeAccent,
    Colors.indigoAccent,
  ];

  Color _getItemColor(String itemName) {
    if (!_itemColorMap.containsKey(itemName)) {
      _itemColorMap[itemName] = _chartColors[_colorIndex % _chartColors.length];
      _colorIndex++;
    }
    return _itemColorMap[itemName]!;
  }

  @override
  Widget build(BuildContext context) {
    final orderItemRepo = Provider.of<OrderItemRepo>(context);

    return StreamBuilder<List<OrderItem>>(
      stream: orderItemRepo.getOrdersBySeller(widget.sellerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No sales data available.'));
        }

        // Process data to aggregate sales by month and item type
        // Map: MonthYear -> ItemName -> TotalSales
        Map<String, Map<String, double>> monthlySalesByItem = {};
        for (var order in snapshot.data!) {
          if (order.status == OrderStatus.delivered ||
              order.status == OrderStatus.confirmed) {
            DateTime orderDateTime = order.orderDate.toDate();
            String monthYear = DateFormat('MMMyyyy').format(orderDateTime);

            for (var cartItem in order.items) {
              final String itemName = cartItem.itemName;
              final double itemTotal = cartItem.quantity * cartItem.itemPrice;

              monthlySalesByItem.update(monthYear, (monthMap) {
                monthMap.update(
                  itemName,
                  (value) => value + itemTotal,
                  ifAbsent: () => itemTotal,
                );
                return monthMap;
              }, ifAbsent: () => {itemName: itemTotal});
            }
          }
        }

        List<String> sortedMonths =
            monthlySalesByItem.keys.toList()..sort((a, b) {
              DateTime dateA = DateFormat('MMMyyyy').parse(a);
              DateTime dateB = DateFormat('MMMyyyy').parse(b);
              return dateA.compareTo(dateB);
            });

        List<BarChartGroupData> barGroups = [];
        List<String> bottomTitles = [];
        double maxY = 0;

        for (int i = 0; i < sortedMonths.length; i++) {
          String month = sortedMonths[i];
          Map<String, double> salesForMonth = monthlySalesByItem[month] ?? {};

          List<BarChartRodStackItem> rodStackItems = [];
          double stackValue = 0;
          double monthTotalSales = 0;

          // Sort items for consistent stacking order (optional, but good practice)
          List<String> sortedItems = salesForMonth.keys.toList()..sort();

          for (var itemName in sortedItems) {
            double salesAmount = salesForMonth[itemName] ?? 0.0;
            if (salesAmount > 0) {
              rodStackItems.add(
                BarChartRodStackItem(
                  stackValue,
                  stackValue + salesAmount,
                  _getItemColor(itemName),
                ),
              );
              stackValue += salesAmount;
            }
          }
          monthTotalSales = stackValue; // The total height of the stacked bar

          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: monthTotalSales,
                  width: 20, // Increased width for better visibility
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  rodStackItems: rodStackItems,
                ),
              ],
            ),
          );
          bottomTitles.add(
            DateFormat('MMM').format(DateFormat('MMMyyyy').parse(month)),
          );
          if (monthTotalSales > maxY) {
            maxY = monthTotalSales;
          }
        }

        maxY = maxY * 1.2;
        if (maxY < 100) maxY = 100;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Monthly Sales by Item Type',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barGroups: barGroups,
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: const Color(0xff37434d),
                          width: 1,
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < bottomTitles.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8.0,
                                  child: Text(
                                    bottomTitles[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 40,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                'RM${value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      alignment: BarChartAlignment.spaceAround,
                      groupsSpace: 12,
                      barTouchData: BarTouchData(
                        // This property provides the tooltip data
                        touchTooltipData: BarTouchTooltipData(
                          // tooltipBgColor: Colors.blueGrey, // Customize tooltip background
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String month = sortedMonths[group.x.toInt()];
                            Map<String, double> salesForMonth =
                                monthlySalesByItem[month] ?? {};
                            List<TextSpan> children = [];
                            double totalMonthSales = 0;

                            // Sort items for consistent display in tooltip
                            List<String> sortedTooltipItems =
                                salesForMonth.keys.toList()..sort();

                            for (var itemName in sortedTooltipItems) {
                              double sales = salesForMonth[itemName] ?? 0.0;
                              totalMonthSales += sales;
                              children.add(
                                TextSpan(
                                  text:
                                      '${itemName}: RM${sales.toStringAsFixed(2)}\n',
                                  style: TextStyle(
                                    color: _getItemColor(itemName),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }

                            return BarTooltipItem(
                              // Display month and total sales at the top of the tooltip
                              '${month}\nTotal: RM${totalMonthSales.toStringAsFixed(2)}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children:
                                  children, // Add individual item sales as children
                            );
                          },
                        ),
                        // To make the tooltip appear only on touch (and not hover/initial render),
                        // we control which bars show tooltips by setting the 'showingTooltipIndicators'
                        // on the BarChartGroupData only when a bar is touched.
                        // However, a simpler way for pure "on-tap" is to let getTooltipItem handle it,
                        // and for "hover", it will automatically appear. If you strictly only want
                        // on-tap, the previous approach with the custom Card was more explicit.
                        // For a clean solution with getTooltipItem, the tooltip will appear on tap
                        // and also on hover (if using mouse/desktop).
                        // If strict "only on tap, then disappear when tapping elsewhere" is needed,
                        // the previous custom card approach with state management is better.
                        // For the current structure with `getTooltipItem`, it functions more like a typical tooltip.
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Legend
                Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  alignment: WrapAlignment.center,
                  children:
                      _itemColorMap.entries.map((entry) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: entry.value,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
