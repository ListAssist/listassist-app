import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';


class SpeechDialog extends StatefulWidget {
  @override
  _SpeechDialog createState() => _SpeechDialog();
}

class _SpeechDialog extends State<SpeechDialog> {

  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String resultText = "";

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler((bool result) => setState(() => _isAvailable = result));
    _speechRecognition.setRecognitionStartedHandler(() => setState(() => _isListening = true));
    _speechRecognition.setRecognitionResultHandler((String speech) => setState(() => resultText = speech));
    _speechRecognition.setRecognitionCompleteHandler(() => setState(() {
      _isListening = false;
      Navigator.pop(context, resultText);
    }));
    _speechRecognition.activate().then((result) => setState(() => _isAvailable = result));
  }

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  @override
  Widget build(BuildContext context) {
    if(_isAvailable && !_isListening){
      _speechRecognition.listen(locale: "de_AT").then((result) {
        print("$result");
      });
    }
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 66.0 + 16.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            margin: EdgeInsets.only(top: 66.0),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                Text(
                  "Spracherkennung",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Liste die gewünschten Produkte getrennt durch "und" auf',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 24.0),
                Text(
                  "$resultText",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 24.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // To close the dialog
                    },
                    child: Text("Fertig"),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16.0,
            right: 16.0,
            child: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              radius: 66.0,
              child: Icon(
                Icons.mic,
                size: 65,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}