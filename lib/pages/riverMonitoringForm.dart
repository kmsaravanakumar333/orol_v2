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
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';




class RiverMonitoringForm extends StatefulWidget {
  String mode;
  String id;
  RiverMonitoringForm({Key? key, required this.mode, required this.id}) : super(key: key);

  @override
  State<RiverMonitoringForm> createState() => _RiverMonitoringFormState();
}

class _RiverMonitoringFormState extends State<RiverMonitoringForm> {
  int _index = 0;
  List<Step> _steps=[];
  bool _error=false;
  bool _isSubmitted=false;
  bool isOthersSelected = false;
  bool isLoading = false;
  List updatedSurroundings = [];
  TextEditingController additionalDetailsController = TextEditingController();
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
  List selectedSurroundings = [];
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
  var generalInformation;
  var waterLevelAndWeather;
  var surroundings;
  var waterTesting;
  var riverPictures;
  var surroundingPictures;
  var floraPictures;
  var faunaPictures;
  var groupPictures;
  var artworkPictures;
  var activityPictures;

  var riverImg=[];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
    setState(() {
      isLoading=true;
    });
    _waterTestDetail = (await AppSharedPreference().getRiverMonitoringInfo())! ;
    generalInformation=_waterTestDetail.generalInformation;
    waterLevelAndWeather=_waterTestDetail.waterLevelAndWeather;
    riverPictures=_waterTestDetail.riverPictures;
    surroundingPictures=_waterTestDetail.surroundingPictures;
    surroundings=_waterTestDetail.surroundings;
    floraPictures=_waterTestDetail.floraPictures;
    faunaPictures=_waterTestDetail.faunaPictures;
    groupPictures=_waterTestDetail.groupPictures;
    artworkPictures=_waterTestDetail.artworkPictures;
    activityPictures=_waterTestDetail.activityPictures;
    waterTesting=_waterTestDetail.waterTesting;
    setForm();
    setState(() {
      isLoading=false;
    });
  }
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
      'waterLevel': FormControl<String>(value:'',validators: [Validators.required]),
      'weather': FormControl<String>(validators: [Validators.required]),
    }),
    'surroundings':  FormControl<List>(value:[],validators: [Validators.required]),
    'waterTesting': fb.group({
      'alkalinity': FormControl<String>( ),
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

  setForm(){
    form.control('generalInformation.activityDate').value=generalInformation['activityDate'];
    form.control('generalInformation.activityTime').value=generalInformation['activityTime'];
    form.control('generalInformation.latitude').value=generalInformation['latitude'];
    form.control('generalInformation.longitude').value=generalInformation['longitude'];
    form.control('generalInformation.location').value=generalInformation['location'];
    form.control('generalInformation.testerName').value=generalInformation['testerName'];
    form.control('waterLevelAndWeather.airTemperature').value=waterLevelAndWeather['airTemperature'];
    form.control('waterLevelAndWeather.waterLevel').value=waterLevelAndWeather['waterLevel'];
    selectedWaterLevel = waterLevelAndWeather['waterLevel'];
    form.control('waterLevelAndWeather.weather').value=waterLevelAndWeather['weather'];
    selectedWeather = waterLevelAndWeather['weather'];
    // form.control('riverPictures').value= riverPictures[0]['imageURL'];
    // selectedSurroundings = ['surroundings'];
    // selectedRiverImages = riverPictures[0]['imageURL'];
    // selectedSurroundingImages = ['surroundingPictures'];
    // selectedFaunaImages = ['floraPictures'];
    // selectedFloraImages = ['faunaPictures'];
    // selectedArtworkImages = ['groupPictures'];
    // selectedActivityImages = ['activityPictures'];
    // selectedGroupImages = ['artworkPictures'];
    for (var i=0;i<riverPictures.length;i++){
      riverImg.add(riverPictures[i]['imageURL']);
      selectedRiverImages.add(riverPictures[i]['imageURL']);
    }
    form.control('waterTesting.alkalinity').value=waterTesting['alkalinity'];
    form.control('waterTesting.ammonia').value=waterTesting['ammonia'];
    form.control('waterTesting.bacteria').value=waterTesting['bacteria'];
    _bacteriaPresent = waterTesting['bacteria'];
    form.control('waterTesting.chlorine').value=waterTesting['alkalinity'];
    form.control('waterTesting.dissolvedOxygen').value=waterTesting['dissolvedOxygen'];
    form.control('waterTesting.hardness').value=waterTesting['hardness'];
    form.control('waterTesting.iron').value=waterTesting['iron'];
    form.control('waterTesting.lead').value=waterTesting['lead'];
    form.control('waterTesting.nitrate').value=waterTesting['nitrate'];
    form.control('waterTesting.nitrite').value=waterTesting['nitrite'];
    form.control('waterTesting.pH').value=waterTesting['pH'];
    form.control('waterTesting.phosphate').value=waterTesting['phosphate'];
    form.control('waterTesting.turbidity').value=waterTesting['turbidity'];
    form.control('waterTesting.waterTemperature').value=waterTesting['waterTemperature'];
    form.control('waterTesting.totalDissolvedSolids').value=waterTesting['totalDissolvedSolids'];
    form.control('waterTesting.conductivity').value=waterTesting['conductivity'];
    form.control('surroundings').value=surroundings;
    selectedSurroundings=surroundings;
  }
  _getCurrentLocation()async{
    try {
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
        _searchController.text= locationName.toString();
        form.control('generalInformation.location').value= locationName.toString();
        form.control('generalInformation.latitude').value=position.latitude.toString();
        form.control('generalInformation.longitude').value=position.longitude.toString();
      });
      return locationName;
    } catch (e) {
      print('Error: $e');
      return null;
    }
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

    final tempDir = await getTemporaryDirectory();
    final compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.path,
      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      minWidth: 230,
      minHeight: 150,
      quality: 75,
    );

    if (compressedImageFile == null) return;
    setState(() {
      // Image.file(File(image!.path));
      File file = File(compressedImageFile.path);
      if(name=='riverPicture'){
        // if(selectedRiverImages[0].runtimeType == String){
        //   selectedRiverImages.removeAt(0);
        // }
        // selectedRiverImages.add(compressedImageFile);
        // riverDescriptions.add(TextEditingController());
        // _steps = _generateSteps();
        selectedRiverImages.add(compressedImageFile);
        _steps = _generateSteps();
        riverDescriptions.add(TextEditingController());
        _steps = _generateSteps();
        if(widget.mode!="add"){
          if(selectedRiverImages[0].runtimeType==String){
            selectedRiverImages.removeAt(0);
            _steps = _generateSteps();
          }
        }
      }
      else if(name=='surroundingImages'){
        selectedSurroundingImages.add(compressedImageFile);
        surroundingDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='flora'){
        selectedFloraImages.add(compressedImageFile);
        floraDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='fauna'){
        selectedFaunaImages.add(compressedImageFile);
        faunaDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='group'){
        selectedGroupImages.add(compressedImageFile);
        groupImageDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='activity'){
        selectedActivityImages.add(compressedImageFile);
        activityImageDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
      else if(name=='artwork'){
        selectedArtworkImages.add(compressedImageFile);
        artworkDescriptions.add(TextEditingController());
        _steps = _generateSteps();
      }
    });
  }
  //FORM

  final steps = ['generalInformation', 'waterLevelAndWeather','surroundings','waterTesting','flora','preview'];



  final List<Map<String, String>> fieldConfigs = [
    {'fieldName': 'waterTesting.waterTemperature', 'label': 'Water Temperatures'},
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
                    fontFamily: 'WorkSans',
                    color: Resources.colors.appTheme.lable
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
                    :fieldName=="waterTesting.pH"?Text("°C")
                    :fieldName=="waterTesting.totalDissolvedSolids"?Text("ppm")
                    :fieldName=="waterTesting.alkalinity"?Text("°C")
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
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: 'WorkSans',
                color: Resources.colors.appTheme.veryDarkGray,
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
  // _navigateToMap() async {
  //   final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => CustomGoogleMap()));
  //   // Handle the result from the next page if needed
  //   if (result != null) {
  //     final locationName = result['locationName'];
  //     final lat = result['lat'];
  //     final lan = result['lan'];
  //     setState(() {
  //       _searchController.text=locationName;
  //       form.control('generalInformation.location').value=locationName;
  //       form.control('generalInformation.latitude').value=lat.toString();
  //       form.control('generalInformation.longitude').value=lan.toString();
  //       _steps = _generateSteps();
  //     });
  //     // Do something with the name and ID
  //   }
  // }

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
                        fontFamily: 'WorkSans',
                        color:  Resources.colors.appTheme.lable
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
                        icon: Icon(
                          Icons.calendar_today,
                          color: Resources.colors.appTheme.blue,// Set the color you want here
                        ),
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
                          color:Resources.colors.appTheme.lable,  // Replace with your desired focus border color
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
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text:  TextSpan(
                      text: 'Activity Time',
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
                    formControlName: 'generalInformation.activityTime',
                    controller: activityTimeController,
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Required field',
                    },
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.schedule,
                          color: Resources.colors.appTheme.blue,// Set the color you want here
                        ),
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
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'WorkSans',
                      color: Resources.colors.appTheme.veryDarkGray,
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
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'WorkSans',
                      color: Resources.colors.appTheme.veryDarkGray,
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
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'WorkSans',
                      color: Resources.colors.appTheme.veryDarkGray,
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
      child: isLoading?CircularProgressIndicator():Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Water Level & Weather",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 16,fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
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
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'WorkSans',
                        color: Resources.colors.appTheme.veryDarkGray,
                      ),
                    ),
                  ],
                ),
                _error==true?const Text("This field is required",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
                RichText(
                  text:  TextSpan(
                    text: 'Observe the Water Level',
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
                                Text(WATERANDWEATHER.waterLevelLabels[Index],style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12, fontWeight:   selectedWaterLevel == WATERANDWEATHER.waterLevelLabels[Index]? FontWeight.w500: FontWeight.w400),)
                              ],
                            ),
                          );
                        })),
                RichText(
                  text:  TextSpan(
                    text: 'Weather Condtions',
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
                                Text(WATERANDWEATHER.weatherLabels[Index],style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12, fontWeight: selectedWeather == WATERANDWEATHER.weatherLabels[Index]? FontWeight.w500: FontWeight.w400),)
                              ],
                            ),
                          );
                        })),
                RichText(
                  text:  TextSpan(
                    text: 'River Pictures',
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
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
            child: const Text(
              'Upload Images',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          _error==true?const Text("This image is required",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
          if (riverPictures != null && riverPictures.isNotEmpty)
            Container(
              height: 255,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: riverPictures.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: (MediaQuery.of(context).size.width - 100) /1.6,
                        // width: (MediaQuery.of(context).size.width - 30) / 2,
                        child:  Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(riverPictures[index]['imageURL']),
                            IconButton(onPressed: (){
                              setState(() {
                                riverPictures.removeAt(index);
                                selectedRiverImages.removeAt(index);
                                _steps = _generateSteps();
                              });
                            }, icon: Icon(Icons.delete,color: Colors.red,),),
                          ],
                        )
                    ),
                  );
                },
              ),
            ),
          if (selectedRiverImages.isNotEmpty && selectedRiverImages[0].runtimeType!=String)
            Container(
                margin: EdgeInsets.symmetric( vertical: 20),
                child: Container(
                    height: 255,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedRiverImages.length,
                        itemBuilder: (BuildContext ctxt, int Index) {
                          return SingleChildScrollView(
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(color: Colors.white),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children:[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: (MediaQuery.of(context).size.width - 100) /1.6,
                                            // width: (MediaQuery.of(context).size.width - 30) / 2,
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
                                  ),
                                  RichText(
                              text:  TextSpan(
                                text: 'Description',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontFamily: 'WorkSans',
                                    color: Resources.colors.appTheme.lable
                                ),
                                // children: const [
                                //   TextSpan(
                                //     text: ' *',
                                //     style: TextStyle(
                                //       fontSize: 16.0,
                                //       color: Colors.red,
                                //     ),
                                //   ),
                                // ],
                              ),
                          ),
                                  SizedBox(height: 5,),
                                  Container(
                                      width: 170,
                                      height: 50,
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
    return SingleChildScrollView(
      child: isLoading?CircularProgressIndicator():Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Observe your Surroundings",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 10,),
        _error==true?const Text("Please select at least 1 surrounding",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
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
              Wrap(
                children: updatedSurroundings.map((item) {
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
              Transform.translate(
                offset:const Offset(-15.0,0.0),
                child: CheckboxListTile(
                  title: Transform.translate(
                    offset:const Offset(-15.0,0.0),
                    child: const Text(
                      'Other...',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'WorkSans',
                      ),
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: isOthersSelected,
                  onChanged: (isChecked) {
                    setState(() {
                      isOthersSelected = isChecked ?? false;
                    });
                    _steps = _generateSteps();
                  },
                  activeColor: Resources.colors.appTheme.lable, // Set the desired dark blue color
                  checkColor: Colors.white, // Set the check color to white
                ),
              ),
              if (isOthersSelected) ...[
                SizedBox(height: 16.0),
                Text(
                  'Additional Details',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'WorkSans',
                    color: Resources.colors.appTheme.lable,
                  ),
                ),
                TextFormField(
                  controller: additionalDetailsController,
                  decoration: const InputDecoration(
                    hintText: 'Enter additional details',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    final String additionalDetails = additionalDetailsController.text;
                    if (additionalDetails.isNotEmpty) {
                      setState(() {
                        updatedSurroundings.add(additionalDetails);
                        isOthersSelected = false;
                        additionalDetailsController.clear();
                        selectedSurrounding(additionalDetails);
                        form.control('surroundings').value=[additionalDetails];
                        _steps = _generateSteps();
                      });
                      // updatedSurroundings.addAll(List.from(updatedSurroundings)); // Create a copy of otherSurroundings and add it to updatedSurroundings
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Resources.colors.appTheme.darkBlue),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 40.0)),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 16.0),
              RichText(
                text:  TextSpan(
                  text: 'Surrounding Pictures',
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
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
          child: const Text(
            'Upload Images',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(height: 16.0),
        _error==true?const Text("This image is required",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
        if(surroundingPictures != null)
          Container(child:Image.network(
            surroundingPictures[0]['imageURL'],
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                );
              }
            },
          ),),
        if (selectedSurroundingImages.isNotEmpty)
          Container(
              margin:
              EdgeInsets.symmetric(vertical: 20),
              child: Container(
                  height: 255,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedSurroundingImages.length,
                      itemBuilder: (BuildContext ctxt, int Index) {
                        return SingleChildScrollView(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.white),
                                  child: Stack(
                                      alignment: Alignment.topRight,
                                      children:[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                              height: (MediaQuery.of(context).size.width - 100) /1.6,
                                              // width: (MediaQuery.of(context).size.width - 30) / 2,
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
                                      ]
                                  ),
                                ),
                                RichText(
                                  text:  TextSpan(
                                    text: 'Description',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontFamily: 'WorkSans',
                                        color: Resources.colors.appTheme.lable
                                    ),
                                    // children: const [
                                    //   TextSpan(
                                    //     text: ' *',
                                    //     style: TextStyle(
                                    //       fontSize: 16.0,
                                    //       color: Colors.red,
                                    //     ),
                                    //   ),
                                    // ],
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Container(
                                    width: 170,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    // padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      surroundingDescriptions[Index],
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
                          ),
                        );
                      })
              )
          ),
      ],
    ),
    );
  }

  //STEP 4 : WATER QUALITY TESTING
  _waterQuality(){
    return SingleChildScrollView(
      child: isLoading?CircularProgressIndicator():Column(
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
                  text: "E-Coli/Coliform Bacteria",
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'WorkSans',
                      color: Resources.colors.appTheme.lable
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
    ),
    );
  }

  //STEP 5 : FLORA AND FAUNA
  _floraAndFauna(){
    return SingleChildScrollView(
      child: isLoading?CircularProgressIndicator():Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10,),
          _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
          Row(
            children: [
              SvgPicture.asset(
                "assets/images/Flora-1.svg",
                width: 20,
                height: 20,
              ),
              SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  text: "Flora",
                  style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: Resources.colors.appTheme.lable,
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Record the vegetation you can see around you. This could include grasses, shrubs, plants and trees', // Add your desired text here
                  style: TextStyle(
                    color: Colors.grey, // Set the color to gray
                  ),
                ),
              ),
              SizedBox(height: 8.0), // Add some spacing between the text and the button
              Container(
                width: double.infinity, // Set the button width to full width
                child: ElevatedButton(
                  onPressed: () async {
                    var camOrGallery = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PictureOptions();
                      },
                    );

                    if (camOrGallery.toString() == "Gallery") {
                      var img = pickImages('flora', 'Gallery');
                    } else if (camOrGallery.toString() == "Camera") {
                      var img = pickImages('flora', 'Camera');
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(
                          color: Resources.colors.appTheme.darkBlue,
                        ),
                      ),
                    ),
                  ),
                  child: const Text(
                    'UPLOAD FLORA PICTURES',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          if (floraPictures != null && floraPictures.isNotEmpty)
            Container(
              child: Image.network(
                floraPictures[0]['imageURL'],
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    );
                  }
                },
              ),
            ),
          if (selectedFloraImages.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                height: 255,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFloraImages.length,
                  itemBuilder: (BuildContext ctxt, int Index) {
                    return SingleChildScrollView(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Stack(
                                  alignment: Alignment.topRight,
                                  children:[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: (MediaQuery.of(context).size.width - 100) /1.6,
                                          // width: (MediaQuery.of(context).size.width - 30) / 2,
                                          child: Image.file(
                                              fit: BoxFit.fill,
                                              File(selectedFloraImages[Index]!.path)
                                          )
                                      ),
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
                                  ]
                              ),
                            ),
                            RichText(
                              text:  TextSpan(
                                text: 'Description',
                                style: TextStyle(
                                    fontSize: 14.0,
                                  fontFamily: 'WorkSans',
                                  color: Resources.colors.appTheme.lable,
                                ),
                                // children: const [
                                //   TextSpan(
                                //     text: ' *',
                                //     style: TextStyle(
                                //       fontSize: 16.0,
                                //       color: Colors.red,
                                //     ),
                                //   ),
                                // ],
                              ),
                            ),
                            SizedBox(height: 5,),
                            Container(
                                width: 170,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                // padding: EdgeInsets.symmetric(horizontal: 5),
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
                                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          Row(
            children: [
              SvgPicture.asset(
                "assets/images/Fauna-1.svg",
                width: 20,
                height: 20,
              ),
              SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  text: "Fauna",
                  style: TextStyle(
                      fontFamily: 'WorkSans',
                      color: Resources.colors.appTheme.lable,
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Record fish, amphibians, reptiles, birds, insects and mammals that you see around you', // Add your desired text here
                  style: TextStyle(
                    color: Colors.grey, // Set the color to gray
                  ),
                ),
              ),
              SizedBox(height: 8.0), // Add some spacing between the text and the button
              Container(
                width: double.infinity, // Set the button width to full width
                child: ElevatedButton(
                  onPressed: () async {
                    var camOrGallery = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PictureOptions();
                      },
                    );

                    if (camOrGallery.toString() == "Gallery") {
                      var img = pickImages('fauna', 'Gallery');
                    } else if (camOrGallery.toString() == "Camera") {
                      var img = pickImages('fauna', 'Camera');
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(
                          color: Resources.colors.appTheme.darkBlue,
                        ),
                      ),
                    ),
                  ),
                  child: const Text(
                    'UPLOAD FAUNA PICTURES',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          if (faunaPictures != null && faunaPictures.isNotEmpty)
            Container(
              child: Image.network(
                faunaPictures[0]['imageURL'],
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    );
                  }
                },
              ),
            ),
          if (selectedFaunaImages.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                height: 255,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFaunaImages.length,
                  itemBuilder: (BuildContext ctxt, int Index) {
                    return SingleChildScrollView(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Stack(
                                  alignment: Alignment.topRight,
                                  children:[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: (MediaQuery.of(context).size.width - 100) /1.6,
                                          // width: (MediaQuery.of(context).size.width - 30) / 2,
                                          child: Image.file(
                                              fit: BoxFit.fill,
                                              File(selectedFaunaImages[Index]!.path)
                                          )
                                      ),
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
                                  ]
                              ),
                            ),
                            RichText(
                              text:  TextSpan(
                                text: 'Description',
                                style: TextStyle(
                                    fontSize: 14.0,
                                  fontFamily: 'WorkSans',
                                  color: Resources.colors.appTheme.lable,
                                ),
                                // children: const [
                                //   TextSpan(
                                //     text: ' *',
                                //     style: TextStyle(
                                //       fontSize: 16.0,
                                //       color: Colors.red,
                                //     ),
                                //   ),
                                // ],
                              ),
                            ),
                            SizedBox(height: 5,),
                            Container(
                                width: 170,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                // padding: EdgeInsets.symmetric(horizontal: 5),
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
                                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  //STEP 6 : FLORA AND FAUNA
  _otherPictures() {
    return SingleChildScrollView(
      child: isLoading
          ? CircularProgressIndicator()
          : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pictures (Optional)",
            style: TextStyle(
                color: Resources.colors.appTheme.darkBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10,),
          _error == true
              ? const Text(
            "Please fill all details",
            style: TextStyle(color: Colors.red, fontSize: 10),
          )
              : SizedBox(),
          RichText(
            text: TextSpan(
              text: "Group pictures",
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: 'WorkSans',
                color: Resources.colors.appTheme.lable,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                var camOrGallery = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PictureOptions();
                  },
                );

                if (camOrGallery.toString() == "Gallery") {
                  var img = pickImages('group', 'Gallery');
                } else if (camOrGallery.toString() == "Camera") {
                  var img = pickImages('group', 'Camera');
                }
              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Resources.colors.appTheme.darkBlue,
                    ),
                  ),
                ),
              ),
              child: const Text(
                'UPLOAD GROUP PICTURES',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          if (groupPictures != null && groupPictures.isNotEmpty)
            Container(
              child: Image.network(
                groupPictures[0]['imageURL'],
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    );
                  }
                },
              ),
            ),
          if (selectedGroupImages.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                height: 255,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedGroupImages.length,
                  itemBuilder: (BuildContext ctxt, int Index) {
                    return SingleChildScrollView(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Stack(
                                  alignment: Alignment.topRight,
                                  children:[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: (MediaQuery.of(context).size.width - 100) /1.6,
                                          // width: (MediaQuery.of(context).size.width - 30) / 2,
                                          child: Image.file(
                                              fit: BoxFit.fill,
                                              File(selectedGroupImages[Index]!.path)
                                          )
                                      ),
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
                                  ]
                              ),
                            ),
                            RichText(
                              text:  TextSpan(
                                text: 'Description',
                                style: TextStyle(
                                    fontSize: 14.0,
                                  fontFamily: 'WorkSans',
                                  color: Resources.colors.appTheme.lable,
                                ),
                                // children: const [
                                //   TextSpan(
                                //     text: ' *',
                                //     style: TextStyle(
                                //       fontSize: 16.0,
                                //       color: Colors.red,
                                //     ),
                                //   ),
                                // ],
                              ),
                            ),
                            SizedBox(height: 5,),
                            Container(
                                width: 170,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                // padding: EdgeInsets.symmetric(horizontal: 5),
                                child: TextFormField(
                                  autofocus: false,
                                  controller:
                                  groupImageDescriptions[Index],
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
                      ),
                    );
                  },
                ),
              ),
            ),

          RichText(
            text: TextSpan(
              text: "Activity pictures",
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: 'WorkSans',
                color: Resources.colors.appTheme.lable,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                var camOrGallery = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PictureOptions();
                  },
                );

                if (camOrGallery.toString() == "Gallery") {
                  var img = pickImages('activity', 'Gallery');
                } else if (camOrGallery.toString() == "Camera") {
                  var img = pickImages('activity', 'Camera');
                }
              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Resources.colors.appTheme.darkBlue,
                    ),
                  ),
                ),
              ),
              child: const Text(
                'UPLOAD ACTIVITY PICTURES',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          if (activityPictures != null && activityPictures.isNotEmpty)
            Container(
              child: Image.network(
                activityPictures[0]['imageURL'],
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    );
                  }
                },
              ),
            ),
          if (selectedActivityImages.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                height: 255,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedActivityImages.length,
                  itemBuilder: (BuildContext ctxt, int Index) {
                    return SingleChildScrollView(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Stack(
                                  alignment: Alignment.topRight,
                                  children:[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: (MediaQuery.of(context).size.width - 100) /1.6,
                                          // width: (MediaQuery.of(context).size.width - 30) / 2,
                                          child: Image.file(
                                              fit: BoxFit.fill,
                                              File(selectedActivityImages[Index]!.path)
                                          )
                                      ),
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
                                  ]
                              ),
                            ),
                            RichText(
                              text:  TextSpan(
                                text: 'Description',
                                style: TextStyle(
                                    fontSize: 14.0,
                                  fontFamily: 'WorkSans',
                                  color: Resources.colors.appTheme.lable,
                                ),
                                // children: const [
                                //   TextSpan(
                                //     text: ' *',
                                //     style: TextStyle(
                                //       fontSize: 16.0,
                                //       color: Colors.red,
                                //     ),
                                //   ),
                                // ],
                              ),
                            ),
                            SizedBox(height: 5,),
                            Container(
                                width: 170,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                // padding: EdgeInsets.symmetric(horizontal: 5),
                                child: TextFormField(
                                  autofocus: false,
                                  controller:
                                  activityImageDescriptions[Index],
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
                      ),
                    );
                  },
                ),
              ),
            ),

          RichText(
            text: TextSpan(
              text: "Artworks",
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: 'WorkSans',
                color: Resources.colors.appTheme.lable,
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                var camOrGallery = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PictureOptions();
                  },
                );

                if (camOrGallery.toString() == "Gallery") {
                  var img = pickImages('artwork', 'Gallery');
                } else if (camOrGallery.toString() == "Camera") {
                  var img = pickImages('artwork', 'Camera');
                }
              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Resources.colors.appTheme.darkBlue,
                    ),
                  ),
                ),
              ),
              child: const Text(
                'UPLOAD ARTWORK',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          if (artworkPictures != null && artworkPictures.isNotEmpty)
            Container(
              child: Image.network(
                artworkPictures[0]['imageURL'],
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    );
                  }
                },
              ),
            ),
          if (selectedArtworkImages.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                height: 255,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedArtworkImages.length,
                  itemBuilder: (BuildContext ctxt, int Index) {
                    return SingleChildScrollView(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Stack(
                                  alignment: Alignment.topRight,
                                  children:[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          height: (MediaQuery.of(context).size.width - 100) /1.6,
                                          // width: (MediaQuery.of(context).size.width - 30) / 2,
                                          child: Image.file(
                                              fit: BoxFit.fill,
                                              File(selectedArtworkImages[Index]!.path)
                                          )
                                      ),
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
                                  ]
                              ),
                            ),
                            RichText(
                              text:  TextSpan(
                                text: 'Description',
                                style: TextStyle(
                                    fontSize: 14.0,
                                  fontFamily: 'WorkSans',
                                  color: Resources.colors.appTheme.lable,
                                ),
                                // children: const [
                                //   TextSpan(
                                //     text: ' *',
                                //     style: TextStyle(
                                //       fontSize: 16.0,
                                //       color: Colors.red,
                                //     ),
                                //   ),
                                // ],
                              ),
                            ),
                            SizedBox(height: 5,),
                            Container(
                                width: 170,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ),
                                // padding: EdgeInsets.symmetric(horizontal: 5),
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
                                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Flexible(
                                child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text('${form.control('generalInformation.activityDate').value ?? ''}',
                                        style: TextStyle(
                                            color: Resources.colors.appTheme.veryDarkGray,
                                            fontWeight: FontWeight.bold))),
                              )
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text("${form.control('generalInformation.activityTime').value ?? ''}",
                                      style: TextStyle(
                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Flexible(
                                child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text('${form.control('generalInformation.location').value ?? ''}',
                                        style: TextStyle(
                                            color: Resources.colors.appTheme.veryDarkGray,
                                            fontWeight: FontWeight.bold))),
                              )
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(' ${form.control('generalInformation.testerName').value ?? ''}',
                                      style: TextStyle(
                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text( '${form.control('generalInformation.latitude').value ?? ''}',
                                      style: TextStyle(
                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(' ${form.control('generalInformation.longitude').value ?? ''}',
                                      style: TextStyle(
                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterLevelAndWeather.weather').value ?? ''}',
                                      style: TextStyle(
                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      '${form.control('waterLevelAndWeather.airTemperature').value ?? ''}' + " °C",
                                      style: TextStyle(
                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterLevelAndWeather.waterLevel').value ?? ''}',
                                      style:  TextStyle(
                                          color: Resources.colors.appTheme.veryDarkGray,
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
                            "River Pictures",
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
                  if (selectedRiverImages.length > 0 && selectedRiverImages[0].runtimeType != String)
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
                                          // width:180,
                                            height:90,
                                            child: Image.file(
                                                fit: BoxFit.fill,
                                                File(selectedRiverImages[Index]!.path)
                                            )
                                        ),
                                        SizedBox(height:20),
                                        Container(
                                          height: 30,
                                          child: TextFormField(
                                            controller: riverDescriptions[Index],
                                            style: const TextStyle(fontSize: 12),
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white, width: 1.0),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }))),
                  // if (riverPictures != null && riverPictures.isNotEmpty)
                  //   Container(
                  //       margin: const EdgeInsets.symmetric(
                  //           horizontal: 10, vertical: 5),
                  //       child: Container(
                  //           height: 150,
                  //           child: ListView.builder(
                  //               shrinkWrap: true,
                  //               scrollDirection: Axis.horizontal,
                  //               itemCount: riverPictures.length,
                  //               itemBuilder:
                  //                   (BuildContext ctxt, int Index) {
                  //                 return Container(
                  //                   height: (MediaQuery.of(context).size.width - 30) / 2,
                  //                   width: (MediaQuery.of(context).size.width - 30) / 2,
                  //                   padding: const EdgeInsets.only(
                  //                       bottom: 10, left: 5),
                  //                   alignment: Alignment.bottomLeft,
                  //                   child: Column(
                  //                     children: [
                  //                       Container(
                  //                         // width:180,
                  //                           height:90,
                  //                           child: Image.file(
                  //                               fit: BoxFit.fill,
                  //                               File(riverPictures[Index]!.path)
                  //                           )
                  //                       ),
                  //                       SizedBox(height:20),
                  //                       Container(
                  //                         height: 30,
                  //                         child: TextFormField(
                  //                           controller: riverDescriptions[Index],
                  //                           style: const TextStyle(fontSize: 12),
                  //                           readOnly: true,
                  //                           decoration: const InputDecoration(
                  //                             border: OutlineInputBorder(
                  //                               borderSide: BorderSide(color: Colors.white, width: 1.0),
                  //                             ),
                  //                             focusedBorder: OutlineInputBorder(
                  //                               borderSide: BorderSide(color: Colors.white, width: 1.0),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       )
                  //                     ],
                  //                   ),
                  //                 );
                  //               }))),
                ],
              )),
          Container(
              margin: const EdgeInsets.symmetric( vertical: 20),
              padding: EdgeInsets.all(30),
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
                  if (selectedSurroundings.length > 0)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                      child: Container(
                        height: 200,
                        child: Wrap(
                          spacing: 5, // Horizontal spacing between buttons
                          runSpacing: 5, // Vertical spacing between rows of buttons
                          children: List.generate(selectedSurroundings.length, (index) {
                            return ElevatedButton(
                              onPressed: () {
                                // Handle button click here
                              },
                              style: ElevatedButton.styleFrom(
                                primary: const Color(0xFFD9EAE8), // Background color
                                onPrimary: const Color(0xFF212121), // Text color
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Padding
                                minimumSize: const Size(0, 0), // Minimum size
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0), // Border radius
                                  side: const BorderSide(
                                    color: const Color(0xFFA8CFCA), // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                              ),
                              child: Text(
                                selectedSurroundings[index],
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  SizedBox(height: 10,),
                  if (selectedSurroundingImages.length > 0)
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Container(
                            height: 170,
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Surrounding Pictures", // Replace with the actual label text
                                      style: TextStyle(
                                          color: Color(
                                            0xFF1C3764,
                                          )),
                                    ),
                                        SizedBox(height: 10,),
                                        Container(
                                          // width:180,
                                            height:90,
                                            child: Image.file(
                                                fit: BoxFit.fill,
                                                File(selectedSurroundingImages[Index]!.path)
                                            )
                                        ),
                                        SizedBox(height: 10,),
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
                            "Water Testing",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.waterTemperature').value!=null?
                                    Text('${form.control('waterTesting.waterTemperature').value }' + " °C",
                                      style: TextStyle(
                                          color: Resources.colors.appTheme.veryDarkGray,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
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
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.alkalinity').value!=null?
                                  Text(
                                    '${form.control('waterTesting.alkalinity').value}' + " mg/L",
                                    style: TextStyle(
                                      color: () {
                                        try {
                                          final doubleValue = double.parse(form.control('waterTesting.alkalinity').value ?? '');
                                          if (doubleValue >= 20 && doubleValue <= 250) {
                                            return Colors.green;
                                          } else {
                                            return Colors.red;
                                          }
                                        } catch (e) {
                                          // Handle the error, e.g., return a default color
                                          return Colors.black;
                                        }
                                      }(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )

                                      :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
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
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: form.control('waterTesting.nitrite').value != null
                                    ? Builder(
                                  builder: (BuildContext context) {
                                    final nitriteValue = form.control('waterTesting.nitrite').value;
                                    double? parsedValue;
                                    Color textColor;

                                    try {
                                      parsedValue = double.tryParse(nitriteValue);
                                      textColor = parsedValue != null && parsedValue <= 1
                                          ? Colors.green
                                          : Colors.red;
                                    } catch (e) {
                                      parsedValue = null;
                                      textColor = Colors.black;
                                    }

                                    return Text(
                                      parsedValue != null ? '${parsedValue} mg/L' : "--",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                )
                                    : const Text(
                                  "--",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontFamily: "WorkSans",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.hardness').value!=null?
                                  Text('${form.control('waterTesting.hardness').value }' + " mg/L",
                                      style: TextStyle(
                                          color: Resources.colors.appTheme.veryDarkGray,
                                          fontWeight: FontWeight.bold))
                              :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: form.control('waterTesting.chlorine').value != null
                                    ? Builder(
                                  builder: (BuildContext context) {
                                    final chlorineValue = form.control('waterTesting.chlorine').value;
                                    double? parsedValue;
                                    Color textColor;

                                    try {
                                      parsedValue = double.tryParse(chlorineValue);
                                      if (parsedValue != null) {
                                        if (parsedValue >= 0.2 && parsedValue <= 1.0) {
                                          textColor = Colors.green;
                                        } else {
                                          textColor = Colors.red;
                                        }
                                      } else {
                                        // Handle cases where parsing failed
                                        textColor = Colors.red; // You can choose another color if needed
                                      }
                                    } catch (e) {
                                      parsedValue = null;
                                      textColor = Colors.black;
                                    }

                                    return Text(
                                      parsedValue != null ? '${parsedValue} mg/L' : "--",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                )
                                    : const Text(
                                  "--",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontFamily: "WorkSans",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )

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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
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
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: form.control('waterTesting.dissolvedOxygen').value != null
                                    ? Builder(
                                  builder: (BuildContext context) {
                                    final dissolvedOxygenValue = form.control('waterTesting.dissolvedOxygen').value;
                                    double? parsedValue;
                                    Color textColor;

                                    try {
                                      parsedValue = double.tryParse(dissolvedOxygenValue);
                                      if (parsedValue != null) {
                                        if (parsedValue >= 4.0 && parsedValue <= 20.0) {
                                          textColor = Colors.green;
                                        } else {
                                          textColor = Colors.red;
                                        }
                                      } else {
                                        // Handle cases where parsing failed
                                        textColor = Colors.red; // You can choose another color if needed
                                      }
                                    } catch (e) {
                                      parsedValue = null;
                                      textColor = Colors.black;
                                    }

                                    return Text(
                                      parsedValue != null ? '${parsedValue} mg/L' : "--",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                )
                                    : const Text(
                                  "--",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontFamily: "WorkSans",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )

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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
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
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.turbidity').value!=null?
                                  Text(
                                    '${form.control('waterTesting.turbidity').value}' + " NTU",
                                    style: TextStyle(
                                      color: () {
                                        try {
                                          final int intValue = int.parse(form.control('waterTesting.turbidity').value ?? '');
                                          if (intValue <= 15000) {
                                            return Colors.green;
                                          } else {
                                            return Colors.red;
                                          }
                                        } catch (e) {
                                          // Handle the error, e.g., return a default color
                                          return Colors.black;
                                        }
                                      }(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )

                                      :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: form.control('waterTesting.phosphate').value != null
                                    ? Builder(
                                  builder: (BuildContext context) {
                                    final phosphateValue = form.control('waterTesting.phosphate').value;
                                    double? parsedValue;
                                    Color textColor;

                                    try {
                                      parsedValue = double.tryParse(phosphateValue);
                                      if (parsedValue != null) {
                                        textColor = parsedValue <= 0.1 ? Colors.green : Colors.red;
                                      } else {
                                        // Handle cases where parsing failed
                                        textColor = Colors.red; // You can choose another color if needed
                                      }
                                    } catch (e) {
                                      parsedValue = null;
                                      textColor = Colors.black;
                                    }

                                    return Text(
                                      parsedValue != null ? '${parsedValue} mg/L' : "--",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                )
                                    : const Text(
                                  "--",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontFamily: "WorkSans",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )

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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child:form.control('waterTesting.ammonia').value!=null?
                                  Text(
                                    '${form.control('waterTesting.ammonia').value}' + " mg/L",
                                    style: TextStyle(
                                      color: () {
                                        final double? doubleValue = double.tryParse(form.control('waterTesting.ammonia').value ?? '');
                                        if (doubleValue != null && doubleValue >= 0.2 && doubleValue <= 1.2) {
                                          return Colors.green;
                                        } else {
                                          return Colors.red;
                                        }
                                      }(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )

                                      :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: form.control('waterTesting.lead').value != null
                                    ? Builder(
                                  builder: (BuildContext context) {
                                    final leadValue = form.control('waterTesting.lead').value;
                                    double? parsedValue;
                                    Color textColor;

                                    try {
                                      parsedValue = double.tryParse(leadValue);
                                      if (parsedValue != null) {
                                        textColor = parsedValue == 0 ? Colors.green : Colors.red;
                                      } else {
                                        // Handle cases where parsing failed
                                        textColor = Colors.red; // You can choose another color if needed
                                      }
                                    } catch (e) {
                                      parsedValue = null;
                                      textColor = Colors.black;
                                    }

                                    return Text(
                                      parsedValue != null ? '${parsedValue} mg/L' : "--",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                )
                                    : const Text(
                                  "--",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontFamily: "WorkSans",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )

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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.totalDissolvedSolids').value!=null?
                                  Text(
                                    '${form.control('waterTesting.totalDissolvedSolids').value}' + " ppm",
                                    style: TextStyle(
                                      color: () {
                                        final String? valueString = form.control('waterTesting.totalDissolvedSolids').value;
                                        final double? doubleValue = double.tryParse(valueString ?? '');

                                        if (doubleValue != null) {
                                          if (doubleValue < 900) {
                                            return Colors.green;
                                          } else {
                                            return Colors.red;
                                          }
                                        }

                                        return Colors.black; // Default color if parsing fails
                                      }(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )

                                      :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "WorkSans",
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
                                          color: Resources.colors.appTheme.lable,
                                          fontFamily: "WorkSans"))),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: form.control('waterTesting.conductivity').value!=null?
                                  Text(
                                    '${form.control('waterTesting.conductivity').value}' + " µs",
                                    style: TextStyle(
                                      color: () {
                                        final String? valueString = form.control('waterTesting.conductivity').value;
                                        final double? doubleValue = double.tryParse(valueString ?? '');

                                        if (doubleValue != null) {
                                          if (doubleValue < 1000 || doubleValue > 10000) {
                                            return Colors.red;
                                          } else {
                                            return Colors.green;
                                          }
                                        }

                                        return Colors.black; // Default color if parsing fails
                                      }(),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )

                                      :const Text("--",style: TextStyle(
                                      color: Colors.green,
                                      fontFamily: "WorkSans",
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
                                            // width:100,
                                            height:90,
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
                                            // width:100,
                                            height:90,
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
                            "Group Pictures",
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
                                            // width:100,
                                            height:90,
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
                            "Activity Pictures",
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
                                            // width:100,
                                            height:90,
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
                            "Artwork Pictures",
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
                                            // width:100,
                                            height:90,
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
      body: isLoading?const Center(child: CircularProgressIndicator()):Stack(
        alignment: Alignment.center,
        children:[
          Theme(
            data:ThemeData(
              primarySwatch: Colors.green,
            ),
            child: Stepper(
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
                        faunaImgObj.add({
                          "imageURL":"",
                          "fileName":path.basename(selectedFaunaImages[i].path),
                          "description":faunaDescriptions[i].text
                        });
                      }
                      for(int i=0;i<selectedGroupImages.length;i++){
                        groupImgObj.add({
                          "imageURL":"",
                          "fileName":path.basename(selectedGroupImages[i].path),
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
                      if(widget.mode=="add"){
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
                      }else{
                        _waterTestDetail.updateWaterTestDetail(
                            widget.id,
                            form.value,
                            selectedRiverImages,
                            selectedSurroundingImages,
                            selectedFaunaImages,
                            selectedFloraImages,
                            selectedArtworkImages,
                            selectedActivityImages,
                            selectedGroupImages,
                            context);
                      }

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
                      backgroundColor: MaterialStateProperty.all<Color>(Resources.colors.appTheme.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                        ),
                      ),
                    ),
                    onPressed: () {
                      // print(selectedRiverImages[0].runtimeType);
                      if (_index >= 0 && _index < steps.length) {
                        if (this._formKey.currentState!.validate() &&
                            steps[_index] != 'flora' &&
                            steps[_index] != 'waterLevelAndWeather' &&
                            steps[_index] != 'preview' &&
                            form.control(steps[_index]).runtimeType == FormGroup &&
                            form.control(steps[_index]).valid) {
                          setState(() {
                            _index++;
                            _error = false;
                            _steps = _generateSteps();
                          });
                        } else if (steps[_index] == "waterLevelAndWeather") {
                          if (form.control(steps[_index]).valid &&
                              selectedRiverImages.length > 0) {
                            setState(() {
                              _index++;
                              _error = false;
                              _steps = _generateSteps();
                            });
                          } else {
                            setState(() {
                              _error = true;
                              _steps = _generateSteps();
                            });
                          }
                        } else if (steps[_index] != 'flora' &&
                            steps[_index] != 'preview' &&
                            form.control(steps[_index]).runtimeType != FormGroup &&
                            (form.value['surroundings'] != 0  &&
                                selectedSurroundingImages.length != 0)) {
                          setState(() {
                            _index++;
                            _error = false;
                            _steps = _generateSteps();
                          });
                        } else if (steps[_index] == 'flora' || steps[_index] == 'preview') {
                          setState(() {
                            _index++;
                            _error = false;
                            _steps = _generateSteps();
                          });
                        } else {
                          setState(() {
                            _error = true;
                            _autoValidate = true;
                            _steps = _generateSteps();
                          });
                          form.control(steps[_index]).markAllAsTouched();
                        }
                      }
                    },
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                      ),
                    ),
                  ),

                ],
              );
            },
        ),
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

