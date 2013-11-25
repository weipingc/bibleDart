import 'dart:html';
import 'dart:js';
import 'package:polymer/polymer.dart';

import 'bible_model.dart';
import 'bookmark_mgr.dart';
import 'verse_previewer.dart';

@CustomTag('bible-app')
class BibleApp extends PolymerElement {
  factory BibleApp() => new Element.tag('BibleApp');
  BookmarkMgr bookmarkMgr;
  VersePreviewer versePreviewer;
  
  @observable List<List<Anchor>> volAnchorLines;
  @observable List<List<Anchor>> chapAnchorLines;
  @observable List<List<Anchor>> verseAnchorLines;
  
  @observable String sQuickInput;
  @observable int nVolume=1, nChapter=1, nVerse=1, nNumOfVerse=3;
  
  @observable String get sVolume => nVolume.toString();
  @observable   void set sVolume( String val ) {
           if(val.isEmpty) nVolume=1; else nVolume = int.parse(val);
         }
  @observable String get sChapter => nChapter.toString();
  @observable void   set sChapter( String val ) {
           if(val.isEmpty) nChapter=1; else nChapter = int.parse(val);
         }
  @observable String get sVerse => nVerse.toString();
  @observable void   set sVerse( String val ) {
           if(val.isEmpty) nVerse=1; else nVerse = int.parse(val);
         }
  
  BibleApp.created() : super.created() {
    // printMaxValues();  // For debug
    
    bookmarkMgr = getShadowRoot( 'bible-app' ).querySelector( '#bookmarkMgr' );
    bookmarkMgr.onViewBookmark.listen( handleViewBookmark );
    versePreviewer = getShadowRoot( 'bible-app' ).querySelector( '#versePreviewer' );
    versePreviewer.onBookmarkVerse.listen( handleSaveBookmark );
     
    sQuickInput = '1.1.1';
    nVolume = 1;
    nChapter = 1;
    nVerse = 1;
    updateVolumeAnchorLines();
    updateChapterAnchorLines();
    updateVerseAnchorLines();
    
    versePreviewer.updateVersesByVerseSub( nVolume, nVerse-1, 'Input'  );
  }
  
  void updateQuickInput( Event evt ) {
    if( sQuickInput.isEmpty ) {
      return;
    }
    var nums = sQuickInput.split( '.' );
    if( nums.length > 0 ) {
      sVolume = nums[0];
    } else {
      nVolume = 1;
    }
    if( nums.length > 1 ) {
      sChapter = nums[1];
    } else {
      nChapter = 1;
    }
    if( nums.length > 2 ) {
      sVerse = nums[2];
    } else {
      nVerse = 1;
    }
    
    updateVerses();
    previewSource = 'Input';
  }
  
  void updateVolumeAnchorLines() {
    List<Anchor> line = [];
    List<List<Anchor>> lines = [];
    lines.add( line );
    for( int volInd=1; volInd<=66; volInd++ ) {
      if( line.length == 20 || volInd==40 ) {
        line = [];
        lines.add( line );
      }
      String brev = brevOfVolume( volInd );
      line.add( new Anchor(volInd, '$volInd.$brev', false) );  // pass false instead of volInd==nVolume due issue in L58-60
    }
    volAnchorLines = lines;
  }
  
  DivElement selectedVolAnchor;
  DivElement selectedChapAnchor;
  DivElement selectedVerseAnchor;
  
  @observable String previewSource = 'Unknown';
  @observable String previewTitle;
  
  void volAnchorClicked( MouseEvent evt ) {
    if( selectedVolAnchor != null ) {
      selectedVolAnchor.classes.remove( 'selectedCell' );
    }
    volAnchorLines[0][0].selected = false;
    DivElement tarEle = evt.target;
    tarEle.classes.add( 'selectedCell' );
    selectedVolAnchor = tarEle;
    
    sVolume = tarEle.id.split('.')[1];
    updateChapterAnchorLines();
    
    nChapter = 1;
    updateVerseAnchorLines();
    nVerse = 1;
    previewSource = 'Anchors';
    updateVerses();
  }
  
  void updateChapterAnchorLines() {
    int CumNumOfChpThisVol = BibleModel.CumNumOfChpPerVol[nVolume-1];
    int CumNumOfChpNextVol = BibleModel.CumNumOfChpPerVol[nVolume];
    int numOfChap = CumNumOfChpNextVol - CumNumOfChpThisVol;
    chapAnchorLines = getAnchorLines( numOfChap, nChapter, 40 );
  }
  
  void chapAnchorClicked( MouseEvent evt ) {
    if( selectedChapAnchor != null ) {
      selectedChapAnchor.classes.remove( 'selectedCell' );
    }
    DivElement tarEle = evt.target;
    tarEle.classes.add( 'selectedCell' );
    selectedChapAnchor = tarEle;
    
    sChapter = tarEle.id.split('.')[1];
    nVerse = 1;
    updateVerseAnchorLines();
    previewSource = 'Anchors';
    updateVerses();
  }
  
  void updateVerseAnchorLines() {
    int cumChap = BibleModel.CumNumOfChpPerVol[nVolume-1];
    int CumNumOfVrsThisChp = BibleModel.CumNumOfVrsPerChp[ cumChap+nChapter-1 ];
    int CumNumOfVrsNextChp = BibleModel.CumNumOfVrsPerChp[ cumChap+nChapter ];
    int numOfVerse = CumNumOfVrsNextChp - CumNumOfVrsThisChp;
    verseAnchorLines = getAnchorLines( numOfVerse, nVerse, 40 );
  }
  
  void verseAnchorClicked( MouseEvent evt ) {
    if( selectedVerseAnchor != null ) {
      selectedVerseAnchor.classes.remove( 'selectedCell' );
    }
    DivElement tarEle = evt.target;
    tarEle.classes.add( 'selectedCell' );
    selectedVerseAnchor = tarEle;
    
    sVerse = tarEle.id.split('.')[1];
    previewSource = 'Anchors';
    updateVerses();
  }
  
  List<List<Anchor>> getAnchorLines( int numOfAnchors, int selectedAnchor, int numPerLine ) {
    List<Anchor> line = [];
    List<List<Anchor>> lines = [];
    lines.add( line );
    for( int anchorInd=1; anchorInd<=numOfAnchors; anchorInd++ ) {
      if( line.length == numPerLine ) {
        line = [];
        lines.add( line );
      }
      line.add( new Anchor(anchorInd, '${anchorInd%100}', false) );  // pass false instead of anchorInd==selectedAnchor due issue in L58-60
    }
    return lines;
  }
  
  void updateVerses() {
    int verseSub = VsePtr(nVolume, nChapter, nVerse);
    _updateVersesByVerseSub( nVolume, verseSub );
  }
  
  void _updateVersesByVerseSub( int nVol, int verseSub ) {
    versePreviewer.updateVersesByVerseSub(nVol, verseSub, previewSource);
  }
  
  void toProject() {
  }
  
  int VsePtr( int nVol, int nChap, int nVer ) {
    var verseSub = 0;
    if(nVer == null) nVer = 1;
    if(nChap == null ) nChap = 1;
    verseSub = BibleModel.CumNumOfVrsPerChp[BibleModel.CumNumOfChpPerVol[nVol-1] + nChap - 1] + nVer - 1 ;
    return(verseSub);  
  }
  
  /*
   * Get breviation of a volume
   */
  String brevOfVolume( int nVol ) {
    int firstVerseSub = BibleModel.CumNumOfVrsPerChp[ BibleModel.CumNumOfChpPerVol[nVol-1] ];
    String firstVerse = BibleModel.Bible[firstVerseSub];
    String firstWord = firstVerse.substring(0, 1);
    return firstWord;
  }
  
  void handleSaveBookmark( BookmarkVerseEvent evt ) {
    bookmarkMgr.bookmarkVerseUnderPreview( evt.volume, evt.verseSub, evt.label );
  }
  
  void handleViewBookmark( ViewBookmarkEvent evt ) {
    versePreviewer.updateVersesByVerseSub( evt.volume, evt.verseSub, 'Bookmark' );
  }
}

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

void printMaxValues() {
    int maxNumOfChp = 0, maxChpVol = 0;
    int maxNumOfVerse = 0, maxVerseVol = 0, maxVerseChp = 0;
    
    for( int volInd=0; volInd<66; volInd++ ) {
      int CumNumOfChpThisVol = BibleModel.CumNumOfChpPerVol[volInd];
      int CumNumOfChpNextVol = BibleModel.CumNumOfChpPerVol[volInd+1];
      int numOfChp = CumNumOfChpNextVol - CumNumOfChpThisVol;
      if( numOfChp > maxNumOfChp ) {
        maxNumOfChp = numOfChp;
        maxChpVol = volInd + 1;
      }
      for( int chpInd=CumNumOfChpThisVol; chpInd<CumNumOfChpNextVol; chpInd++ ) {
        int numOfVerse = BibleModel.CumNumOfVrsPerChp[chpInd+1] - BibleModel.CumNumOfVrsPerChp[chpInd];
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
