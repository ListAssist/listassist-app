import 'package:listassist/models/DetectionResponse.dart';
import 'package:listassist/models/PossibleProduct.dart';

class RecognizeService {
  // final String blackList = "%()[]{}²³/\\!§?^°_#";
  final RegExp blackList = RegExp(r"%|§|?|^|°|_|²|³|#|€|EUR");
  final RegExp regexPreprocessing = RegExp(r"\.|[0-9]|kg|g|-");
  // final List<String> marken = ["clever", "oetk", "nöm", "knorr"];

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
        if (correctedLine.isNotEmpty) {
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
    }

    return output;
  }


  int editDistance(String s1, String s2) {
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    /// If any string empty => edit distance is the length of the other string (abcd to "" => 4 changes)
    /// https://de.wikipedia.org/wiki/Levenshtein-Distanz
    if (s1.length == 0) {
      return s2.length;
    } else if (s2.length == 0) {
      return s1.length;
    }

    int iMax = s1.length + 1;
    int jMax = s2.length + 1;

    /// create matrix
    List<List<int>> matrix = List.generate(iMax, (_) => List(jMax));
    /// set default value for top left corner
    matrix[0][0] = 0;

    /// set initial values which are just the simple distances
    for (int j = 1; j < jMax; j++) {
      matrix[0][j] = j;
    }
    for (int i = 1; i < iMax; i++) {
      matrix[i][0] = i;
    }

    for (int i = 1; i < iMax; i++) {
      for (int j = 1; j < jMax; j++) {
        int topLeft = matrix[i - 1][j - 1];

        /// if chars not same => add 1 to topleft
        if (s1[i - 1] != s2[j - 1]) {
          topLeft++;
        }
        /// get the min value of left, top left, top
        matrix[i][j] = _minValsForKernel(matrix[i][j - 1] + 1, topLeft, matrix[i - 1][j] + 1);
      }
    }

    /// Return the bottom right value since this is the edit distance
    return matrix[iMax - 1][jMax - 1];
  }

  /// get the min value between the 3 items calculated before
  int _minValsForKernel(left, topLeft, top) {
    if (topLeft <= left && topLeft <= top) {
      return topLeft;
    } else if (left <= topLeft && left <= top) {
      return left;
    } else {
      return top;
    }
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
    if (blackList.hasMatch(toCheck)) {
      return true;
    }
    return false;
  }
}

final RecognizeService recognizeService = RecognizeService();
