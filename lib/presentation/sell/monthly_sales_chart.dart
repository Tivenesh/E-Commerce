import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../data/models/order_item.dart'; // Corrected path
import '../../data/services/order_item_repo.dart'; // Corrected path

class MonthlySalesChart extends StatefulWidget {
  final String sellerId; // Assuming you want to filter by sellerId
  const MonthlySalesChart({super.key, required this.sellerId});

  @override
  State<MonthlySalesChart> createState() => _MonthlySalesChartState();
}

class _MonthlySalesChartState extends State<MonthlySalesChart> {
  @override
  Widget build(BuildContext context) {
    // Access the OrderItemRepo using Provider
    final orderItemRepo = Provider.of<OrderItemRepo>(context);

    return StreamBuilder<List<OrderItem>>(
      stream: orderItemRepo.getOrdersBySeller(
        widget.sellerId,
      ), // Fetch orders for the specific seller
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

        // Process the data to aggregate sales by month
        Map<String, double> monthlySales = {};
        for (var order in snapshot.data!) {
          // Only consider delivered or confirmed orders for sales
          if (order.status == OrderStatus.delivered ||
              order.status == OrderStatus.confirmed) {
            DateTime orderDateTime = order.orderDate.toDate();
            // Use 'MMM yyyy' for month-year format
            String monthYear = DateFormat(
              'MMM yyyy',
            ).format(orderDateTime); // e.g., "Jan 2023"
            monthlySales.update(
              monthYear,
              (value) => value + order.totalAmount,
              ifAbsent: () => order.totalAmount,
            );
          }
        }

        // Sort months chronologically for proper chart display
        List<String> sortedMonths =
            monthlySales.keys.toList()..sort((a, b) {
              // Parse using 'MMM yyyy'
              DateTime dateA = DateFormat('MMM yyyy').parse(a);
              DateTime dateB = DateFormat('MMM yyyy').parse(b);
              return dateA.compareTo(dateB);
            });

        List<BarChartGroupData> barGroups = [];
        List<String> bottomTitles = [];

        double maxY = 0;
        for (int i = 0; i < sortedMonths.length; i++) {
          String month = sortedMonths[i];
          double salesAmount = monthlySales[month] ?? 0.0;
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: salesAmount,
                  color: Colors.blueAccent,
                  width: 16,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          );
          // Use 'MMM' for bottom titles (e.g., "Jan", "Feb")
          bottomTitles.add(
            DateFormat('MMM').format(DateFormat('MMM yyyy').parse(month)),
          );
          if (salesAmount > maxY) {
            maxY = salesAmount;
          }
        }

        // Add some padding to maxY for better chart visualization
        maxY = maxY * 1.2;
        if (maxY < 100) maxY = 100; // Ensure a minimum Y-axis height

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
                  'Monthly Sales Overview',
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
                                '\$${value.toInt()}',
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
                        touchTooltipData: BarTouchTooltipData(
                          // tooltipBgColor: Colors.blueGrey,  // Customizing the tooltip background color
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String month = sortedMonths[group.x.toInt()];
                            return BarTooltipItem(
                              '${month}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '\$${rod.toY.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
