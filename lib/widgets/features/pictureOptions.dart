import 'package:flutter/material.dart';
class PictureOptions extends StatefulWidget {
  const PictureOptions({Key? key}) : super(key: key);

  @override
  State<PictureOptions> createState() => _PictureOptionsState();
}

class _PictureOptionsState extends State<PictureOptions> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ) ,
      content:
      Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20)
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: (){
                  Navigator.pop(context, "Camera");
                },
                child: Container(
                    child: Wrap(
                      direction: Axis.vertical,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF1C3764),
                          size: 30,
                        ),
                        Container(
                          height: 60,
                          alignment: Alignment.center,
                          width: 60,
                          child: Text("Camera", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ],
                    )
                ),
              ),
              InkWell(
                  onTap: (){
                    Navigator.pop(context, "Gallery");
                  },
                  child: Container(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        direction: Axis.vertical,
                        children: <Widget>[
                          const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF1C3764),
                            size: 30,
                          ),
                          Container(
                              height: 60,
                              alignment: Alignment.center,
                              width: 90,
                              child: Text("Gallery",
                                style: TextStyle(color: Colors.grey, fontSize: 12),)
                          ),
                        ],
                      )
                  )
              )
            ],
          )
      ),
    );
  }
}
