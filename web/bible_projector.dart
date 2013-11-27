import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

import 'bible_model.dart';
import 'common_event.dart';

@CustomTag('bible-projector')
class BibleProjector extends PolymerElement {
  factory BibleProjector() => new Element.tag('BibleProjector');
  
  int nVolume;
  int startVerseSub;
  int indOfLastVerseOfThisVol;
  
  @observable List<VerseItem> verseList;
  @observable String previewSource = 'Unknown';
  @observable String previewTitle;
  
  @observable int nPageSize = 3;
  @observable String get sPageSize => nPageSize.toString();
  @observable   void set sPageSize( String val ) {
           if(val.isEmpty) nPageSize=3; else nPageSize = int.parse(val);
         }
  
  StreamControllerProvider<VerseEvent> streamControllerProvider;
  StreamController<VerseEvent> controller;
  Stream<VerseEvent> get onSaveVerse => controller.stream;
  
  BibleProjector.created() : super.created() {
    print( '[BibleProjector.created] Enter' );
    streamControllerProvider = new StreamControllerProvider<VerseEvent>();
    controller = streamControllerProvider.getController();
  }
  
  void sPageSizeChanged(evt) {
    sPageSize = evt.target.value;
    _updateVerses();
  }
  
  void viewPreviousPage() {
    int indOfFirstVerseOfThisVol = BibleModel.CumNumOfVrsPerChp[ BibleModel.CumNumOfChpPerVol[nVolume-1] ];
    if( startVerseSub <= indOfFirstVerseOfThisVol  ) {
      return;
    } else if( startVerseSub - nPageSize <= indOfFirstVerseOfThisVol){
      startVerseSub = indOfFirstVerseOfThisVol;
    } else {
      startVerseSub -= nPageSize;
    }
    previewSource = "Paging";
    _updateVerses();
  }
  
  void viewNextPage() {
    if( nVolume>66 ) {
      return;
    }
    if( startVerseSub + nPageSize > indOfLastVerseOfThisVol  ) {
      return;
    }
    startVerseSub += nPageSize;
    previewSource = "Paging";
    _updateVerses();
  }
  
  void bookmarkVerseUnderPreview() {
    VerseEvent evt = new VerseEvent( nVolume, startVerseSub, previewTitle );
    controller.add( evt );
  }
  
  void _updateVerses() {
    updateVersesByVerseSub(nVolume, startVerseSub, previewSource);
  }
  
  void updateVersesByVerseSub( int nVol, int verseSub, String previewSource ) {
    this.nVolume = nVol;
    this.startVerseSub = verseSub;
    this.previewSource = previewSource;
    int cumNumOfChpNextVol = BibleModel.CumNumOfChpPerVol[nVolume];
    indOfLastVerseOfThisVol = BibleModel.CumNumOfVrsPerChp[cumNumOfChpNextVol] - 1;
    List<VerseItem> vList = [];
    for( var cnt=0; cnt<nPageSize && startVerseSub+cnt<=indOfLastVerseOfThisVol; cnt++ ) {
      vList.add( new VerseItem('${startVerseSub+cnt}', BibleModel.Bible[startVerseSub+cnt]) );
    }
    verseList = vList;
    String verseText = verseList[0].verseText;
    previewTitle = getTitleFromVerseText( verseText );
  }
  
  String getTitleFromVerseText( String verseText ) {
    return "$nVolume.${verseText.substring(0, verseText.indexOf(' ') )}";
  }

}

class VerseItem {
  String verseSub;
  String verseText;
  
  VerseItem( this.verseSub, this.verseText );
  
  String toString() => 'VerseItem($verseSub, $verseText)';
}

