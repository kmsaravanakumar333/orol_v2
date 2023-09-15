import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/models/floodWatch.dart';
import '../services/models/user.dart';
import '../services/providers/AppSharedPreferences.dart';
import '../widgets/features/alertBox.dart';
import '../widgets/features/googleMap.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/features/pictureOptions.dart';
import 'package:path/path.dart' as path;


class FloodAlertForm extends StatefulWidget {
  String mode;
  var formValue;
  FloodAlertForm({Key? key, required this.mode, required this.formValue}) : super(key: key);

  @override
  State<FloodAlertForm> createState() => _FloodAlertFormState();
}

class _FloodAlertFormState extends State<FloodAlertForm> {
  bool isLoading = false;
  bool _isSubmitted=false;
  DateTime now = DateTime.now();
  final String GOOGLE_MAP_API='AIzaSyD9VmkK8P-ONafIM_49q6v5vtu3apjbdFg';
  final TextEditingController activityDateController = TextEditingController();
  final TextEditingController activityTimeController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  final TextEditingController yourExpressionController = TextEditingController();
  FloodAlert _flooodAlertDetails = new FloodAlert();

  var floodImgObj=[];
  var floodAlert;


  var newLocationName;
  var newLatitude;
  var newLongitude;
  var floodPicture;


  @override
  void initState() {
    super.initState();
    setState(() {
      newLocationName = widget.formValue['floodInformation']['location'];
      form.control('floodAlert.location').value=widget.formValue['floodInformation']['location'];
      newLatitude = widget.formValue['floodInformation']['latitude'];
      form.control('floodAlert.latitude').value=widget.formValue['floodInformation']['latitude'];
      newLongitude = widget.formValue['floodInformation']['longitude'];
      form.control('floodAlert.longitude').value=widget.formValue['floodInformation']['longitude'];
      form.control('floodAlert.activityDate').value=DateFormat('yyyy-MM-dd').format(now);
      form.control('floodAlert.activityTime').value= DateFormat('h:mm a').format(now);
    });
    if(widget.mode=="edit"){
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  final FormGroup form = fb.group({
    'floodAlert': fb.group({
      'location': FormControl<String>(value:'',validators: [Validators.required]),
      'latitude': FormControl<String>(value:'',validators: [Validators.required]),
      'longitude': FormControl<String>(value:'',validators: [Validators.required]),
      'activityDate': FormControl<String>(value:'',validators: [Validators.required]),
      'activityTime': FormControl<String>(validators: [Validators.required]),
      'experience': FormControl<String>(validators: [Validators.required]),
    }),
    'floodPicture':FormControl<List>(value:[]),
  });


  setForm(){
    form.control('floodAlert.location').value=floodAlert['location'];
    form.control('floodAlert.latitude&longitude').value=floodAlert['latitude&longitude'];
    form.control('floodAlert.activityDate').value=floodAlert['activityDate'];
    form.control('floodAlert.activityTime').value=floodAlert['activityTime'];
  }


  Future<Map<String, dynamic>> getLocationFromPlaceId(String placeId) async {
    final apiUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$GOOGLE_MAP_API';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      form.control('floodAlert.latitude').value="${decodedData['result']['geometry']['location']['lat']}";
      form.control('floodAlert.longitude').value="${decodedData['result']['geometry']['location']['lng']}";
      return decodedData;
    } else {
      throw Exception('Failed to fetch location data');
    }
  }
  List<File> selectedImages = [];

  Future<void> pickImages(name, mode) async {
    XFile? image;
    try {
      if (mode == 'Gallery') {
        image = await ImagePicker().pickImage(source: ImageSource.gallery);
      } else if (mode == 'Camera') {
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
      File file = File(compressedImageFile.path);
      if (name == 'floodPicture') {
        selectedImages.add(file); // Convert XFile to File here
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flood Alert"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(30), // Add 30 units of padding to the entire container
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ReactiveForm(
                  formGroup: form,
                  child: Column(
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
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text:  TextSpan(
                          text: '$newLocationName',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'WorkSans',
                              color: Resources.colors.appTheme.darkBlue
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text:  TextSpan(
                              text: '$newLatitude',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'WorkSans',
                                  color: Resources.colors.appTheme.darkBlue
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                            ),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text:  TextSpan(
                              text: '$newLongitude',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'WorkSans',
                                  color: Resources.colors.appTheme.darkBlue
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                            ),
                          ),
                          ReactiveTextField<String>(
                            formControlName: 'floodAlert.activityDate',
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
                                    form.control('floodAlert.activityDate').value=activityDateController.text;
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
                            ),
                          ),
                          ReactiveTextField<String>(
                            formControlName: 'floodAlert.activityTime',
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
                                    form.control('floodAlert.activityTime').value=activityTimeController.text;
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
                          const SizedBox(height: 30,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              var camOrGallery = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PictureOptions();
                                  });
                              if (camOrGallery.toString() == "Gallery") {
                                var img = pickImages('floodPicture','Gallery');
                              } else if (camOrGallery.toString() == "Camera") {
                                var img = pickImages('floodPicture','Camera');
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
                            child: Container(
                              width: double.infinity, // Make the button full width
                              child: Text(
                                'Upload Flood Pictures',
                                textAlign: TextAlign.center, // Center the text horizontally
                                style: TextStyle(
                                  color: Resources.colors.appTheme.darkBlue,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),

                          if (selectedImages.isNotEmpty)
                            Container(
                                margin:
                                EdgeInsets.symmetric(vertical: 20),
                                child: Container(
                                    height: 200,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: selectedImages.length,
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
                                                                    File(selectedImages[Index]!.path)
                                                                )
                                                            ),
                                                          ),
                                                          Align(
                                                              alignment: Alignment.topRight,
                                                              child: IconButton(
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      selectedImages.removeAt(Index);
                                                                    });
                                                                  },
                                                                  icon: const Icon(
                                                                    Icons.delete,
                                                                    color: Colors.red,
                                                                  ))),
                                                        ]
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        })
                                )
                            ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      RichText(
                        text:  TextSpan(
                          text: 'Experience',
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'WorkSans',
                              color: Resources.colors.appTheme.lable
                          ),
                        ),
                      ),
                      ReactiveTextField<String>(
                        formControlName: 'floodAlert.experience',
                        validationMessages: {
                          ValidationMessage.required: (_) => 'Required field',
                        },
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
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
                      SizedBox(height: 20,),
                      Container(
                        height: 300, // Adjust the height as needed
                        child: CustomGoogleMap(
                          onLocationPicked: (locationName, latitude, longitude) {
                            setState(() {
                              _searchController.text = locationName;
                              newLocationName = locationName;
                              newLatitude = latitude.toString();
                              newLongitude = longitude.toString();
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align buttons at the ends
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Add your cancel button functionality here
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.red), // Customize the button color
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white, // Customize the text color
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // sendFloodAlert();
                              for(int i=0;i<selectedImages.length;i++){
                                floodImgObj.add({
                                  "imageURL":"",
                                  "fileName":path.basename(selectedImages[i].path),
                                });
                              }
                              form.control('floodPicture').value=floodImgObj;

                              setState(() {
                                _isSubmitted=true;
                              });

                              if(widget.mode=="add"){
                                _flooodAlertDetails.createFloodAlert(
                                  form.value,
                                  selectedImages,
                                  context,
                                );
                              }else{

                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Customize the button color
                            ),
                            child: Text(
                              '+ Add Alert',
                              style: TextStyle(
                                color: Colors.white, // Customize the text color
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
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

