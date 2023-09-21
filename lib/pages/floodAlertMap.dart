import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/floodAlertList.dart';
import 'package:flutter_orol_v2/pages/floodWatch.dart';
import 'package:flutter_orol_v2/pages/sideNavigationBar/sideNavigationBar.dart';
import 'package:flutter_orol_v2/services/models/floodWatch.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps package

class FloodAlertMap extends StatefulWidget {
  String mode;
  FloodAlertMap({Key? key, required this.mode}) : super(key: key);

  @override
  State<FloodAlertMap> createState() => _FloodAlertMapState();
}


class _FloodAlertMapState extends State<FloodAlertMap> {
  List<dynamic> items = [];
  bool isLoading = true;
  FloodAlert _floodAlert = new FloodAlert();
  int currentPage = 1; // Initialize to the first page
  List<dynamic> allData = [];
  bool isExpanded = false;
  var today;
  int index =0;
  bool isTodayButtonActive = false;
  bool isThisWeekButtonActive = false;
  bool isThisMonthButtonActive = false;
  bool isThisYearButtonActive = false;
  bool isAllButtonActive = true;


  getTodayDate(){
    Navigator.of(context).pop();
    var today = DateTime.now();
    var startDate = "${today.year}-${today.month}-${today.day}";
    var endDate = "${today.year}-${today.month}-${today.day+1}";
    fetchDataByFilter(startDate,endDate);
    setState(() {
      isTodayButtonActive = true;
      isThisWeekButtonActive = false;
      isThisMonthButtonActive = false;
      isThisYearButtonActive = false;
      isAllButtonActive = false;
    });
  }

  getWeek(){
    Navigator.of(context).pop();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    var startDate = "${startOfWeek.year}-${startOfWeek.month}-${startOfWeek.day}";
    var endDate = "${endOfWeek.year}-${endOfWeek.month}-${endOfWeek.day}";
    fetchDataByFilter(startDate,endDate);
    setState(() {
      isTodayButtonActive = false;
      isThisWeekButtonActive = true;
      isThisMonthButtonActive = false;
      isThisYearButtonActive = false;
      isAllButtonActive = false;
    });
  }

  getMonth(){
    Navigator.of(context).pop();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));
    var startDate = "${startOfMonth.year}-${startOfMonth.month}-${startOfMonth.day}";
    var endDate = "${endOfMonth.year}-${endOfMonth.month}-${endOfMonth.day}";
    fetchDataByFilter(startDate,endDate);
    setState(() {
      isTodayButtonActive = false;
      isThisWeekButtonActive = false;
      isThisMonthButtonActive = true;
      isThisYearButtonActive = false;
      isAllButtonActive = false;
    });
  }

  getYear(){
    Navigator.of(context).pop();
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    var startDate = "${startOfYear.year}-${startOfYear.month}-${startOfYear.day}";
    var endDate = "${endOfYear.year}-${endOfYear.month}-${endOfYear.day}";
    fetchDataByFilter(startDate,endDate);
    setState(() {
      isTodayButtonActive = false;
      isThisWeekButtonActive = false;
      isThisMonthButtonActive = false;
      isThisYearButtonActive = true;
      isAllButtonActive = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        // You can build your filter UI inside this builder
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  getTodayDate();
                },
                style: ElevatedButton.styleFrom(
                  primary: isTodayButtonActive ? Colors.lightGreen : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Resources.colors.appTheme.darkBlue,
                    ),
                  ),
                  minimumSize: Size(double.infinity, 20.0),
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: isTodayButtonActive ? Colors.white : Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  getWeek();
                },
                style: ElevatedButton.styleFrom(
                  primary: isThisWeekButtonActive ? Colors.lightGreen : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Resources.colors.appTheme.darkBlue,
                    ),
                  ),
                  minimumSize: Size(double.infinity, 20.0),
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text(
                  'This Week',
                  style: TextStyle(
                    color: isThisWeekButtonActive ? Colors.white : Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  getMonth();
                },
                style: ElevatedButton.styleFrom(
                  primary: isThisMonthButtonActive ? Colors.lightGreen : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Resources.colors.appTheme.darkBlue,
                    ),
                  ),
                  minimumSize: Size(double.infinity, 20.0),
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text(
                  'This Month',
                  style: TextStyle(
                    color: isThisMonthButtonActive ? Colors.white : Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  getYear();
                },
                style: ElevatedButton.styleFrom(
                  primary: isThisYearButtonActive ? Colors.lightGreen : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Resources.colors.appTheme.darkBlue,
                    ),
                  ),
                  minimumSize: Size(double.infinity, 20.0),
                  padding: EdgeInsets.all(12.0),
                ),
                child: Text(
                  'This Year',
                  style: TextStyle(
                    color: isThisYearButtonActive ? Colors.white : Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  fetchData();
                  setState(() {
                    isAllButtonActive = true; // Set the "All" button to active (green)
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    isAllButtonActive ? Colors.lightGreen : Colors.white,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: Resources.colors.appTheme.darkBlue,
                      ),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 20.0)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(12.0)),
                ),
                child: Text(
                  'All',
                  style: TextStyle(
                    color: isAllButtonActive ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _navigateToFloodAlertListScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloodAlertList(),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<dynamic> fetchedItems = [];
      int currentPage = 1; // Start with page 1

      while (true) {
        final floodAlert = await _floodAlert.getFloodAlert(currentPage);
        if (floodAlert.details.isEmpty) {
          // Stop fetching if there are no more items on the current page
          break;
        }
        fetchedItems.addAll(floodAlert.details);
        currentPage++; // Move to the next page
      }

      setState(() {
        items = fetchedItems;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDataByFilter(startDate,endDate) async {
    try {
      List<dynamic> fetchedItems = [];
      int currentPage = 1; // Start with page 1
      final floodAlert = await _floodAlert.getFloodAlertByFilter(currentPage,startDate,endDate);
      setState(() {
        items = floodAlert.details;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
    _navigateToFloodWatchFormScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloodWatchForm(mode: "add"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create a LatLng object for the location

    // Define a set of markers
    List<Marker> markers = [];
    for (int i = 0; i < items.length; i++) {
      var dataItem = items[i]; // Replace 'yourData' with your actual data source

      // Check if dataItem is not null and latitude and longitude are not null or empty
      if (dataItem != null &&
          dataItem.latitude != null &&
          dataItem.longitude != null &&
          dataItem.latitude.isNotEmpty &&
          dataItem.longitude.isNotEmpty) {
        markers.add(
          Marker(
            markerId: MarkerId('$i'), // Use a unique identifier, e.g., index
            position: LatLng(double.parse(dataItem.latitude), double.parse(dataItem.longitude)),
            infoWindow: InfoWindow(
              title: dataItem.location ?? '', // Provide a default empty string for location
              snippet: '(${dataItem.latitude}, ${dataItem.longitude})',
            ),
          ),
        );
      }
    }

    Set<Marker> markerSet = markers.toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text("Flood Alert Map View"),
          actions: [
          IconButton(
            icon: Icon(Icons.filter_list), // This is the filter icon
            onPressed: () {
              _showFilterBottomSheet(); // Add your filter logic here
              // You can open a filter dialog or perform any other filter-related action
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              _navigateToFloodAlertListScreen(context);// Add your logic here when the "+" button is pressed
            },
          ),
        ],
      ),
      drawer: AppSideNavigationBar(onTap: (ctx,i){
        setState(() {
          index=i;
          Navigator.pop(ctx);
        });
      }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Resources.colors.appTheme.blue,
        foregroundColor: Resources.colors.appTheme.white,
        onPressed: () {
          // add your onPressed event handler here
          _navigateToFloodWatchFormScreen(context);
        },
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(20.5937, 78.9629),
          zoom: 2.0, // Adjust the initial zoom level as needed
        ),
        markers: markerSet, // Set the markers for the map
      ),
    );
  }
}


void main() => runApp(MaterialApp(
  home: FloodAlertMap(mode: 'your_mode'),
));
