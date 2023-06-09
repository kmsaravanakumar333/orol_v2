import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:flutter_orol_v2/services/constants/constants.dart';
import '../services/models/riverMonitoring.dart';
import '../services/providers/AppSharedPreferences.dart';
import '../widgets/features/googleMap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../widgets/features/pictureOptions.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class RiverMonitoringForm extends StatefulWidget {
  String mode;
  RiverMonitoringForm({Key? key, required this.mode}) : super(key: key);

  @override
  State<RiverMonitoringForm> createState() => _RiverMonitoringFormState();
}

class _RiverMonitoringFormState extends State<RiverMonitoringForm> {
  int _index = 0;
  List<Step> _steps=[];
  bool _error=false;
  bool _isSubmitted=false;
  DateTime now = DateTime.now();
  final String GOOGLE_MAP_API='AIzaSyD9VmkK8P-ONafIM_49q6v5vtu3apjbdFg';
  final TextEditingController activityDateController = TextEditingController();
  final TextEditingController activityTimeController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  List<PlacesSearchResult> _searchResults = [];
  var selectedWaterLevel ;
  var selectedWeather;
  var _bacteriaPresent;
  List<String> selectedSurroundings = [];
  WaterTestDetails _waterTestDetail = new WaterTestDetails();

  //River Images
  var selectedRiverImages = [];
  var riverDescriptions = [];
  //Surrounding Images
  var selectedSurroundingImages = [];
  var surroundingDescriptions = [];
  //Flora Images
  var selectedFloraImages = [];
  var floraDescriptions = [];
  //Fauna Images
  var selectedFaunaImages = [];
  var faunaDescriptions = [];
  //Surrounding Images
  var selectedGroupImages = [];
  var groupImageDescriptions = [];
  //Flora Images
  var selectedActivityImages = [];
  var activityImageDescriptions = [];
  //Fauna Images
  var selectedArtworkImages = [];
  var artworkDescriptions = [];

  var riverImgObj=[];
  var surroundingImgObj=[];
  var floraImgObj=[];
  var faunaImgObj=[];
  var groupImgObj=[];
  var activityImgObj=[];
  var artwrokImgObj=[];
  @override
  void initState() {
    super.initState();
    setState(() {
      form.control('generalInformation.activityDate').value=DateFormat('yyyy-MM-dd').format(now);
      form.control('generalInformation.activityTime').value= DateFormat('h:mm a').format(now);
    });
    if(widget.mode=="edit"){
      getRiverMonitoringDetail();
    }
    _steps = _generateSteps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<WaterTestDetails?> getRiverMonitoringDetail() async {
    _waterTestDetail = (await AppSharedPreference().getRiverMonitoringInfo())! ;
  }

  Future<void> pickImages(name,mode) async {
    XFile? image;
    try {
      if(mode=='Gallery'){
        image = await ImagePicker().pickImage(source: ImageSource.gallery);
      }else if(mode=='Camera'){
        image = await ImagePicker().pickImage(source: ImageSource.camera);
      }
    } catch (e) {
      // Handle any exceptions
    }
    if (image == null) return;
    setState(() {
      // Image.file(File(image!.path));
      File file = File(image!.path);
      if(name=='riverPicture'){
        selectedRiverImages.add(file);
        riverDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='surroundingImages'){
        selectedSurroundingImages.add(file);
        surroundingDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='flora'){
        selectedFloraImages.add(file);
        floraDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='fauna'){
        selectedFaunaImages.add(file);
        faunaDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='group'){
        selectedGroupImages.add(file);
        groupImageDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='activity'){
        selectedActivityImages.add(file);
        activityImageDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='artwork'){
        selectedArtworkImages.add(file);
        artworkDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
    });
  }
  //FORM
  final steps = ['generalInformation', 'waterLevelAndWeather','surroundings','waterTesting','flora','preview'];
  final FormGroup form = fb.group({
    'generalInformation': fb.group({
      'activityDate': FormControl<String>(value:'',validators: [Validators.required]),
      'activityTime': FormControl<String>(validators: [Validators.required]),
      'latitude': FormControl<String>(validators: [Validators.required]),
      'longitude': FormControl<String>(validators: [Validators.required]),
      'location': FormControl<String>(validators: [Validators.required]),
      'testerName': FormControl<String>(validators: [Validators.required]),
    }),
    'waterLevelAndWeather': fb.group({
      'airTemperature': FormControl<String>(value:'',validators: [Validators.required,Validators.number]),
      'waterLevel': FormControl<String>(validators: [Validators.required]),
      'weather': FormControl<String>(validators: [Validators.required]),
    }),
    'surroundings':  FormControl<List<String>>(value:[],validators: [Validators.required]),
    'waterTesting': fb.group({
      'alkalinity': FormControl<String>(),
      'ammonia': FormControl<String>(),
      'bacteria': FormControl<String>(),
      'chlorine': FormControl<String>(),
      'dissolvedOxygen': FormControl<String>(),
      'hardness': FormControl<String>(),
      'iron': FormControl<String>(),
      'lead': FormControl<String>(),
      'nitrate': FormControl<String>(),
      'nitrite': FormControl<String>(),
      'pH': FormControl<String>(),
      'phosphate': FormControl<String>(),
      'turbidity': FormControl<String>(),
      'waterTemperature': FormControl<String>(),
      'totalDissolvedSolids': FormControl<String>(),
      'conductivity': FormControl<String>(),
    }),
    'riverPictures':FormControl<List>(value:[]),
    'surroundingPictures':FormControl<List>(value:[]),
    'floraPictures':FormControl<List>(value:[]),
    'faunaPictures':FormControl<List>(value:[]),
    'groupPictures':FormControl<List>(value:[]),
    'artworkPictures':FormControl<List>(value:[]),
    'activityPictures':FormControl<List>(value:[]),
  });

  final List<Map<String, String>> fieldConfigs = [
    {'fieldName': 'waterTesting.waterTemperature', 'label': 'Water Temperature'},
    {'fieldName': 'waterTesting.pH', 'label': 'pH'},
    {'fieldName': 'waterTesting.alkalinity', 'label': 'Alkalinity'},
    {'fieldName': 'waterTesting.nitrate', 'label': 'Nitrate'},
    {'fieldName': 'waterTesting.nitrite', 'label': 'Nitrite'},
    {'fieldName': 'waterTesting.hardness', 'label': 'Hardness'},
    {'fieldName': 'waterTesting.chlorine', 'label': 'Chlorine'},
    {'fieldName': 'waterTesting.iron', 'label': 'Iron'},
    {'fieldName': 'waterTesting.dissolvedOxygen', 'label': 'Dissolved Oxygen'},
    {'fieldName': 'waterTesting.turbidity', 'label': 'Turbidity'},
    {'fieldName': 'waterTesting.phosphate', 'label': 'Phosphate'},
    {'fieldName': 'waterTesting.ammonia', 'label': 'Ammonia'},
    {'fieldName': 'waterTesting.lead', 'label': 'Lead'},
    {'fieldName': 'waterTesting.totalDissolvedSolids', 'label': 'Total Dissolved Solids'},
    {'fieldName': 'waterTesting.conductivity', 'label': 'Conductivity'},
  ];

  // Generate water quality form fields dynamically using a loop
  List<Widget> waterQualityFormFields() {
    return fieldConfigs.map((config) {
      final fieldName = config['fieldName'];
      final label = config['label'];
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text:  TextSpan(
                text: label,
                style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Montserrat',
                    color: Resources.colors.appTheme.darkBlue
                ),
              ),
            ),
            ReactiveTextField<String>(
              formControlName: fieldName,
              keyboardType: TextInputType.number,
              validationMessages: {
                ValidationMessage.required: (_) =>
                'The ${label?.toLowerCase()} must not be empty'
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                suffix: fieldName=="waterTesting.waterTemperature"?Text("°C")
                    :fieldName=="waterTesting.turbidity"?Text("NTU")
                    :fieldName=="waterTesting.conductivity"?Text("µs")
                    :fieldName=="waterTesting.pH"?Text("ph")
                    :fieldName=="waterTesting.totalDissolvedSolids"?Text("ppm")
                    :Text("mg/L"),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color:Resources.colors.appTheme.darkBlue,  // Replace with your desired focus border color
                    width: 1.0,         // Replace with your desired focus border width
                  ),
                ),
                helperText: '',
                helperStyle: TextStyle(height: 0.7),
                errorStyle: TextStyle(height: 0.7),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void selectedSurrounding(String size) {
    setState(() {
      if (selectedSurroundings.contains(size)) {
        selectedSurroundings.remove(size);
      } else {
        selectedSurroundings.add(size);
      }
    });
  }

  //Navigations
  _navigateToMap() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomGoogleMap()));
    // Handle the result from the next page if needed
    if (result != null) {
      final locationName = result['locationName'];
      final lat = result['lat'];
      final lan = result['lan'];
      setState(() {
        _searchController.text=locationName;
        form.control('generalInformation.location').value=locationName;
        form.control('generalInformation.latitude').value=lat.toString();
        form.control('generalInformation.longitude').value=lan.toString();
        _steps = _generateSteps();
      });
      // Do something with the name and ID
    }
  }

  //STEPS COUNT
  List<Step> _generateSteps() {
    return List<Step>.generate(7, (int index) {
      return Step(
        state: _index>index?StepState.complete:StepState.indexed,
        title: Text(''),
        isActive: _index == index,
        content: _buildFormForStep(index),
      );
    });
  }

  //STEPS CONTENT
  _buildFormForStep(step){
    switch (step) {
      case 0:return _generalInformation();
      case 1:return _waterAndWeatherInformation();
      case 2:return _surrounding();
      case 3:return _waterQuality();
      case 4:return _floraAndFauna();
      case 5:return _otherPictures();
      case 6:return _confirmSubmit();
    }
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
      _steps=_generateSteps();
    });
  }

  Future<Map<String, dynamic>> getLocationFromPlaceId(String placeId) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$GOOGLE_MAP_API';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      form.control('generalInformation.latitude').value="${decodedData['result']['geometry']['location']['lat']}";
      form.control('generalInformation.longitude').value="${decodedData['result']['geometry']['location']['lng']}";
      return decodedData;
    } else {
      throw Exception('Failed to fetch location data');
    }
  }

  //STEP 1 : GENERAL INFORMATION
  _generalInformation (){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("General Information",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 10,),
        ReactiveForm(
          formGroup: form,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text:  TextSpan(
                      text: 'Activity Date',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                        color:  Resources.colors.appTheme.darkBlue
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
                    formControlName: 'generalInformation.activityDate',
                    controller: activityDateController,
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Required field',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            activityDateController.text =
                                selectedDate.toIso8601String().substring(0, 10);
                            form.control('generalInformation.activityDate').value=activityDateController.text;
                          }
                        },
                      ),
                      labelStyle: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),
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
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text:  TextSpan(
                      text: 'Activity Time',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Montserrat',
                          color: Resources.colors.appTheme.darkBlue
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
                    formControlName: 'generalInformation.activityTime',
                    controller: activityTimeController,
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Required field',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(Icons.schedule),
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            activityTimeController.text =
                                selectedTime.format(context);
                            form.control('generalInformation.activityTime').value=activityTimeController.text;
                          }
                        },
                      ),
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
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text:  TextSpan(
                      text: 'Tester Name',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Montserrat',
                          color: Resources.colors.appTheme.darkBlue
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
                    formControlName: 'generalInformation.testerName',
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
                      // helperText: '',
                      // helperStyle: TextStyle(height: 0.7),
                      errorStyle: TextStyle(height: 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text:  TextSpan(
                      text: 'Location',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Montserrat',
                          color: Resources.colors.appTheme.darkBlue
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
                        autofocus: true,
                        decoration:  InputDecoration(
                          border: UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.gps_fixed),
                            onPressed: () async {
                              _navigateToMap();
                            },
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color:Resources.colors.appTheme.darkBlue,  // Replace with your desired focus border color
                              width: 1.0,         // Replace with your desired focus border width
                            ),
                          ),
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        form.control('generalInformation.location').value=pattern;
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
                          form.control('generalInformation.location').value=location;
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
                          fontFamily: 'Montserrat',
                          color: Resources.colors.appTheme.darkBlue
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
                    formControlName: 'generalInformation.latitude',
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
                          fontFamily: 'Montserrat',
                          color: Resources.colors.appTheme.darkBlue
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
                    formControlName: 'generalInformation.longitude',
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
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
      ],
    );
  }

  //STEP 2 : WATER LEVEL & WEATHER
  _waterAndWeatherInformation(){
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Water Level & Weather",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 16,fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
          ReactiveForm(
            formGroup: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text:  TextSpan(
                        text: 'Measure the air temperature',
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'Montserrat',
                            color: Resources.colors.appTheme.darkBlue
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
                      formControlName: 'waterLevelAndWeather.airTemperature',
                      keyboardType: TextInputType.number,
                      validationMessages: {
                        ValidationMessage.required: (_) => 'Required field',
                      },
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        suffix: Text("°C"),
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
                    ),
                  ],
                ),
                RichText(
                  text:  TextSpan(
                    text: 'Observe the Water Level',
                    style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                        color: Resources.colors.appTheme.darkBlue
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
                Container(
                    height: 100,
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      selectedWaterLevel=WATERANDWEATHER.waterLevelLabels[Index];
                                      form.control('waterLevelAndWeather.waterLevel').value=WATERANDWEATHER.waterLevelLabels[Index];
                                      _steps = _generateSteps();
                                    });
                                  },
                                  child: SvgPicture.asset(
                                    selectedWaterLevel == WATERANDWEATHER.waterLevelLabels[Index]
                                        ? "assets/images/${WATERANDWEATHER.waterLevelSelectedIcons[Index]}"
                                        : "assets/images/${WATERANDWEATHER.waterLevelUnselectedIcons[Index]}",
                                    width: 44,
                                    height: 44,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(WATERANDWEATHER.waterLevelLabels[Index],style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),)
                              ],
                            ),
                          );
                        })),
                RichText(
                  text:  TextSpan(
                    text: 'Weather Condtions',
                    style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                        color: Resources.colors.appTheme.darkBlue
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
                Container(
                    height: 100,
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      selectedWeather=WATERANDWEATHER.weatherLabels[Index];
                                      form.control('waterLevelAndWeather.weather').value=WATERANDWEATHER.weatherLabels[Index];
                                      _steps = _generateSteps();
                                    });
                                  },
                                  child: SvgPicture.asset(
                                    selectedWeather == WATERANDWEATHER.weatherLabels[Index]
                                        ? "assets/images/${WATERANDWEATHER.weatherSelectedIcons[Index]}"
                                        : "assets/images/${WATERANDWEATHER.weatherUnselectedIcons[Index]}",
                                    width: 44,
                                    height: 44,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(WATERANDWEATHER.weatherLabels[Index],style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),)
                              ],
                            ),
                          );
                        })),
                RichText(
                  text:  TextSpan(
                    text: 'River Pictures',
                    style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                        color: Resources.colors.appTheme.darkBlue
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
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              var camOrGallery = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PictureOptions();
                  });
              if (camOrGallery.toString() == "Gallery") {
                var img = pickImages('riverPicture','Gallery');
              } else if (camOrGallery.toString() == "Camera") {
                var img = pickImages('riverPicture','Camera');
              }
            },
            child: const Text('Upload Images'),
          ),
          const SizedBox(height: 10.0),
          if (selectedRiverImages.isNotEmpty)
            Container(
                margin: EdgeInsets.symmetric( vertical: 20),
                child: Container(
                    height: 225,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedRiverImages.length,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children:[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: (MediaQuery.of(context).size.width - 30) / 2,
                                        width: (MediaQuery.of(context).size.width - 30) / 2,
                                          child: Image.file(
                                              fit: BoxFit.fill,
                                              File(selectedRiverImages[Index]!.path)
                                          )
                                      ),
                                    ),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedRiverImages.removeAt(Index);
                                                riverDescriptions.removeAt(Index);
                                                _steps = _generateSteps();
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))),
                                  ]
                                ),
                                Container(
                                    width: 170,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                       ),
                                    // padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      riverDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        border:OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.black, width: 1.0),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        })
                )
            ),
        ],
      ),
    );
  }

  //STEP 3 : OBSERVE YOUR SURROUNDINGS
  _surrounding(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Observe your Surroundings",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 10,),
        _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
        ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text:  TextSpan(
                  text: 'Surroundings',
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Montserrat',
                      color: Resources.colors.appTheme.darkBlue
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
              Wrap(
                children: WATERANDWEATHER.surroundings.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0,left: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        item,
                        style: TextStyle(
                          color: Resources.colors.appTheme.darkBlue,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Set the border radius
                        side: const BorderSide(
                          color:  Colors.grey,
                          width: 0.5, // Set the border width
                        ),
                      ),
                      selected: selectedSurroundings.contains(item),
                      selectedColor: Resources.colors.appTheme.lightTeal,
                      backgroundColor: Colors.white,
                      onSelected: (isSelected) {
                        selectedSurrounding(item);
                        setState(() {
                          _steps = _generateSteps();
                        });
                        form.control('surroundings').value=selectedSurroundings;
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              RichText(
                text:  TextSpan(
                  text: 'Surrounding Pictures',
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Montserrat',
                      color: Resources.colors.appTheme.darkBlue
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
            ],
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () async {
            var camOrGallery = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PictureOptions();
                });

            if (camOrGallery.toString() == "Gallery") {
              var img = pickImages('surroundingImages','Gallery');
            } else if (camOrGallery.toString() == "Camera") {
              var img = pickImages('surroundingImages','Camera');
            }
          },
          child: Text('Upload Images'),
        ),
        SizedBox(height: 16.0),
        if (selectedSurroundingImages.isNotEmpty)
          Container(
              margin:
              EdgeInsets.symmetric(vertical: 20),
              child: Container(
                  height: 225,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedSurroundingImages.length,
                      itemBuilder: (BuildContext ctxt, int Index) {
                        return Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                       height: (MediaQuery.of(context).size.width - 30) / 2,
                                       width: (MediaQuery.of(context).size.width - 30) / 2,
                                        child: Image.file(
                                            fit: BoxFit.fill,
                                            File(selectedSurroundingImages[Index]!.path)
                                        )
                                    ),
                                  ),
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedSurroundingImages.removeAt(Index);
                                              surroundingDescriptions.removeAt(Index);
                                              _steps = _generateSteps();
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ))),
                                ],
                              ),
                              Container(  width: 170,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                  ),
                                  child: TextFormField(
                                    autofocus: false,
                                    controller:
                                    surroundingDescriptions[Index],
                                    style: const TextStyle(fontSize: 12),
                                    decoration: const InputDecoration(
                                      border:OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                                      ),
                                      focusedBorder:OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      })
              )
          ),
      ],
    );
  }

  //STEP 4 : WATER QUALITY TESTING
  _waterQuality(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Water Quality Testing",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 10,),
        _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
        ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...waterQualityFormFields(),
              SizedBox(height: 16.0),
              RichText(
                text:  TextSpan(
                  text: "Bacteria",
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Montserrat',
                      color: Resources.colors.appTheme.darkBlue
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        _bacteriaPresent="Present";
                        form.control('waterTesting.bacteria').value=_bacteriaPresent;
                        _steps = _generateSteps();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _bacteriaPresent=="Present"?Resources.colors.appTheme.lightTeal:Colors.white,                // Background color
                        borderRadius: BorderRadius.circular(20),  // Border radius
                        border: Border.all(
                          color: Colors.grey,             // Border color
                          width: 0.5,                        // Border width
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Present'),
                      ),
                    ),
                  ),
                  SizedBox(width: 16,),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        _bacteriaPresent="Absent";
                        form.control('waterTesting.bacteria').value=_bacteriaPresent;
                        _steps = _generateSteps();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _bacteriaPresent=="Absent"?Resources.colors.appTheme.lightTeal:Colors.white,                // Background color
                        borderRadius: BorderRadius.circular(20),  // Border radius
                        border: Border.all(
                          color: Colors.grey,             // Border color
                          width: 0.5,                        // Border width
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Absent'),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ],
    );
  }

  //STEP 5 : FLORA AND FAUNA
  _floraAndFauna(){
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Flora & Fauna",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 16,fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
          RichText(
            text:  TextSpan(
              text: "Flora",
              style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'Montserrat',
                  color: Resources.colors.appTheme.darkBlue
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              var camOrGallery = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PictureOptions();
                  });

              if (camOrGallery.toString() == "Gallery") {
                var img = pickImages('flora','Gallery');
              } else if (camOrGallery.toString() == "Camera") {
                var img = pickImages('flora','Camera');
              }
            },
            child: Text('Upload Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedFloraImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(vertical: 20),
                child: Container(
                    height: 225,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedFloraImages.length,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment:Alignment.topRight,
                                  children: [
                                    Container(
                                        height: (MediaQuery.of(context).size.width - 30) / 2,
                                        width: (MediaQuery.of(context).size.width - 30) / 2,
                                        padding: EdgeInsets.all(8.0),
                                        child: Image.file(
                                            fit: BoxFit.fill,
                                            File(selectedFloraImages[Index]!.path)
                                        )
                                    ),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedFloraImages.removeAt(Index);
                                                floraDescriptions.removeAt(Index);
                                                _steps = _generateSteps();
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))),
                                  ],
                                ),
                                Container(
                                    width: 170,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      floraDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        border:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        })
                )
            ),
          RichText(
            text:  TextSpan(
              text: "Fauna",
              style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'Montserrat',
                  color: Resources.colors.appTheme.darkBlue
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              var camOrGallery = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PictureOptions();
                  });

              if (camOrGallery.toString() == "Gallery") {
                var img = pickImages('fauna','Gallery');
              } else if (camOrGallery.toString() == "Camera") {
                var img = pickImages('fauna','Camera');
              }
            },
            child: Text('Upload Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedFaunaImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(vertical: 20),
                child: Container(
                    height: 225,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedFaunaImages.length,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                        height: (MediaQuery.of(context).size.width - 30) / 2,
                                        width: (MediaQuery.of(context).size.width - 30) / 2,
                                        padding:EdgeInsets.all(8.0),
                                        child: Image.file(
                                            fit: BoxFit.fill,
                                            File(selectedFaunaImages[Index]!.path)
                                        )
                                    ),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedFaunaImages.removeAt(Index);
                                                faunaDescriptions.removeAt(Index);
                                                _steps = _generateSteps();
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))),
                                  ],
                                ),
                                Container(
                                    width: 170,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        ),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      faunaDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        border:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        })
                )
            ),
        ],
      ),
    );
  }

  //STEP 6 : FLORA AND FAUNA
  _otherPictures(){
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Water Level & Weather",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 16,fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
          RichText(
            text:  TextSpan(
              text: "Group pictures",
              style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'Montserrat',
                  color: Resources.colors.appTheme.darkBlue
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              var camOrGallery = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PictureOptions();
                  });

              if (camOrGallery.toString() == "Gallery") {
                var img = pickImages('group','Gallery');
              } else if (camOrGallery.toString() == "Camera") {
                var img = pickImages('group','Camera');
              }
            },
            child: Text('Upload Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedGroupImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(vertical: 20),
                child: Container(
                    height: 225,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedGroupImages.length,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment:Alignment.topRight,
                                  children: [
                                    Container(
                                        height: (MediaQuery.of(context).size.width - 30) / 2,
                                        width: (MediaQuery.of(context).size.width - 30) / 2,
                                        padding:EdgeInsets.all(8.0),
                                        child: Image.file(
                                            fit: BoxFit.fill,
                                            File(selectedGroupImages[Index]!.path)
                                        )
                                    ),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedGroupImages.removeAt(Index);
                                                groupImageDescriptions.removeAt(Index);
                                                _steps = _generateSteps();
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))),
                                  ],
                                ),
                                Container(    width: 170,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                       ),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      groupImageDescriptions[Index],
                                      style: const TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        border:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        })
                )
            ),
          RichText(
            text:  TextSpan(
              text: "Activity pictures",
              style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'Montserrat',
                  color: Resources.colors.appTheme.darkBlue
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              var camOrGallery = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PictureOptions();
                  });

              if (camOrGallery.toString() == "Gallery") {
                var img = pickImages('activity','Gallery');
              } else if (camOrGallery.toString() == "Camera") {
                var img = pickImages('activity','Camera');
              }
            },
            child: Text('Upload Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedActivityImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(vertical: 20),
                child: Container(
                    height: 225,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedActivityImages.length,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return Container(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                        height: (MediaQuery.of(context).size.width - 30) / 2,
                                        width: (MediaQuery.of(context).size.width - 30) / 2,
                                        padding:EdgeInsets.all(8.0),
                                        child: Image.file(
                                            fit: BoxFit.fill,
                                            File(selectedActivityImages[Index]!.path)
                                        )
                                    ),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedActivityImages.removeAt(Index);
                                                activityImageDescriptions.removeAt(Index);
                                                _steps = _generateSteps();
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))),
                                  ],
                                ),
                                Container(    width: 170,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                    ),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      activityImageDescriptions[Index],
                                      style: const TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        border:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        })
                )
            ),
          RichText(
            text:  TextSpan(
              text: "Artworks",
              style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'Montserrat',
                  color: Resources.colors.appTheme.darkBlue
              ),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              var camOrGallery = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PictureOptions();
                  });

              if (camOrGallery.toString() == "Gallery") {
                var img = pickImages('artwork','Gallery');
              } else if (camOrGallery.toString() == "Camera") {
                var img = pickImages('artwork','Camera');
              }
            },
            child: Text('Upload Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedArtworkImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(vertical: 20),
                child: Container(
                    height: 225,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedArtworkImages.length,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                        height: (MediaQuery.of(context).size.width - 30) / 2,
                                        width: (MediaQuery.of(context).size.width - 30) / 2,
                                        padding:EdgeInsets.all(8.0),
                                        child: Image.file(
                                            fit: BoxFit.fill,
                                            File(selectedArtworkImages[Index]!.path)
                                        )
                                    ),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedArtworkImages.removeAt(Index);
                                                artworkDescriptions.removeAt(Index);
                                                _steps = _generateSteps();
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))),
                                  ],
                                ),
                                Container(    width: 170,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                       ),

                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      artworkDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                        border:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        })
                )
            ),
        ],
      ),
    );
  }

  //STEP 7 : CONFIRM SUBMIT
  _confirmSubmit(){
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text("Preview before submit",
                style: TextStyle(
                    color: Resources.colors.appTheme.darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Container(
              margin:
              EdgeInsets.symmetric(vertical: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF1C3764),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(bottom: 5),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            "General Information",
                            style: TextStyle(
                                color: Color(
                                  0xFF1C3764,
                                )),
                          ),
                          InkWell(
                              onTap: () {
                                // _controller.jumpToPage(1);
                              },
                              child: const Icon(Icons.mode_edit,
                                  color: Color(0xFF1C3764), size: 20)),
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Activity Date",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('generalInformation.activityDate').value ?? ''}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Activity Time",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text("${form.control('generalInformation.activityTime').value ?? ''}",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Location",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(' ${form.control('generalInformation.location').value ?? ''}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Name",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(' ${form.control('generalInformation.testerName').value ?? ''}',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Latitude",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text( '${form.control('generalInformation.latitude').value ?? ''}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Longitude",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(' ${form.control('generalInformation.longitude').value ?? ''}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
              margin:
              const EdgeInsets.symmetric(vertical: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF1C3764),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(bottom: 5),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            "Water Level & Weather",
                            style: TextStyle(
                                color: Color(
                                  0xFF1C3764,
                                )),
                          ),
                          InkWell(
                              onTap: () {
                                // _controller.jumpToPage(2);
                              },
                              child: const Icon(Icons.mode_edit,
                                  color: Color(0xFF1C3764), size: 20)),
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Weather",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterLevelAndWeather.weather').value ?? ''}',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Air Temperatue",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      '${form.control('waterLevelAndWeather.airTemperature').value ?? ''}' + " °C",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Water Level",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterLevelAndWeather.waterLevel').value ?? ''}',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight:
                                          FontWeight.bold))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
              margin:
              const EdgeInsets.symmetric( vertical: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF1C3764),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            "Water Quality Testing",
                            style: TextStyle(
                                color: Color(
                                  0xFF1C3764,
                                )),
                          ),
                          InkWell(
                              onTap: () {
                                // _controller.jumpToPage(4);
                              },
                              child: Icon(Icons.mode_edit,
                                  color: Color(0xFF1C3764), size: 20)),
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Water Temperature",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.waterTemperature').value!=null?
                                    Text('${form.control('waterTesting.waterTemperature').value }' + " °C",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("pH",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.pH').value!=null?
                                      Text(' ${form.control('waterTesting.pH').value}' + " ph",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.pH').value)>=6.5&&double.parse(form.control('waterTesting.pH').value)<=8.5
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.pH').value)<6.5||double.parse(form.control('waterTesting.pH').value)>8.5
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Alkalinity",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.alkalinity').value!=null?
                                  Text('${form.control('waterTesting.alkalinity').value}' + " mg/L",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.alkalinity').value)>=20&&double.parse(form.control('waterTesting.alkalinity').value)<=250
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.alkalinity').value)<20||double.parse(form.control('waterTesting.alkalinity').value)>250
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight:
                                          FontWeight.bold))
                                      :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Nitrate",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.nitrate').value!=null?
                                  Text('${form.control('waterTesting.nitrate').value}' + " mg/L",
                                      style:  TextStyle(
                                          color: int.parse(form.control('waterTesting.nitrate').value)<=1
                                              ?Colors.green
                                              :int.parse(form.control('waterTesting.nitrate').value)>1
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Nitrite",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child:form.control('waterTesting.nitrite').value!=null?
                                  Text('${form.control('waterTesting.nitrite').value}' + " mg/L",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.nitrite').value)<=1
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.nitrite').value)>1
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Hardness",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.hardness').value!=null?
                                  Text('${form.control('waterTesting.hardness').value }' + " mg/L",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Chlorine",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.chlorine').value!=null?
                                  Text('${form.control('waterTesting.chlorine').value}' + " mg/L",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.chlorine').value)>=0.2&&double.parse(form.control('waterTesting.chlorine').value)<=1.0
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.chlorine').value)<0.2||double.parse(form.control('waterTesting.chlorine').value)>1.0
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Iron",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.iron').value!=null?
                                  Text('${form.control('waterTesting.iron').value }' + " mg/L",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.iron').value)>=0.2&&double.parse(form.control('waterTesting.iron').value)<=2.0
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.iron').value)<0.2||double.parse(form.control('waterTesting.iron').value)>2.0
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Dissolved oxygen",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.dissolvedOxygen').value!=null?
                                  Text(
                                      '${form.control('waterTesting.dissolvedOxygen').value ?? ''}' + " mg/L",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.dissolvedOxygen').value)>=4.0&&double.parse(form.control('waterTesting.dissolvedOxygen').value)<=20.0
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.dissolvedOxygen').value)<4.0||double.parse(form.control('waterTesting.dissolvedOxygen').value)>20.0
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text(
                                      "E Coli/Coliform Bacteria",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.bacteria').value!=null?
                                  Text(
                                      '${form.control('waterTesting.bacteria').value}' + " ",
                                      style: TextStyle(
                                          color: form.control('waterTesting.bacteria').value=="Absent"
                                              ?Colors.green
                                              :form.control('waterTesting.bacteria').value=="Present"
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Turbidity",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.turbidity').value!=null?
                                  Text('${form.control('waterTesting.turbidity').value}' + " NTU",
                                      style: TextStyle(
                                          color: int.parse(form.control('waterTesting.turbidity').value)<=15000
                                              ?Colors.green
                                              :int.parse(form.control('waterTesting.turbidity').value)>15000
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Phosphate",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.phosphate').value!=null?
                                  Text('${form.control('waterTesting.phosphate').value }' + " mg/L",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.phosphate').value)<=0.1
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.phosphate').value)>0.1
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Ammonia",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child:form.control('waterTesting.ammonia').value!=null?
                                  Text('${form.control('waterTesting.ammonia').value }' + " mg/L",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.ammonia').value)>=0.2&&double.parse(form.control('waterTesting.ammonia').value)<=1.2
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.ammonia').value)<0.2||double.parse(form.control('waterTesting.ammonia').value)>1.2
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Lead",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.lead').value!=null?
                                  Text('${form.control('waterTesting.lead').value}' + " mg/L",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.lead').value)==0
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.lead').value)>0
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Total Dissolved Solids",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.totalDissolvedSolids').value!=null?
                                  Text('${form.control('waterTesting.totalDissolvedSolids').value}' + " ppm",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.totalDissolvedSolids').value)<900
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.totalDissolvedSolids').value)>=900
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text("Conductivity",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.conductivity').value!=null?
                                  Text('${form.control('waterTesting.conductivity').value }' + " µs",
                                      style: TextStyle(
                                          color: double.parse(form.control('waterTesting.conductivity').value)<1000&&double.parse(form.control('waterTesting.conductivity').value)>10000
                                              ?Colors.green
                                              :double.parse(form.control('waterTesting.conductivity').value)>=1000||double.parse(form.control('waterTesting.conductivity').value)<=10000
                                              ?Colors.red
                                              :Colors.black,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "Montserrat",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Container(
              margin:
              EdgeInsets.symmetric( vertical: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF1C3764),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(bottom: 5),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            "Rivers",
                            style: TextStyle(
                                color: Color(
                                  0xFF1C3764,
                                )),
                          ),
                          InkWell(
                              onTap: () {
                                // _controller.jumpToPage(2);
                              },
                              child: const Icon(Icons.mode_edit,
                                  color: Color(0xFF1C3764), size: 20)),
                        ],
                      )),
                  if (selectedRiverImages.length > 0)
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Container(
                            height: 150,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedRiverImages.length,
                                itemBuilder:
                                    (BuildContext ctxt, int Index) {
                                  return Container(
                                    height: (MediaQuery.of(context).size.width - 30) / 2,
                                    width: (MediaQuery.of(context).size.width - 30) / 2,
                                    padding: const EdgeInsets.only(
                                        bottom: 10, left: 5),
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      children: [
                                        Container(
                                            width:120,
                                            height:80,
                                            child: Image.file(
                                                fit: BoxFit.fill,
                                                File(selectedRiverImages[Index]!.path)
                                            )
                                        ),
                                        SizedBox(height:20),
                                        Container(
                                          height: 30,
                                          child: TextFormField(
                                            controller:
                                            riverDescriptions[Index],
                                            style:
                                            const TextStyle(fontSize: 12),
                                            readOnly:true,
                                            decoration: const InputDecoration(
                                              border:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                              focusedBorder:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))),
                ],
              )),
          Container(
              margin: const EdgeInsets.symmetric( vertical: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF1C3764),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(bottom: 5),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            "Surroundings",
                            style: TextStyle(
                                color: Color(
                                  0xFF1C3764,
                                )),
                          ),
                          InkWell(
                              onTap: () {
                                // _controller.jumpToPage(3);
                              },
                              child: const Icon(Icons.mode_edit,
                                  color: Color(0xFF1C3764), size: 20)),
                        ],
                      )),
                  if (selectedSurroundingImages.length > 0)
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Container(
                            height: 150,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedSurroundingImages.length,
                                itemBuilder:
                                    (BuildContext ctxt, int Index) {
                                  return Container(    margin: EdgeInsets.only(right: 10),
                                    height: (MediaQuery.of(context)
                                        .size
                                        .width -
                                        30) /
                                        2,
                                    width: (MediaQuery.of(context)
                                        .size
                                        .width -
                                        30) /
                                        2,
                                    padding: const EdgeInsets.only(
                                        bottom: 10, left: 5),
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      children: [
                                        Container(
                                            width:100,
                                            height:80,
                                            child: Image.file(
                                                fit: BoxFit.fill,
                                                File(selectedSurroundingImages[Index]!.path)
                                            )
                                        ),
                                        SizedBox(height: 20,),
                                        Container(
                                          height:30,
                                          child: TextFormField(
                                            controller:
                                            surroundingDescriptions[
                                            Index],
                                            style:
                                            TextStyle(fontSize: 12),
                                            readOnly:true,
                                            decoration: const InputDecoration(
                                              border:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                              focusedBorder:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))),
                ],
              )),
          Container(
              margin: const EdgeInsets.symmetric( vertical: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF1C3764),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(bottom: 5),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            "Flora & Fauna",
                            style: TextStyle(
                                color: Color(
                                  0xFF1C3764,
                                )),
                          ),
                          InkWell(
                              onTap: () {
                                // _controller.jumpToPage(5);
                              },
                              child: Icon(Icons.mode_edit,
                                  color: Color(0xFF1C3764), size: 20)),
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(
                                bottom: 5,
                              ),
                              child: SvgPicture.asset(
                                "assets/images/Flora-1.svg",
                                width: 30,
                                height: 30,
                              ),
                            ),
                            Container(padding: const EdgeInsets.only(
                              left: 10,
                              bottom: 5,
                            ),
                                child: const Text(
                                  "Flora",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1C3764),
                                      fontWeight: FontWeight.w900),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selectedFloraImages.length > 0)
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Container(
                            height: 150,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedFloraImages.length,
                                itemBuilder:
                                    (BuildContext ctxt, int Index) {
                                  return Container(    margin: EdgeInsets.only(right: 10),
                                    height: (MediaQuery.of(context)
                                        .size
                                        .width -
                                        30) /
                                        2,
                                    width: (MediaQuery.of(context)
                                        .size
                                        .width -
                                        30) /
                                        2,
                                    padding: EdgeInsets.only(
                                        bottom: 10, left: 5),
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      children: [
                                        Container(
                                            width:100,
                                            height:80,
                                            child: Image.file(
                                                fit: BoxFit.fill,
                                                File(selectedFloraImages[Index]!.path)
                                            )
                                        ),
                                        SizedBox(height: 20,),
                                        Container(
                                          height:30,
                                          child: TextFormField(
                                            controller:
                                            floraDescriptions[
                                            Index],
                                            style:
                                            TextStyle(fontSize: 12),
                                            readOnly:true,
                                            decoration: const InputDecoration(
                                              border:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                              focusedBorder:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                          left: 10,
                          bottom: 5,
                          top: 20,
                        ),
                        child: SvgPicture.asset(
                          "assets/images/Fauna-1.svg",
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(
                            top: 20,
                            left: 10,
                            bottom: 5,
                          ),
                          child: const Text(
                            "Fauna",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1C3764),
                                fontWeight: FontWeight.w900),
                          )),
                    ],
                  ),
                  if (selectedFaunaImages.length > 0)
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Container(
                            height: 150,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedFaunaImages.length,
                                itemBuilder:
                                    (BuildContext ctxt, int Index) {
                                  return Container(    margin: EdgeInsets.only(right: 10),
                                    height: (MediaQuery.of(context)
                                        .size
                                        .width -
                                        30) /
                                        2,
                                    width: (MediaQuery.of(context)
                                        .size
                                        .width -
                                        30) /
                                        2,
                                    padding: EdgeInsets.only(
                                        bottom: 10, left: 5),
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      children: [
                                        Container(
                                            width:100,
                                            height:80,
                                            child: Image.file(
                                                fit: BoxFit.fill,
                                                File(selectedFaunaImages[Index]!.path)
                                            )
                                        ),
                                        SizedBox(height: 20,),
                                        Container(
                                          height:30,
                                          child: TextFormField(
                                            controller:
                                            faunaDescriptions[
                                            Index],
                                            style:
                                            TextStyle(fontSize: 12),
                                            readOnly:true,
                                            decoration: const InputDecoration(
                                              border:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                              focusedBorder:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))),
                ],
              )),
          Container(
              margin: EdgeInsets.symmetric( vertical: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFF1C3764),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(bottom: 5),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            "Pictures",
                            style: TextStyle(
                                color: Color(
                                  0xFF1C3764,
                                )),
                          ),
                          InkWell(
                              onTap: () {
                                // _controller.jumpToPage(6);
                              },
                              child: Icon(Icons.mode_edit,
                                  color: Color(0xFF1C3764), size: 20)),
                        ],
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: SvgPicture.asset(
                          "assets/images/Flora-1.svg",
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(
                            left: 10,
                            bottom: 5,
                          ),
                          child: const Text(
                            "Groups",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1C3764),
                                fontWeight: FontWeight.w900),
                          )),
                    ],
                  ),
                  if (selectedGroupImages.length > 0)
                    Container(
                        margin:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Container(
                            height: 150,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedGroupImages.length,
                                itemBuilder: (BuildContext ctxt, int Index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 10),
                                    height: (MediaQuery.of(context).size.width -
                                        30) /
                                        2,
                                    width: (MediaQuery.of(context).size.width -
                                        30) /
                                        2,
                                    padding:
                                    EdgeInsets.only(bottom: 10, left: 5),
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      children: [
                                        Container(
                                            width:100,
                                            height:80,
                                            child: Image.file(
                                                fit: BoxFit.fill,
                                                File(selectedGroupImages[Index]!.path)
                                            )
                                        ),
                                        SizedBox(height: 20,),
                                        Container(
                                          height:30,
                                          child: TextFormField(
                                            controller:
                                            groupImageDescriptions[Index],
                                            style: TextStyle(fontSize: 12),
                                            readOnly:true,
                                            decoration: const InputDecoration(
                                              border:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                              focusedBorder:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 2.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: SvgPicture.asset(
                          "assets/images/Flora-1.svg",
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(
                            left: 10,
                            bottom: 5,
                          ),
                          child: const Text(
                            "Activities",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1C3764),
                                fontWeight: FontWeight.w900),
                          )),
                    ],
                  ),
                  if (selectedActivityImages.length > 0)
                    Container(
                        margin:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Container(
                            height: 150,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedActivityImages.length,
                                itemBuilder: (BuildContext ctxt, int Index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 10),
                                    height: (MediaQuery.of(context).size.width -
                                        30) /
                                        2,
                                    width: (MediaQuery.of(context).size.width -
                                        30) /
                                        2,
                                    padding:
                                    EdgeInsets.only(bottom: 10, left: 5),
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      children: [
                                        Container(
                                            width:100,
                                            height:80,
                                            child: Image.file(
                                                fit: BoxFit.fill,
                                                File(selectedActivityImages[Index]!.path)
                                            )
                                        ),
                                        SizedBox(height: 20,),
                                        Container(
                                          height:30,
                                          child: TextFormField(
                                            controller:
                                            activityImageDescriptions[Index],
                                            style: TextStyle(fontSize: 12),
                                            readOnly:true,
                                            decoration: const InputDecoration(
                                              border:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                              focusedBorder:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: SvgPicture.asset(
                          "assets/images/Flora-1.svg",
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.only(
                            left: 10,
                            bottom: 5,
                          ),
                          child: const Text(
                            "Artworks",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1C3764),
                                fontWeight: FontWeight.w900),
                          )),
                    ],
                  ),
                  if (selectedArtworkImages.length > 0)
                    Container(
                        margin:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Container(
                            height: 150,
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedArtworkImages.length,
                                itemBuilder: (BuildContext ctxt, int Index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 10),
                                    height: (MediaQuery.of(context).size.width -
                                        30) /
                                        2,
                                    width: (MediaQuery.of(context).size.width -
                                        30) /
                                        2,
                                    padding:
                                    EdgeInsets.only(bottom: 10, left: 5),
                                    alignment: Alignment.bottomLeft,
                                    child: Column(
                                      children: [
                                        Container(
                                            width:100,
                                            height:80,
                                            child: Image.file(
                                                fit: BoxFit.fill,
                                                File(selectedArtworkImages[Index]!.path)
                                            )
                                        ),
                                        SizedBox(height: 20,),
                                        Container(
                                          height:30,
                                          child: TextFormField(
                                            controller:
                                            artworkDescriptions[Index],
                                            style: const TextStyle(fontSize: 12),
                                            readOnly:true,
                                            decoration: const InputDecoration(
                                              border:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                              focusedBorder:OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }))),
                ],
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monitor River"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children:[
          Stepper(
          elevation: 0,
          type:StepperType.horizontal,
          currentStep: _index,
          onStepTapped: (int index) {
            // setState(() {
            //   _index = index;
            //   _steps = _generateSteps();
            // });
            if (steps[_index]!='flora'&&steps[_index]!='waterLevelAndWeather'&&steps[_index]!='preview'&&form.control(steps[_index]).runtimeType==FormGroup&&form.control(steps[_index]).valid) {
              setState(() {
                _error=false;
                _index = index;
                _steps = _generateSteps();
              });
            }
            else if(steps[_index]=="waterLevelAndWeather"){
              if(form.control(steps[_index]).valid&&selectedRiverImages.length>0){
                setState(() {
                  _index = index;
                  _error=false;
                  _steps = _generateSteps();
                });
              }
              else{
                setState(() {
                  _error=true;
                  _steps = _generateSteps();
                });
              }
            }
            else if (steps[_index]!='flora'&&steps[_index]!='preview'&&form.control(steps[_index]).runtimeType!=FormGroup&&((form.value['surroundings'] as List<String>).isNotEmpty&&selectedSurroundingImages.length!=0)) {
              setState(() {
                _index = index;
                _error=false;
                _steps = _generateSteps();
              });
            }
            else if (steps[_index]=='flora'||steps[_index]=='preview') {
              setState(() {
                _index = index;
                _error=false;
                _steps = _generateSteps();
              });
            }
            else {
              setState(() {
                _error=true;
                _steps = _generateSteps();
              });
              form.control(steps[_index]).markAllAsTouched();
            }
          },
          steps:_steps,
          controlsBuilder:(onStepContinue,onStepCancel){
            return _index == _steps.length - 1?
            Row(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Resources.colors.appTheme.darkBlue),
                  ),
                  onPressed: () async {
                    for(int i=0;i<selectedRiverImages.length;i++){
                      riverImgObj.add({
                        "imageURL":"",
                        "fileName":path.basename(selectedRiverImages[i].path),
                        "description":riverDescriptions[i].text
                      });
                    }
                    for(int i=0;i<selectedSurroundingImages.length;i++){
                      surroundingImgObj.add({
                        "imageURL":"",
                        "fileName":path.basename(selectedSurroundingImages[i].path),
                        "description":surroundingDescriptions[i].text
                      });
                    }
                    for(int i=0;i<selectedFloraImages.length;i++){
                      floraImgObj.add({
                        "imageURL":"",
                        "fileName":path.basename(selectedFloraImages[i].path),
                        "description":floraDescriptions[i].text
                      });
                    }
                    for(int i=0;i<selectedFaunaImages.length;i++){
                      faunaDescriptions.add({
                        "imageURL":"",
                        "fileName":path.basename(selectedFaunaImages[i].path),
                        "description":faunaDescriptions[i].text
                      });
                    }
                    for(int i=0;i<selectedGroupImages.length;i++){
                      groupImgObj.add({
                        "imageURL":"",
                        "fileName":path.basename(selectedFaunaImages[i].path),
                        "description":groupImageDescriptions[i].text
                      });
                    }
                    for(int i=0;i<selectedActivityImages.length;i++){
                      activityImgObj.add({
                        "imageURL":"",
                        "fileName":path.basename(selectedActivityImages[i].path),
                        "description":activityImageDescriptions[i].text
                      });
                    }
                    for(int i=0;i<selectedArtworkImages.length;i++){
                      artwrokImgObj.add({
                        "imageURL":"",
                        "fileName":path.basename(selectedArtworkImages[i].path),
                        "description":artworkDescriptions[i].text
                      });
                    }
                    form.control('riverPictures').value=riverImgObj;
                    form.control('surroundingPictures').value=surroundingImgObj;
                    form.control('floraPictures').value=floraImgObj;
                    form.control('faunaPictures').value=faunaImgObj;
                    form.control('groupPictures').value=groupImgObj;
                    form.control('activityPictures').value=activityImgObj;
                    form.control('artworkPictures').value=artwrokImgObj;
                    // var newMap = new Map(Object.entries(form.value));

                    var _isSubmitted1=true;
                    setState(() {
                      _isSubmitted=true;
                    });
                    _waterTestDetail.createWaterTestDetail(
                        form.value,
                        selectedRiverImages,
                        selectedSurroundingImages,
                        selectedFaunaImages,
                        selectedFloraImages,
                        selectedArtworkImages,
                        selectedActivityImages,
                        selectedGroupImages,
                        context);
                    setState(() {
                      _isSubmitted==false;
                      _steps = _generateSteps();
                    });
                  },
                  child: _isSubmitted?Text('Creating'):Text("Save"),
                ),
              ],
            ):
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _index>0?
                Row(
                  children: [
                    TextButton(
                      onPressed: (){
                        if (_index > 0) {
                          setState(() {
                            _index -= 1;
                            _steps = _generateSteps();
                          });
                        }
                      },
                      child: Text('Previous'),
                    ),
                    SizedBox(width: 16),
                  ],
                ):
                SizedBox(),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Resources.colors.appTheme.darkBlue),
                  ),
                  onPressed: (){

                    if (this._formKey.currentState!.validate()&&steps[_index]!='flora'&&steps[_index]!='waterLevelAndWeather'&&steps[_index]!='preview'&&form.control(steps[_index]).runtimeType==FormGroup&&form.control(steps[_index]).valid) {
                      setState(() {
                        _index++;
                        _error=false;
                        _steps = _generateSteps();
                      });
                    }
                    else if(steps[_index]=="waterLevelAndWeather"){
                      if(form.control(steps[_index]).valid&&selectedRiverImages.length>0){
                        setState(() {
                          _index++;
                          _error=false;
                          _steps = _generateSteps();
                        });
                      }
                      else{
                        setState(() {
                          _error=true;
                          _steps = _generateSteps();
                        });
                      }
                    }
                    else if (steps[_index]!='flora'&&steps[_index]!='preview'&&form.control(steps[_index]).runtimeType!=FormGroup&&((form.value['surroundings'] as List<String>).isNotEmpty&&selectedSurroundingImages.length!=0)) {
                      setState(() {
                        _index++;
                        _error=false;
                        _steps = _generateSteps();
                      });
                    }
                    else if (steps[_index]=='flora'||steps[_index]=='preview') {
                      setState(() {
                        _index++;
                        _error=false;
                        _steps = _generateSteps();
                      });
                    }
                    else {
                      setState(() {
                        _error=true;
                        _autoValidate = true;
                        _steps = _generateSteps();
                      });
                      form.control(steps[_index]).markAllAsTouched();
                    }
                  },
                  child: Text('Next'),
                ),
              ],
            );
          },
        ),
          if(_isSubmitted)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          if(_isSubmitted)
          CircularProgressIndicator()
        ],
      ),
    );
  }
}

