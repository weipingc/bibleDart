import 'dart:js';
import 'package:polymer/polymer.dart';

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
  static String brevOfVolume( int nVol ) {
    int firstVerseSub = CumNumOfVrsPerChp[ CumNumOfChpPerVol[nVol-1] ];
    String firstVerse = Bible[firstVerseSub];
    String firstWord = firstVerse.substring(0, 1);
    return firstWord;
  }
  
  static int VsePtr( int nVol, int nChap, int nVer ) {
    var verseSub = 0;
    if(nVer == null) nVer = 1;
    if(nChap == null ) nChap = 1;
    verseSub = BibleModel.CumNumOfVrsPerChp[BibleModel.CumNumOfChpPerVol[nVol-1] + nChap - 1] + nVer - 1 ;
    return(verseSub);  
  }
  
}
