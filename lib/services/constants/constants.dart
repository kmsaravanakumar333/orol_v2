class URL {
  // static const apiURL = "http://10.0.2.2:8080"; // for local run it in emulator
  static const apiURL = "http://orol-nodejs-rest-api-env.eba-parzzmti.ap-south-1.elasticbeanstalk.com";         //http://15.207.0.95:3000
  static const verificationKey = "AIzaSyALR2ZDTTyZXGBRFeCV0AHd0S-TV_GWYm8";
}
class WATERANDWEATHER{
  //Water Observe Image
  static const  waterLevelLabels = ['Low', "Normal", "High", "Flooded"];
  static const  waterLevelSelectedIcons = [
    "Low - selected.svg",
    "Normal - selected.svg",
    "High - selected.svg",
    "Flooded - selected.svg"
  ];
  static const waterLevelUnselectedIcons = [
    "Low - unselected.svg",
    "Normal - unselected.svg",
    "High - unselected.svg",
    "Flooded - unselected.svg"
  ];
  //Weather Conditions
  static const weatherLabels = [
    "Sunny",
    "Partly Cloudy",
    "Cloudy",
    "Light Rain",
    "Heavy Rain"
  ];
  static const weatherSelectedIcons = [
    "Sunny - Selected.svg",
    "Partly Cloudy- Selected.svg",
    "Cloudy - Selected.svg",
    "Light Rain - Selected.svg",
    "Heavy Rain - Selected.svg"
  ];
  static const weatherUnselectedIcons = [
    "Sunny - unselected.svg",
    "Partly Cloudy - unselected.svg",
    "Cloudy - unselected.svg",
    "Light Rain - unselected.svg",
    "Heavy Rain - unselected.svg"
  ];
  static const List<String> surroundings = [
    'Clothes washing',
    'Cattle grazing',
    'Vehicles',
    'Agricultural land',
    'Plantation',
    'Bridge',
    'Industry',
    'Place of worship',
    'Village',
    'Town',
    'Effluent discharge',
    'Sewage discharge',
    'Irrigation pump',
  ];
}