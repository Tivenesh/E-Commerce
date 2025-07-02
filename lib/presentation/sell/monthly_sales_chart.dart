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
    Colors.cyan,
    Colors.amber,
    Colors.lightBlue,
    Colors.pink,
  ];

  String? _selectedMonthYear; // Stores 'MMMyyyy' e.g., 'Jul2024'
  List<String> _availableMonthYears = []; // All available 'MMMyyyy' strings

  Color _getItemColor(String itemName) {
    if (!_itemColorMap.containsKey(itemName)) {
      _itemColorMap[itemName] = _chartColors[_colorIndex % _chartColors.length];
      _colorIndex++;
    }
    return _itemColorMap[itemName]!;
  }

  // State variable to hold the index of the touched section for tooltip
  int touchedIndex = -1;

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

        // Sort months and update available months for dropdown
        List<String> sortedMonths =
            monthlySalesByItem.keys.toList()..sort((a, b) {
              DateTime dateA = DateFormat('MMMyyyy').parse(a);
              DateTime dateB = DateFormat('MMMyyyy').parse(b);
              return dateA.compareTo(dateB);
            });

        // Update available months if they have changed or on initial load
        if (_availableMonthYears.isEmpty ||
            !listEquals(_availableMonthYears, sortedMonths)) {
          _availableMonthYears = sortedMonths;
          // Set initial selected month to the latest available month
          if (_selectedMonthYear == null && _availableMonthYears.isNotEmpty) {
            _selectedMonthYear = _availableMonthYears.last;
          }
        }

        // Prepare data for the selected month for the Pie Chart
        Map<String, double> salesForSelectedMonth =
            monthlySalesByItem[_selectedMonthYear] ?? {};

        List<PieChartSectionData> sections = [];
        double totalSalesInSelectedMonth = 0;

        // Sort items for consistent legend and tooltip order
        List<String> sortedItemNames =
            salesForSelectedMonth.keys.toList()..sort();

        for (var itemName in sortedItemNames) {
          double salesAmount = salesForSelectedMonth[itemName] ?? 0.0;
          if (salesAmount > 0) {
            totalSalesInSelectedMonth += salesAmount;
            final isTouched = sortedItemNames.indexOf(itemName) == touchedIndex;
            final fontSize = isTouched ? 16.0 : 12.0;
            final radius =
                isTouched ? 60.0 : 50.0; // Slightly larger when touched

            sections.add(
              PieChartSectionData(
                color: _getItemColor(itemName),
                value: salesAmount,
                title:
                    'RM${salesAmount.toStringAsFixed(2)}', // Display amount on slice
                radius: radius,
                titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
                badgeWidget:
                    isTouched
                        ? _PieChartSectionBadge(
                          itemName,
                          _getItemColor(itemName),
                        )
                        : null,
                badgePositionPercentageOffset: .98,
              ),
            );
          }
        }

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
                  'Monthly Sales Distribution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Month selection dropdown
                if (_availableMonthYears.isNotEmpty)
                  Center(
                    child: DropdownButton<String>(
                      value: _selectedMonthYear,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedMonthYear = newValue;
                            touchedIndex =
                                -1; // Reset touched index when month changes
                          });
                        }
                      },
                      items:
                          _availableMonthYears.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                DateFormat(
                                  'MMMM yyyy',
                                ).format(DateFormat('MMMyyyy').parse(value)),
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                const SizedBox(height: 20),
                if (sections.isEmpty)
                  Container(
                    height: 250,
                    alignment: Alignment.center,
                    child: Text(
                      'No sales data for ${DateFormat('MMMM yyyy').format(DateFormat('MMMyyyy').parse(_selectedMonthYear!))}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 250, // Height for the pie chart
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (
                            FlTouchEvent event,
                            pieTouchResponse,
                          ) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                            });
                          },
                        ),
                        sectionsSpace: 2, // Space between sections
                        centerSpaceRadius: 40, // Inner circle radius
                        sections: sections,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Total Sales and Legend
                if (totalSalesInSelectedMonth > 0) ...[
                  Text(
                    'Total Sales for ${DateFormat('MMMM yyyy').format(DateFormat('MMMyyyy').parse(_selectedMonthYear!))}: RM${totalSalesInSelectedMonth.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Item Distribution:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    alignment: WrapAlignment.center,
                    children:
                        sortedItemNames.map((itemName) {
                          if (salesForSelectedMonth[itemName]! > 0) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: _getItemColor(itemName),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  itemName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink(); // Hide if no sales
                        }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// Helper widget for the badge on touched pie chart sections
class _PieChartSectionBadge extends StatelessWidget {
  const _PieChartSectionBadge(this.itemName, this.color);
  final String itemName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          itemName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

// Helper function to compare lists for `_availableMonthYears` update
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
