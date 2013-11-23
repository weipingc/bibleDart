class Anchor {
  int id;
  String text;
  bool selected;
  
  Anchor( this.id, this.text, this.selected );
  String get selectedClass => selected ? 'selectedCell' : '';
  
  String toString() => 'Anchor($id, $text, $selected)';
}

class VerseItem {
  String verseSub;
  String verseText;
  
  VerseItem( this.verseSub, this.verseText );
  
  String toString() => 'VerseItem($verseSub, $verseText)';
}

class Bookmark {
  int volume;
  String verseSub;
  String label;
  bool selected;
  
  Bookmark( this.volume, this.verseSub, this.label, this.selected );
  String get selectedClass => selected ? 'selectedBookmark' : '';
  
  String toString() => 'Bookmark($verseSub, $label, $selected)';
}

void printMaxValues() {
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
