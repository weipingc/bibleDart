import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

import 'bible_app.dart';
import 'bible_model.dart';

@CustomTag('verse-previewer')
class VersePreviewer extends PolymerElement {
  factory VersePreviewer() => new Element.tag('VersePreviewer');
  
  @observable int nVolume;
  int startVerseSub;
  
  @observable List<VerseItem> verseList;
  @observable String previewSource = 'Unknown';
  @observable String previewTitle;
  
  @observable int nPageSize = 3;
  @observable String get sPageSize => nPageSize.toString();
  @observable   void set sPageSize( String val ) {
           if(val.isEmpty) nPageSize=3; else nPageSize = int.parse(val);
         }
  
  bool _listening = false;
  bool _cancelled = false;
  void listenning() {
    _listening = true;
  }
  void paused()  {
    _listening = false;
  }
  void cancelled()  {
    _cancelled = true;
  }
  StreamController<BookmarkVerseEvent> controller;
  Stream<BookmarkVerseEvent> get onBookmarkVerse => controller.stream;
  
  VersePreviewer.created() : super.created() {
    controller = new StreamController<BookmarkVerseEvent>(
        onListen: listenning,
        onPause:  paused,
        onResume: listenning,
        onCancel: cancelled
      );
  }
  
  void sPageSizeChanged(evt) {
    sPageSize = evt.target.value;
    updateVersesByVerseSub(nVolume, startVerseSub, previewSource);
  }
  
  void bookmarkVerseUnderPreview() {
    BookmarkVerseEvent evt = new BookmarkVerseEvent( nVolume, startVerseSub, previewTitle );
    controller.add( evt );
  }
  
  void updateVersesByVerseSub( int nVol, int verseSub, String previewSource ) {
    this.nVolume = nVol;
    this.startVerseSub = verseSub;
    this.previewSource = previewSource;
    List<VerseItem> vList = [];
    for( var cnt=0; cnt<nPageSize; cnt++ ) {
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

class BookmarkVerseEvent {
  int volume;
  int verseSub;
  String label;
  
  BookmarkVerseEvent( this.volume, this.verseSub, this.label );
}
