import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Import for listEquals

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
  List<String> _availableMonthYears =
      []; // All available 'MMMyyyy' strings for the selected year

  // NEW: Year state variables
  int? _selectedYear; // Stores the selected year e.g., 2024
  List<int> _availableYears = []; // All unique years from the data

  // State variable to hold the index of the touched section for tooltip
  int touchedIndex = -1;

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

        // --- MODIFIED: Process data to aggregate sales by Year, Month, and ItemName ---
        // Map: Year -> MonthYear -> ItemName -> TotalSales
        Map<int, Map<String, Map<String, double>>> yearlyMonthlySalesByItem =
            {};
        Set<int> uniqueYears = {}; // To collect all unique years

        for (var order in snapshot.data!) {
          if (order.status == OrderStatus.delivered ||
              order.status == OrderStatus.confirmed) {
            DateTime orderDateTime = order.orderDate.toDate();
            int year = orderDateTime.year;
            String monthYear = DateFormat('MMMyyyy').format(orderDateTime);

            uniqueYears.add(year); // Add year to unique set

            // Initialize maps if they don't exist
            yearlyMonthlySalesByItem.putIfAbsent(year, () => {});
            yearlyMonthlySalesByItem[year]!.putIfAbsent(monthYear, () => {});

            for (var cartItem in order.items) {
              final String itemName = cartItem.itemName;
              final double itemTotal = cartItem.quantity * cartItem.itemPrice;

              yearlyMonthlySalesByItem[year]![monthYear]!.update(
                itemName,
                (value) => value + itemTotal,
                ifAbsent: () => itemTotal,
              );
            }
          }
        }

        // --- NEW/MODIFIED: Initialize/Update Year and Month Selectors ---
        List<int> sortedYears = uniqueYears.toList()..sort();
        // Update available years if they have changed or on initial load
        if (!listEquals(_availableYears, sortedYears)) {
          _availableYears = sortedYears;
          // Set initial selected year to the latest available year
          if (_selectedYear == null && _availableYears.isNotEmpty) {
            _selectedYear = _availableYears.last;
          } else if (_selectedYear != null &&
              !_availableYears.contains(_selectedYear)) {
            // If previously selected year is no longer available, default to latest
            _selectedYear =
                _availableYears.isNotEmpty ? _availableYears.last : null;
          }
        }

        // Get monthly sales data for the currently selected year
        Map<String, Map<String, double>> currentYearMonthlySales =
            yearlyMonthlySalesByItem[_selectedYear] ?? {};

        List<String> sortedMonthsForSelectedYear =
            currentYearMonthlySales.keys.toList()..sort((a, b) {
              DateTime dateA = DateFormat('MMMyyyy').parse(a);
              DateTime dateB = DateFormat('MMMyyyy').parse(b);
              return dateA.compareTo(dateB);
            });

        // Update available months for the selected year
        if (!listEquals(_availableMonthYears, sortedMonthsForSelectedYear)) {
          _availableMonthYears = sortedMonthsForSelectedYear;
          // Set initial selected month to the latest available month for the current year
          if (_selectedMonthYear == null && _availableMonthYears.isNotEmpty) {
            _selectedMonthYear = _availableMonthYears.last;
          } else if (_selectedMonthYear != null &&
              !_availableMonthYears.contains(_selectedMonthYear)) {
            // If previously selected month not available for new year, default to latest
            _selectedMonthYear =
                _availableMonthYears.isNotEmpty
                    ? _availableMonthYears.last
                    : null;
          }
        }
        // --- END Initialize/Update Selectors ---

        // Prepare data for the selected month for the Pie Chart
        Map<String, double> salesForSelectedMonth =
            currentYearMonthlySales[_selectedMonthYear] ??
            {}; // Access via selected year's map

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
                // NEW: Year and Month selection dropdowns in a Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Year Dropdown
                    if (_availableYears.isNotEmpty)
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          value: _selectedYear,
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedYear = newValue;
                                _selectedMonthYear =
                                    null; // Reset month when year changes
                                touchedIndex = -1; // Reset touched index
                              });
                            }
                          },
                          items:
                              _availableYears.map<DropdownMenuItem<int>>((
                                int year,
                              ) {
                                return DropdownMenuItem<int>(
                                  value: year,
                                  child: Text('$year'),
                                );
                              }).toList(),
                          isExpanded: true,
                        ),
                      ),
                    const SizedBox(width: 10), // Space between dropdowns
                    // Month Dropdown
                    if (_availableMonthYears.isNotEmpty)
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Month',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
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
                              _availableMonthYears
                                  .map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        DateFormat('MMMM').format(
                                          DateFormat('MMMyyyy').parse(value),
                                        ),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  })
                                  .toList(),
                          isExpanded: true,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Chart or No Data Message
                if (sections.isEmpty)
                  Container(
                    height: 250,
                    alignment: Alignment.center,
                    child: Text(
                      'No sales data for ${_selectedMonthYear != null ? DateFormat('MMMM y').format(DateFormat('MMMyyyy').parse(_selectedMonthYear!)) : 'the selected period'}',
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
                    'Total Sales for ${DateFormat('MMMM y').format(DateFormat('MMMyyyy').parse(_selectedMonthYear!))}: RM${totalSalesInSelectedMonth.toStringAsFixed(2)}',
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
