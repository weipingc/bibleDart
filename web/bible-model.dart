library bible.web.app;

import 'package:polymer/polymer.dart';
import 'dart:js';

final bibleModel = new BibleModel._();

@reflectable
class BibleModel extends Observable {
  static final List<String> Bible = context['Bible'];
  static final List<int> CumNumOfChpPerVol = context['CumNumOfChpPerVol'];
  static final List<int> CumNumOfVrsPerChp = context['CumNumOfVrsPerChp'];
  
  BibleModel._() {
    // printMaxValues();  // For debug
  }
  
  /*
   * Get breviation of a volume
   * @param nVol volume, starts from 0
   */
  String brevOfVolume( int nVol ) {
    int firstVerseSub = CumNumOfVrsPerChp[ CumNumOfChpPerVol[nVol-1] ];
    String firstVerse = Bible[firstVerseSub];
    String firstWord = firstVerse.substring(0, 1);
    return firstWord;
  }
}
