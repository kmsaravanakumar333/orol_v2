import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../auth/loginPage.dart';
class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  @override
  Widget build(BuildContext context) {
    //this is a page decoration for intro screen
    PageDecoration pageDecoration =PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color:Resources.colors.appTheme.darkBlue
      ), //tile font size, weight and color
      bodyTextStyle:TextStyle(
        fontSize: 19.0,
        color:Resources.colors.appTheme.darkBlue,
        letterSpacing: 0.36,
        height: 1.3,
        fontWeight: FontWeight.w500
      ),
      bodyAlignment: Alignment.topCenter,
      imageAlignment: Alignment.bottomCenter,
      contentMargin: const EdgeInsets.only(top: 0,bottom: 20,left: 20,right: 20),
      imagePadding: const EdgeInsets.all(20), //image padding
      boxDecoration:BoxDecoration(
        color: Resources.colors.appTheme.lightTeal
      ), //show linear gradient background of page
    );
    return IntroductionScreen(
      globalBackgroundColor: Resources.colors.appTheme.lightTeal,
      //main background of screen
      pages: [ //set your page view here
        PageViewModel(
          title: "",
          body:"Our River Our Life is a citizen centric movement which envisions monitoring and protection of our waterways through community participation. Because together, we can make a difference.",
          image: introImage('assets/images/img_gettingStarted_1.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "",
          body: "Get involved and Make a difference by getting involved in a river monitoring movement and join our network of citizen scientists to help safeguard our waterways.",
          image: introImage('assets/images/img_gettingStarted_1.png'),
          decoration: pageDecoration,
        ),
      ],

      onDone: () => goHomepage(context), //go to home page on done
      onSkip: () => goHomepage(context), // You can override on skip
      showSkipButton: true,
      dotsFlex: 5,
      nextFlex: 0,
      skip: Text('Skip', style: TextStyle(color: Resources.colors.appTheme.darkBlue),),
      next: Icon(Icons.arrow_forward, color: Resources.colors.appTheme.darkBlue,),
      done: Text('Get Started', style: TextStyle(
          fontWeight: FontWeight.w600, color:Resources.colors.appTheme.darkBlue
      ),),
      dotsDecorator:  DotsDecorator(
        size: const Size(10.0, 10.0), //size of dots
        color: Colors.white, //color of dots
        activeSize: const Size(22.0, 10.0),
        activeColor: Resources.colors.appTheme.darkBlue, //color of active dot
        activeShape: const RoundedRectangleBorder( //shave of active dot
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  void goHomepage(context){
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context){
          return const LoginPage();
        }
        ), (Route<dynamic> route) => false);
    //Navigate to home page and remove the intro screen history
    //so that "Back" button wont work.
  }

  Widget introImage(String assetName) {
    //widget to show intro image
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(top: 120),
          child: Image.asset('$assetName', width: 150.0)
      ),
    );
  }
}
