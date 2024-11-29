import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyStatisticsScreen extends StatefulWidget {
  @override
  _MyStatisticsScreenState createState() => _MyStatisticsScreenState();
}

class _MyStatisticsScreenState extends State<MyStatisticsScreen> {
  int _selectedIndex = 0;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Class-level variables for practice data
  List<String> categories = [];
  List<String> tips = [];
  List<List<String?>> gridData = [];
   List<DateTime> _getDateRange() {
    List<DateTime> dateRange = [];
    DateTime currentDate = _startDate;

    while (!currentDate.isAfter(_endDate)) {
      dateRange.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }

    return dateRange;
  }

  @override
  void initState() {
    super.initState();
    _loadPracticeData(); // Load practice data on initialization
  }

  // Fetch practice data from Firebase Firestore
  Future<void> _loadPracticeData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!docSnapshot.exists) return;

      var userData = docSnapshot.data() as Map<String, dynamic>;
      var practiceData = (userData['practice'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

      // Extract categories and tips
      setState(() {
        categories = practiceData
            .map((session) => session['category']?.toString() ?? 'Unknown Category')
            .toSet()
            .toList();
        tips = practiceData
            .map((session) => session['tip']?.toString() ?? 'Unknown Tip')
            .toSet()
            .toList();

        categories.sort();
        tips.sort();

        // Prepare gridData
        gridData = List.generate(
          categories.length,
          (_) => List<String?>.filled(tips.length, null),
        );

        for (var session in practiceData) {
          var categoryIndex = categories.indexOf(session['category']);
          var tipIndex = tips.indexOf(session['tip']);
          if (categoryIndex != -1 && tipIndex != -1) {
            gridData[categoryIndex][tipIndex] = session['sets']?.toString();
          }
        }
      });
    } catch (e) {
      print("Error loading practice data: $e");
    }
  }

  // Toggle between Practice Data and Graph
  void _onToggleButton(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Date Picker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
    String _getDataForDate(DateTime date, int categoryIndex, int tipIndex) {
    // Your logic here for checking if the date exists in the data
    // This is just an example; replace it with actual data logic.
    if (gridData[categoryIndex][tipIndex] != null) {
      return gridData[categoryIndex][tipIndex]!;
    }
    return "NA";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Minhas estatísticas"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onToggleButton(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == 0 ? Colors.green : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Dados práticos"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onToggleButton(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIndex == 1 ? Colors.green : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text("Gráfico", style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(),
          Expanded(
            child: _selectedIndex == 0
                ? PracticeDataScreen()
                : GraphScreen(
                    categories: categories,
                    tips: tips,
                    gridData: gridData,
                  ),
          ),
        ],
      ),
    );
  }
}




class PracticeDataScreen extends StatefulWidget {
  @override
  _PracticeDataScreenState createState() => _PracticeDataScreenState();
}

class _PracticeDataScreenState extends State<PracticeDataScreen> {
  List<Map<String, dynamic>> practiceData = [];
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchPracticeData();
  }

  Future<void> fetchPracticeData() async {
    try {
      // Get the current logged-in user
      User? user = _auth.currentUser;
      if (user == null) {
        print("No user is logged in");
        return;
      }

      // Fetch practice data for the logged-in user only
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        print("User document not found");
        return;
      }

      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      print("Fetched User Data: $data"); // Debug print

      List<dynamic>? practices = data?['practice'];
      if (practices != null) {
        List<Map<String, dynamic>> fetchedData = [];

        for (var practice in practices) {
          // Parse the timestamp field and store it
          Timestamp? timestamp = practice['timestamp'];
          if (timestamp != null) {
            practice['parsedTimestamp'] = timestamp.toDate(); // Convert Timestamp to DateTime
            print("Parsed Timestamp: ${practice['parsedTimestamp']}"); // Debug print
          }
          fetchedData.add(Map<String, dynamic>.from(practice));
        }

        // Now filter based on the selected date range using the timestamp
        List<Map<String, dynamic>> filteredData = fetchedData.where((entry) {
          DateTime? parsedTimestamp = entry['parsedTimestamp'];
          return parsedTimestamp != null &&
              !parsedTimestamp.isBefore(_startDate) &&
              !parsedTimestamp.isAfter(_endDate);
        }).toList();

        // Sort the filtered data by the timestamp field in ascending order
        filteredData.sort((a, b) {
          DateTime timestampA = a['parsedTimestamp'] ?? DateTime.now();
          DateTime timestampB = b['parsedTimestamp'] ?? DateTime.now();
          return timestampA.compareTo(timestampB); // Ascending order
        });

        setState(() {
          practiceData = filteredData;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      fetchPracticeData();  // Re-fetch data with new date range
    }
  }

  @override
  Widget build(BuildContext context) {
    // Organize data into UI-friendly format
    Map<String, List<Map<String, dynamic>>> groupedData = {};
    for (var entry in practiceData) {
      String category = entry['category'] ?? 'Unknown';
      groupedData.putIfAbsent(category, () => []).add(entry);
    }

    List<String> categories = groupedData.keys.toList();

    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Display
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDateRange(context),
                    icon: Icon(Icons.date_range),
                    label: Text("Selecione o intervalo de datas"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, 
                      backgroundColor: Color.fromRGBO(124, 12, 17, 1),
                    ),
                  ),
                ),
                Text(
                  "${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM').format(_endDate)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Data Grid (Wrapped in Expanded to prevent overflow)
            Expanded(
              child: practiceData.isEmpty
                  ? Center(
                      child: Text(
                        "Nenhum dado disponível",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        String category = categories[index];
                        List<Map<String, dynamic>> entries = groupedData[category] ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 150,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _generateDateRange(_startDate, _endDate).map((date) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              DateFormat('d MMM').format(date),
                                              style: TextStyle(
                                                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: entries.map((entry) {
                                                bool hasData = DateFormat('yyyy-MM-dd').format(entry['parsedTimestamp']) == DateFormat('yyyy-MM-dd').format(date);

                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                                  decoration: BoxDecoration(
                                                    color: hasData ? Colors.green : Colors.grey,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      hasData ? entry['sets'].toString() : "NA",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to generate a date range
  List<DateTime> _generateDateRange(DateTime startDate, DateTime endDate) {
    List<DateTime> dateRange = [];
    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(Duration(days: 1))) {
      dateRange.add(date);
    }
    return dateRange;
  }
}



class GraphScreen extends StatelessWidget {
  final List<String> categories;
  final List<String> tips;
  final List<List<String?>> gridData;

  GraphScreen({
    required this.categories,
    required this.tips,
    required this.gridData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Practice Data Visualization",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            _buildBarGraph(),
            SizedBox(height: 32),  // Added some spacing between the two graphs
            _buildPieChart(),
          ],
        ),
      ),
    );
  }

  // Simple Bar Graph
  Widget _buildBarGraph() {
    return Container(
      height: 300, // Adjusted the height for better visibility
      child: BarChart(
        BarChartData(
          barGroups: List.generate(categories.length, (index) {
            final totalSets = gridData[index]
                .map((value) => int.tryParse(value ?? '0') ?? 0)
                .reduce((a, b) => a + b);

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: totalSets.toDouble(),
                  color: Colors.primaries[index % Colors.primaries.length],
                  width: 30,  // Made the bars wider
                  borderRadius: BorderRadius.circular(6), // Rounded corners for bars
                ),
              ],
              showingTooltipIndicators: [0],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      categories[index],
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true),  // Added grid lines for better readability
          borderData: FlBorderData(show: true),  // Added border around the chart
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipMargin: 8,
              tooltipBorder: BorderSide(color: Colors.grey),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "${categories[groupIndex]}: ${rod.toY.toInt()} sets",
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Pie Chart
  Widget _buildPieChart() {
    final totalPerTip = List.generate(
      tips.length,
      (index) => gridData
          .map((row) => int.tryParse(row[index] ?? '0') ?? 0)
          .reduce((a, b) => a + b),
    );

    final totalSum = totalPerTip.fold(0, (sum, item) => sum + item);

    return Container(
      height: 250,
     
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: List.generate(
            tips.length,
            (index) {
              final value = totalPerTip[index].toDouble();
              final percentage = (value / totalSum) * 100;

              return PieChartSectionData(
                value: value,
                title: "${percentage.toStringAsFixed(1)}%",  // Displaying percentage inside pie chart
                color: Colors.primaries[index % Colors.primaries.length],
                radius: 60,  // Adjusted the radius to make the pie chart more proportional
                titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (response != null && response.touchedSection != null) {
                final index = response.touchedSection!.touchedSectionIndex;
                print("Tapped on: ${tips[index]}");
              }
            },
          ),
        ),
      ),
    );
  }
}
