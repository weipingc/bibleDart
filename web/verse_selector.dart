import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

import 'bible_model.dart';
import 'common_event.dart';

@CustomTag('verse-selector')
class VerseSelector extends PolymerElement {
  factory VerseSelector() => new Element.tag('VerseSelector');
  
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
  
  bool _listening = false;
  bool _cancelled = false;
  void listenning() { _listening = true; }
  void paused()     { _listening = false; }
  void cancelled()  { _cancelled = true; }
  StreamController<ViewVerseEvent> controller;
  Stream<ViewVerseEvent> get onViewVerse => controller.stream;
  
  void updateVerses() {
    int verseSub = BibleModel.VsePtr(nVolume, nChapter, nVerse);
    ViewVerseEvent evt = new ViewVerseEvent( nVolume, verseSub );
    controller.add( evt );
  }
  
  VerseSelector.created() : super.created() {
    controller = new StreamController<ViewVerseEvent>(
        onListen: listenning,
        onPause:  paused,
        onResume: listenning,
        onCancel: cancelled
      );
    nVolume = 1;
    nChapter = 1;
    nVerse = 1;
    updateVolumeAnchorLines();
    updateChapterAnchorLines();
    updateVerseAnchorLines();
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
      String brev = BibleModel.brevOfVolume( volInd );
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
  
}

class Anchor {
  int id;
  String text;
  bool selected;
  
  Anchor( this.id, this.text, this.selected );
  String get selectedClass => selected ? 'selectedCell' : '';
  
  String toString() => 'Anchor($id, $text, $selected)';
}
