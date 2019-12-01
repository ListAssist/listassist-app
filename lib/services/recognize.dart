import 'package:listassist/models/DetectionResponse.dart';
import 'package:listassist/models/PossibleProduct.dart';

class RecognizeService {
  // final String blackList = "%()[]{}²³/\\!§?^°_#";
  final String blackList = "%§?^°_²³#";
  final RegExp regexPreprocessing = RegExp(r"\.|[0-9]|,");
  final List<String> marken = ["clever", "oetk", "nöm", "knorr"];

  final int minLength = 3;


  List<PossibleProduct> processResponse(DetectionResponse response) {
    List<PossibleProduct> output = [];

    /// Split texts into array seperated by new lines
    String responseString = response.detectedString.replaceAll(",", ".").replaceAll("..", ".");
    print(responseString);

    List<String> lines = responseString.split("\n");

    for (int i = 0; i < lines.length; i++) {
      /// Check if line is not empty and proceed
      if (lines[i].isNotEmpty) {
        List<String> correctedLine = _correctLine(lines[i].split(" "));

        /// seperate price and product name
        PossibleProduct product;
        if (double.tryParse(correctedLine.last) != null) {
          double price = double.parse(correctedLine.last);
          correctedLine.removeLast();

          product = PossibleProduct(name: _preprocessName(correctedLine), price: price);
        } else {
          product = PossibleProduct(name: _preprocessName(correctedLine));
        }
        output.add(product);
      }
    }

    return output;
  }

  /// remove words which have nothing to do with the price or product name
  /// These are for example discounts in percents or any other unwanted single letters
  List<String> _correctLine(List<String> unfilteredList) {
    List<String> correctedLine = [];
    /// Iterate through line which has been splitted by a space
    for (int i = 0; i < unfilteredList.length; i++) {
      if (!_containsBlacklistedItem(unfilteredList[i]) && unfilteredList[i].length >= minLength) {
        String finalPartString = unfilteredList[i];
        if (double.tryParse(unfilteredList[i]) == null) {
          finalPartString = finalPartString.replaceAll(".", ". ");
        }
        correctedLine.add(finalPartString);
      }
    }
    return correctedLine;
  }

  /// preprocess name to make comparing strings easier later
  List<String> _preprocessName(List<String> nameToBeFiltered) {
    List<String> filtered = [];
    /// Iterate through line which has been splitted by a space
    for (int i = 0; i < nameToBeFiltered.length; i++) {
      filtered.add(nameToBeFiltered[i].replaceAll(regexPreprocessing, ""));
    }
    return filtered;
  }

  /// Check if String contains unwanted char
  bool _containsBlacklistedItem(String toCheck) {
    /// Check if char in string which is not allowed and delete part from line
    for (int i = 0; i < blackList.length; i++) {
      if (toCheck.contains(blackList[i])) {
        return true;
      }
    }
    return false;
  }
}

final RecognizeService recognizeService = RecognizeService();
