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
    verseSub = CumNumOfVrsPerChp[CumNumOfChpPerVol[nVol-1] + nChap - 1] + nVer - 1 ;
    return(verseSub);  
  }

  static void printMaxValues() {
    int maxNumOfChp = 0, maxChpVol = 0;
    int maxNumOfVerse = 0, maxVerseVol = 0, maxVerseChp = 0;
    
    for( int volInd=0; volInd<66; volInd++ ) {
      int CumNumOfChpThisVol = CumNumOfChpPerVol[volInd];
      int CumNumOfChpNextVol = CumNumOfChpPerVol[volInd+1];
      int numOfChp = CumNumOfChpNextVol - CumNumOfChpThisVol;
      if( numOfChp > maxNumOfChp ) {
        maxNumOfChp = numOfChp;
        maxChpVol = volInd + 1;
      }
      for( int chpInd=CumNumOfChpThisVol; chpInd<CumNumOfChpNextVol; chpInd++ ) {
        int numOfVerse = CumNumOfVrsPerChp[chpInd+1] - CumNumOfVrsPerChp[chpInd];
        if( numOfVerse > maxNumOfVerse ) {
          maxNumOfVerse = numOfVerse;
          maxVerseVol = volInd + 1;
          maxVerseChp = chpInd - CumNumOfChpThisVol + 1;
        }
      }
    }
    print( 'maxNumOfChp=$maxNumOfChp, maxChpVol=$maxChpVol' );
    print( 'maxNumOfVerse=$maxNumOfVerse, maxVerseVol=$maxVerseVol, maxVerseChp=$maxVerseChp' );
  }
}
