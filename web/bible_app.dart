library bible.web.app;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'dart:js';

import 'bibleUtil.dart';
import 'verse_previewer.dart';

@CustomTag('bible-app')
class BibleApp extends PolymerElement {
  factory BibleApp() => new Element.tag('BibleApp');
  VersePreviewer versePreviewer;
  
  static final List<String> Bible = context['Bible'];
  static final List<int> CumNumOfChpPerVol = context['CumNumOfChpPerVol'];
  static final List<int> CumNumOfVrsPerChp = context['CumNumOfVrsPerChp'];

  @observable List<List<Anchor>> volAnchorLines;
  @observable List<List<Anchor>> chapAnchorLines;
  @observable List<List<Anchor>> verseAnchorLines;
  
  @observable List<VerseItem> verseList;
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
  @observable String get sNumOfVerse => nNumOfVerse.toString();
  @observable void   set sNumOfVerse( String val ) {
           if(val.isEmpty) nNumOfVerse=1; else nNumOfVerse = int.parse(val);
         }
  
  BibleApp.created() : super.created() {
    // printMaxValues();  // For debug
    
    versePreviewer = getShadowRoot( 'bible-app' ).querySelector( '#versePreviewer' );
    
    sQuickInput = '1.1.1';
    nVolume = 1;
    nChapter = 1;
    nVerse = 1;
    updateVolumeAnchorLines();
    updateChapterAnchorLines();
    updateVerseAnchorLines();
    previewSource = 'Input';
    updateVerses();
    /* the following querySelector causes:
     * Exception: SyntaxError: Internal Dartium Exception at BibleApp.BibleApp.created (bible_app.dart:58:59)
     * Dartium could not find element nested two level below template?
    ShadowRoot bibleAppShadowRoot = getShadowRoot( 'bible-app' );
      selectedVolAnchor = bibleAppShadowRoot.querySelector( '#vol.1' );
     selectedChapAnchor = bibleAppShadowRoot.querySelector( '#chap.1' );
    selectedVerseAnchor = bibleAppShadowRoot.querySelector( '#verse.1' );
    */
  }
  
  void updateQuickInput() {
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
    int CumNumOfChpThisVol = CumNumOfChpPerVol[nVolume-1];
    int CumNumOfChpNextVol = CumNumOfChpPerVol[nVolume];
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
    int cumChap = CumNumOfChpPerVol[nVolume-1];
    int CumNumOfVrsThisChp = CumNumOfVrsPerChp[ cumChap+nChapter-1 ];
    int CumNumOfVrsNextChp = CumNumOfVrsPerChp[ cumChap+nChapter ];
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
  
  @observable List<Bookmark> bookmarks = [];
  
  void updateVerses() {
    int verseSub = VsePtr(nVolume, nChapter, nVerse);
    _updateVersesByVerseSub( nVolume, verseSub );
  }
  
  void _updateVersesByVerseSub( int nVol, int verseSub ) {
    versePreviewer.updateVersesByVerseSub(nVol, verseSub, previewSource);
  }
  
  void toProjector() {
  }
  
  int VsePtr( int nVol, int nChap, int nVer ) {
    var verseSub = 0;
    if(nVer == null) nVer = 1;
    if(nChap == null ) nChap = 1;
    verseSub = CumNumOfVrsPerChp[CumNumOfChpPerVol[nVol-1] + nChap - 1] + nVer - 1 ;
    return(verseSub);  
  }
  
  /*
   * Get breviation of a volume
   */
  String brevOfVolume( int nVol ) {
    int firstVerseSub = CumNumOfVrsPerChp[ CumNumOfChpPerVol[nVol-1] ];
    String firstVerse = Bible[firstVerseSub];
    String firstWord = firstVerse.substring(0, 1);
    return firstWord;
  }
}
