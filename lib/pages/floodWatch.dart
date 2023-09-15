import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/addFloodAlert.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../widgets/features/googleMap.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';





class FloodWatchForm extends StatefulWidget {
  String mode;
  FloodWatchForm({Key? key, required this.mode}) : super(key: key);

  @override
  State<FloodWatchForm> createState() => _FloodWatchFormState();
}

class _FloodWatchFormState extends State<FloodWatchForm> {
  bool isLoading = true;
  bool _error=false;
  TextEditingController additionalDetailsController = TextEditingController();
  DateTime now = DateTime.now();
  final String GOOGLE_MAP_API='AIzaSyD9VmkK8P-ONafIM_49q6v5vtu3apjbdFg';
  final TextEditingController activityDateController = TextEditingController();
  final TextEditingController activityTimeController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  List<PlacesSearchResult> _searchResults = [];

  var floodInformation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }




  final FormGroup form = fb.group({
    'floodInformation': fb.group({
      'latitude': FormControl<String>(validators: [Validators.required]),
      'longitude': FormControl<String>(validators: [Validators.required]),
      'location': FormControl<String>(validators: [Validators.required]),
    }),
  });

  setForm(){
    form.control('floodInformation.latitude').value=floodInformation['latitude'];
    form.control('floodInformation.longitude').value=floodInformation['longitude'];
    form.control('floodInformation.location').value=floodInformation['location'];
  }
  _getCurrentLocation()async{
    try {
      setState(() {
        isLoading = true;
      });
      // Get the current position (latitude and longitude)
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocoding to get the address from the coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      double latitude = position.latitude;
      double longitude = position.longitude;

      // Extract the location name from the first placemark
      Placemark placemark = placemarks.first;
      String? locationName = "${placemark.name!}, ${placemark.street}, ${placemark.postalCode}, ${placemark.country}";
      setState(() {
        isLoading = false;
        _searchController.text= locationName.toString();
        form.control('floodInformation.location').value= locationName.toString();
        form.control('floodInformation.latitude').value=position.latitude.toString();
        form.control('floodInformation.longitude').value=position.longitude.toString();
      });
      return locationName;
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Set isLoading to false on error
      });
      return null;
    }
  }


  _navigateToFloodAlertScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FloodAlertForm(mode:"add",formValue: form.value,)));

  }

  void _onSearchTextChanged(String value) async {
    final places = GoogleMapsPlaces(apiKey: GOOGLE_MAP_API);

    PlacesAutocompleteResponse response = await places.autocomplete(
      value,
      language: 'en',
      types: ['geocode'], // Restrict to addresses only
    );

    setState(() {
      _searchResults = response.predictions
          .map((prediction) => PlacesSearchResult(
        placeId: prediction.placeId.toString(),
        name: prediction.structuredFormatting!.mainText,
        formattedAddress: prediction.structuredFormatting!.secondaryText, reference: '',
      ))
          .toList();
    });
  }

  Future<Map<String, dynamic>> getLocationFromPlaceId(String placeId) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$GOOGLE_MAP_API';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      form.control('floodInformation.latitude').value="${decodedData['result']['geometry']['location']['lat']}";
      form.control('floodInformation.longitude').value="${decodedData['result']['geometry']['location']['lng']}";
      return decodedData;
    } else {
      throw Exception('Failed to fetch location data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flood Watch"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(30), // Add 30 units of padding to the entire container
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(height: 30),
            _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ReactiveForm(
                formGroup: form,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter, // Align the text to the top center
                      child: Text(
                        "PICK YOUR LOCATION",
                        style: TextStyle(
                          color: Resources.colors.appTheme.darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text:  TextSpan(
                            text: 'Location',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'WorkSans',
                                color: Resources.colors.appTheme.lable
                            ),
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Form(
                          key: this._formKey,
                          autovalidateMode: _autoValidate
                              ? AutovalidateMode.always
                              : AutovalidateMode.disabled,
                          child: TypeAheadFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required field';
                              }
                              return null;
                            },
                            textFieldConfiguration:  TextFieldConfiguration(
                              controller:_searchController,
                              decoration:  InputDecoration(
                                border: UnderlineInputBorder(),
                                // suffixIcon: IconButton(
                                //   icon: Icon(
                                //     Icons.gps_fixed,
                                //     color: Resources.colors.appTheme.blue,// Set the color you want here
                                //   ),
                                //   onPressed: () async {
                                //     _navigateToMap();
                                //   },
                                // ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:Resources.colors.appTheme.darkBlue,  // Replace with your desired focus border color
                                    width: 1.0,         // Replace with your desired focus border width
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'WorkSans',
                                color: Resources.colors.appTheme.veryDarkGray,
                              ),
                            ),
                            suggestionsCallback: (pattern) async {
                              form.control('floodInformation.location').value=pattern;
                              _onSearchTextChanged(pattern);
                              return _searchResults.where((place) =>
                                  place.name.toLowerCase().contains(pattern.toLowerCase()));
                            },
                            itemBuilder: (context, suggestion) {
                              return _searchResults.length>0?ListTile(
                                title: Text(suggestion.name),
                                subtitle: Text(suggestion.formattedAddress==null?"":"${suggestion.formattedAddress}"),
                              ):SizedBox();
                            },
                            onSuggestionSelected: (suggestion) {
                              var location= "${suggestion.name}, ${suggestion.formattedAddress!=null?suggestion.formattedAddress:''}";
                              getLocationFromPlaceId(suggestion.placeId);
                              setState(() {
                                _searchController.text=location;
                                form.control('floodInformation.location').value=location;
                              });
                            },
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text:  TextSpan(
                            text: 'Latitude',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'WorkSans',
                                color: Resources.colors.appTheme.lable
                            ),
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ReactiveTextField<String>(
                          formControlName: 'floodInformation.latitude',
                          keyboardType: TextInputType.number,
                          validationMessages: {
                            ValidationMessage.required: (_) => 'Required field',
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color:Resources.colors.appTheme.darkBlue,  // Replace with your desired focus border color
                                width: 1.0,         // Replace with your desired focus border width
                              ),
                            ),
                            helperText: '',
                            helperStyle: TextStyle(height: 0.7),
                            errorStyle: TextStyle(height: 1),
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'WorkSans',
                            color: Resources.colors.appTheme.veryDarkGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text:  TextSpan(
                            text: 'Longitude',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'WorkSans',
                                color: Resources.colors.appTheme.lable
                            ),
                            children: const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ReactiveTextField<String>(
                          formControlName: 'floodInformation.longitude',
                          keyboardType: TextInputType.number,
                          validationMessages: {
                            ValidationMessage.required: (_) => 'Required field',
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color:Resources.colors.appTheme.darkBlue,  // Replace with your desired focus border color
                                width: 1.0,         // Replace with your desired focus border width
                              ),
                            ),
                            helperText: '',
                            helperStyle: TextStyle(height: 0.7),
                            errorStyle: TextStyle(height: 1),
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'WorkSans',
                            color: Resources.colors.appTheme.veryDarkGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30,),
                    Container(
                      decoration: BoxDecoration(
                        color: Resources.colors.appTheme.blue, // Change this to your desired blue color
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: EdgeInsets.all(25),
                      child: Column(
                        children: [
                          Text(
                            "Did you observe flooding in the above location?",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'WorkSans',
                              color: Resources.colors.appTheme.white,
                            ),
                          ),
                          const SizedBox(height: 30,),
                          ElevatedButton(
                            onPressed: () {
                              _navigateToFloodAlertScreen(context);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: const Color(0xFF7ABE32), // Background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0), // Border radius
                              ),
                            ),
                            child: Text(
                                ("Add Alert"),
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'WorkSans',
                                color: Resources.colors.appTheme.darkBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30,),
                    Container(
                      height: 300, // Adjust the height as needed
                      child: CustomGoogleMap(
                        onLocationPicked: (locationName, latitude, longitude) {
                          setState(() {
                            _searchController.text = locationName;
                            form.control('floodInformation.location').value = locationName;
                            form.control('floodInformation.latitude').value = latitude.toString();
                            form.control('floodInformation.longitude').value = longitude.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

