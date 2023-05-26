import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:flutter_orol_v2/services/constants/constants.dart';
import '../services/models/riverMonitoring.dart';
import '../services/providers/AppSharedPreferences.dart';
import '../widgets/features/googleMap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

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
  final TextEditingController activityDateController = TextEditingController();
  final TextEditingController activityTimeController = TextEditingController();
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
    if(widget.mode=="edit"){
      getRiverMonitoringDetail();
    }
    _steps = _generateSteps();
  }


  Future<WaterTestDetails?> getRiverMonitoringDetail() async {
     _waterTestDetail = (await AppSharedPreference().getRiverMonitoringInfo())! ;
     print('_waterTestDetail');
     print(jsonEncode(_waterTestDetail));
  }

  Future<void> pickImages(name) async {
    XFile? image;
    try {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
      print('image');
      print(image!.name);
    } catch (e) {
      // Handle any exceptions
    }
    if (image == null) return;
    setState(() {
      // Image.file(File(image!.path));
      File file = File(image!.path);
      print('file');
      print(file);
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
        child: ReactiveTextField<String>(
          formControlName: fieldName,
          keyboardType: TextInputType.number,
          validationMessages: {
            ValidationMessage.required: (_) =>
            'The ${label?.toLowerCase()} must not be empty'
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: label,
            suffix: fieldName=="waterTesting.waterTemperature"||fieldName=="waterTesting.pH"||fieldName=="waterTesting.alkalinity"?Text("°C")
                    :fieldName=="waterTesting.turbidity"?Text("NTU")
                    :fieldName=="waterTesting.conductivity"?Text("µs")
                    :fieldName=="waterTesting.totalDissolvedSolids"?Text("ppm"):Text("mg/L"),
            labelStyle: TextStyle(color: Resources.colors.appTheme.darkBlue),
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
      print("LOCATION DETAILS");
      setState(() {
        form.control('generalInformation.location').value=locationName;
        form.control('generalInformation.latitude').value=lat.toString();
        form.control('generalInformation.longitude').value=lan.toString();
        _steps = _generateSteps();
      });
      // Do something with the name and ID
    }
  }

  List<Map<String, dynamic>> convertToObjects(List<XFile> images, List<String> descriptions) {
    setState(() {
      _steps = _generateSteps();
    });
    return List.generate(
      images.length,
          (index) => {
        'imageURL': '',
        'description': descriptions.length>0?descriptions[index]:'',
      },
    );
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

  //STEP 1 : GENERAL INFORMATION
  _generalInformation (){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("General Information",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 15,fontWeight: FontWeight.w600),),
        const SizedBox(height: 10,),
        ReactiveForm(
          formGroup: form,
          child: Column(
            children: [
              ReactiveTextField<String>(
                formControlName: 'generalInformation.activityDate',
                controller: activityDateController,
                validationMessages: {
                  ValidationMessage.required: (_) => 'required',
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
                  labelText: 'Activity Date ',
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
              SizedBox(height: 10,),
              ReactiveTextField<String>(
                formControlName: 'generalInformation.activityTime',
                controller: activityTimeController,
                validationMessages: {
                  ValidationMessage.required: (_) => 'required',
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
                  labelText: 'Activity Time ',
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
              const SizedBox(height: 10),
              ReactiveTextField<String>(
                formControlName: 'generalInformation.testerName',
                validationMessages: {
                  ValidationMessage.required: (_) => 'required',
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Tester Name',
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
              SizedBox(width: 10,),
              ReactiveTextField<String>(
                formControlName: 'generalInformation.location',
                validationMessages: {
                  ValidationMessage.required: (_) => 'required',
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Location',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.gps_fixed),
                    onPressed: () async {
                      _navigateToMap();
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
              const SizedBox(height: 10),
              ReactiveTextField<String>(
                formControlName: 'generalInformation.latitude',
                validationMessages: {
                  ValidationMessage.required: (_) => 'required',
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Latitude',
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
              SizedBox(width: 10,),
              ReactiveTextField<String>(
                formControlName: 'generalInformation.longitude',
                validationMessages: {
                  ValidationMessage.required: (_) => 'required',
                },
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Longitude',
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
          Text("Water Level & Weather",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 15,fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
          ReactiveForm(
            formGroup: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReactiveTextField<String>(
                  formControlName: 'waterLevelAndWeather.airTemperature',
                  validationMessages: {
                    ValidationMessage.required: (_) => 'required',
                  },
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Measure the air temperature',
                    suffix: Text("°C"),
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
                Text("Observe the Water Level",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
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
                Text("Weather Condtions",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
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
                Text("River Pictures",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: (){
              pickImages('riverPicture');
            },
            child: const Text('Select Images'),
          ),
          const SizedBox(height: 16.0),
          if (selectedRiverImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Container(
                    height: 250,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedRiverImages.length,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                Container(
                                    width:150,
                                    height:150,
                                    child: Image.file(
                                        fit: BoxFit.fill,
                                        File(selectedRiverImages[Index]!.path)
                                    )
                                ),
                                Container(
                                    width: 170,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(5)),
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      riverDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                          borderRadius: BorderRadius.circular(25.0),
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
        Text("Observe your Surroundings",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 15,fontWeight: FontWeight.w600),),
        const SizedBox(height: 10,),
        _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
        ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        // print(jsonEncode(selectedSurroundings));
                        // print(jsonEncode(form.value['surroundings']);
                      },
                    ),
                  );
                }).toList(),
              ),
              Text("Surrounding Pictures",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
            ],
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
         onPressed: (){
          pickImages('surroundingImages');
          },
          child: Text('Select Images'),
        ),
        SizedBox(height: 16.0),
        if (selectedSurroundingImages.isNotEmpty)
          Container(
              margin:
              EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Container(
                  height: 250,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedSurroundingImages.length,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                              Container(
                                  width:150,
                                  height:150,
                                  child: Image.file(
                                      fit: BoxFit.fill,
                                      File(selectedSurroundingImages[Index]!.path)
                                  )
                              ),
                              Container(  width: 170,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(5)),
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 5),
                                  child: TextFormField(
                                    autofocus: false,
                                    controller:
                                    surroundingDescriptions[Index],
                                    style: TextStyle(fontSize: 12),
                                    decoration: InputDecoration(
                                      focusedBorder:OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                        borderRadius: BorderRadius.circular(25.0),
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
        Text("Water Quality Testing",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 15,fontWeight: FontWeight.w600),),
        const SizedBox(height: 10,),
        _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
        ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...waterQualityFormFields(),
              Text("Bacteria",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
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
                        padding: EdgeInsets.all(8.0),
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
                        padding: EdgeInsets.all(8.0),
                        child: Text('Absent'),
                      ),
                    ),
                  )
                ],
              )
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
          Text("Flora & Fauna",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 15,fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
          Text("Flora",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: (){
              pickImages('flora');
            },
            child: Text('Select Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedFloraImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Container(
                    height: 250,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedFloraImages.length,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                Container(
                                    width:150,
                                    height:150,
                                    child: Image.file(
                                        fit: BoxFit.fill,
                                        File(selectedFloraImages[Index]!.path)
                                    )
                                ),
                                Container(    width: 170,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(5)),
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      floraDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                          borderRadius: BorderRadius.circular(25.0),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        })
                )
            ),
          Text("Fauna",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: (){
              pickImages('fauna');
            },
            child: Text('Select Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedFaunaImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Container(
                    height: 250,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedFaunaImages.length,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                Container(
                                    width:150,
                                    height:150,
                                    child: Image.file(
                                        fit: BoxFit.fill,
                                        File(selectedFaunaImages[Index]!.path)
                                    )
                                ),
                                Container(    width: 170,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(5)),
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      faunaDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                          borderRadius: BorderRadius.circular(25.0),
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
          Text("Water Level & Weather",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 15,fontWeight: FontWeight.w600),),
          const SizedBox(height: 10,),
          _error==true?const Text("Please fill all details",style: TextStyle(color: Colors.red,fontSize: 10),):SizedBox(),
          Text("Group pictures",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: (){
              pickImages('group');
            },
            child: Text('Select Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedGroupImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Container(
                    height: 250,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                Container(
                                    width:150,
                                    height:150,
                                    child: Image.file(
                                        fit: BoxFit.fill,
                                        File(selectedGroupImages[Index]!.path)
                                    )
                                ),
                                Container(    width: 170,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(5)),
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      groupImageDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                          borderRadius: BorderRadius.circular(25.0),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        })
                )
            ),
          Text("Activity pictures",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: (){
              pickImages('activity');
            },
            child: Text('Select Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedActivityImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Container(
                    height: 250,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                Container(
                                    width:150,
                                    height:150,
                                    child: Image.file(
                                        fit: BoxFit.fill,
                                        File(selectedActivityImages[Index]!.path)
                                    )
                                ),
                                Container(    width: 170,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(5)),
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      activityImageDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                          borderRadius: BorderRadius.circular(25.0),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        })
                )
            ),
          Text("Artworks",style: TextStyle(color: Resources.colors.appTheme.darkBlue,fontSize: 12),),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: (){
              pickImages('artwork');
            },
            child: Text('Select Images'),
          ),
          SizedBox(height: 16.0),
          if (selectedArtworkImages.isNotEmpty)
            Container(
                margin:
                EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Container(
                    height: 250,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                Container(
                                    width:150,
                                    height:150,
                                    child: Image.file(
                                        fit: BoxFit.fill,
                                        File(selectedArtworkImages[Index]!.path)
                                    )
                                ),
                                Container(    width: 170,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(5)),
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                    child: TextFormField(
                                      autofocus: false,
                                      controller:
                                      artworkDescriptions[Index],
                                      style: TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        focusedBorder:OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                          borderRadius: BorderRadius.circular(25.0),
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
                                  child: Text(
                                     ' ${form.control('waterTesting.waterTemperature').value ?? ''}' + " °C",
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
                                  child: Text("pH",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text(' ${form.control('waterTesting.pH').value ?? ''}' + " units",
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
                                  child: Text("Alkalinity",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.alkalinity').value ?? ''}' + " mg/L",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight:
                                          FontWeight.bold))),
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
                                  child: Text('${form.control('waterTesting.nitrate').value ?? ''}' + " mg/L",
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
                                  child: Text("Nitrite",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.nitrite').value ?? ''}' + " mg/L",
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
                                  child: Text("Hardness",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.hardness').value ?? ''}' + " mg/L",
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
                                  child: Text("Chlorine",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.chlorine').value ?? ''}' + " mg/L",
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
                                  child: Text("Iron",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.iron').value ?? ''}' + " mg/L",
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
                                  child: Text("Dissolved oxygen",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      '${form.control('waterTesting.dissolvedOxygen').value ?? ''}' + " mg/L",
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
                                  child: Text(
                                      "E Coli/Coliform Bacteria",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      '${form.control('waterTesting.bacteria').value ?? ''}' + " ",
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
                                  child: Text("Turbidity",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.turbidity').value ?? ''}' + " NTU",
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
                                  child: Text("Phosphate",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.phosphate').value ?? ''}' + " mg/L",
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
                                  child: Text("Ammonia",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.ammonia').value ?? ''}' + " mg/L",
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
                                  child: Text("Lead",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.lead').value ?? ''}' + " mg/L",
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
                                  child: Text("Total Dissolved Solids",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.totalDissolvedSolids').value ?? ''}' + " ppm",
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
                                  child: Text("Conductivity",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontFamily: "Montserrat"))),
                              Container(  
                                  alignment: Alignment.centerLeft,
                                  child: Text('${form.control('waterTesting.conductivity').value ?? ''}' + " µs",
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
                                                File(selectedRiverImages[Index]!.path)
                                            )
                                        ),
                                        TextFormField(
                                          controller:
                                          riverDescriptions[Index],
                                          style:
                                          TextStyle(fontSize: 12),
                                          readOnly:true,
                                          decoration: InputDecoration(
                                            focusedBorder:OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                              borderRadius: BorderRadius.circular(25.0),
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
                                        TextFormField(
                                          controller:
                                          surroundingDescriptions[
                                          Index],
                                          style:
                                          TextStyle(fontSize: 12),
                                          readOnly:true,
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
                                        TextFormField(
                                          controller:
                                          floraDescriptions[
                                          Index],
                                          style:
                                          TextStyle(fontSize: 12),
                                          readOnly:true,
                                          decoration: InputDecoration(
                                            focusedBorder:OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                              borderRadius: BorderRadius.circular(25.0),
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
                                        TextFormField(
                                          controller:
                                          faunaDescriptions[
                                          Index],
                                          style:
                                          TextStyle(fontSize: 12),
                                          readOnly:true,
                                          decoration: InputDecoration(
                                            focusedBorder:OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                              borderRadius: BorderRadius.circular(25.0),
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
                                        TextFormField(
                                          controller:
                                          groupImageDescriptions[Index],
                                          style: TextStyle(fontSize: 12),
                                          readOnly:true,
                                          decoration: InputDecoration(
                                            focusedBorder:OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                              borderRadius: BorderRadius.circular(25.0),
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
                                        TextFormField(
                                          controller:
                                          activityImageDescriptions[Index],
                                          style: TextStyle(fontSize: 12),
                                          readOnly:true,
                                          decoration: InputDecoration(
                                            focusedBorder:OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                              borderRadius: BorderRadius.circular(25.0),
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
                                        TextFormField(
                                          controller:
                                          artworkDescriptions[Index],
                                          style: TextStyle(fontSize: 12),
                                          readOnly:true,
                                          decoration: InputDecoration(
                                            focusedBorder:OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white, width: 2.0),
                                              borderRadius: BorderRadius.circular(25.0),
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
        title: Text("Add river monitoring"),
      ),
      body: Stepper(
        elevation: 0,
        type:StepperType.horizontal,
        currentStep: _index,
        onStepTapped: (int index) {
          setState(() {
            _index = index;
            _steps = _generateSteps();
          });
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
                  onStepContinue;
                  for(int i=0;i<selectedRiverImages.length;i++){
                    print('imageTemporary');
                    riverImgObj.add({
                      "imageURL":"",
                      "fileName":path.basename(selectedRiverImages[i].path),
                      "description":riverDescriptions[i].text
                    });
                    print(riverImgObj);
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
                  Map<String, dynamic> testMap = (form.value);
                  _waterTestDetail.createWaterTestDetail(form,selectedRiverImages,selectedSurroundingImages, context);
                },
                child: Text('Save'),
              ),
            ],
          ):
          Row(
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
                  print("FORM CONTROL");
                  print(form.value['surroundings']);
                  if (steps[_index]!='flora'&&steps[_index]!='preview'&&form.control(steps[_index]).runtimeType==FormGroup&&form.control(steps[_index]).valid) {
                    setState(() {
                      _index++;
                      _error=false;
                      _steps = _generateSteps();
                    });
                  }
                  else if (steps[_index]!='flora'&&steps[_index]!='preview'&&form.control(steps[_index]).runtimeType!=FormGroup&&(form.value['surroundings'] as List<String>).isNotEmpty) {
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
    );
  }
}


