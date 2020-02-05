import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';


class IntroSliderView extends StatefulWidget {
  @override
  _IntroSliderViewState createState() => _IntroSliderViewState();

  final VoidCallback onExit;
  IntroSliderView({this.onExit});
}

class _IntroSliderViewState extends State<IntroSliderView> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "LISTEN ERSTELLEN",
        description: "Erstelle Einkaufslisten mit eigenen Produkten, oder von uns vorgefertigten Produkten",
        pathImage: "assets/images/liste.png",
        backgroundColor: Color(0xfff5a623),
        heightImage: 200,
        widthImage: 200,
        marginDescription: EdgeInsets.only(top: 50, left: 22, right: 22),
      ),
    );
    slides.add(
      new Slide(
        title: "GRUPPEN ERSTELLEN",
        description: "Erstelle Gruppen und teile deine Einkaufslisten mit Freunden",
        pathImage: "assets/images/group.png",
        backgroundColor: Color(0xff203152),
        heightImage: 200,
        widthImage: 200,
        marginDescription: EdgeInsets.only(top: 50, left: 22, right: 22),
      ),
    );
    slides.add(
      new Slide(
        title: "RECHNUNGEN SCANNEN",
        description: "Scanne deine Rechnungen ein, um gekaufte Produkte automatisch von der Einkaufsliste zu streichen",
        pathImage: "assets/images/scan.png",
        backgroundColor: Color(0xff9932CC),
        heightImage: 200,
        widthImage: 200,
        marginDescription: EdgeInsets.only(top: 50, left: 22, right: 22),
      ),
    );
  }

  void onDonePress() {
    widget.onExit();
  }

  void onSkipPress() {
    widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onSkipPress,
      nameNextBtn: "WEITER",
      namePrevBtn: "ZURÜCK",
      //nameSkipBtn: "Überspringen",
      nameDoneBtn: "FERTIG",
    );
  }
}