import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'package:polymer/polymer.dart';

@CustomTag('bookmark-mgr')
class BookmarkMgr extends PolymerElement {
  factory BookmarkMgr() => new Element.tag('BookmarkMgr');
  @observable List<Bookmark> bookmarks = [];
  
  bool _listening = false;
  bool _cancelled = false;
  void listenning() { _listening = true; }
  void paused()  { _listening = false; }
  void cancelled()  { _cancelled = true; }
  StreamController<ViewBookmarkEvent> controller;
  Stream<ViewBookmarkEvent> get onViewBookmark => controller.stream;
  
  BookmarkMgr.created() : super.created() {
    controller = new StreamController<ViewBookmarkEvent>(
        onListen: listenning,
        onPause:  paused,
        onResume: listenning,
        onCancel: cancelled
      );
  }
  
  void bookmarkClicked( MouseEvent evt ) {
//    hisItem.selected=true;
  }
  
  void bookmarkDblClicked( MouseEvent evt ) {
    Element tarEle = evt.target;
    _previewBookmark( tarEle );
  }
  
  void previewBookmark( MouseEvent evt ) {
    ShadowRoot bookmarkMgrShadowRoot = getShadowRoot( 'bookmark-mgr' );
    List<InputElement> hisItemRadios = bookmarkMgrShadowRoot.querySelectorAll( '[name=bookmark]' );
    for( InputElement inputEle in hisItemRadios ) {
      if( inputEle.checked ) {
        _previewBookmark( inputEle );
        break;
      }
    }
  }
  
  void _previewBookmark( Element bmElement ) {
    int verseSub = int.parse( bmElement.id.split( '.' )[1] );
    Bookmark bm = findBookmarkByVerseSub( verseSub );
    
    ViewBookmarkEvent evt = new ViewBookmarkEvent( bm.volume, bm.verseSub, bm.label );
    controller.add( evt );
  }
  
  Bookmark findBookmarkByVerseSub( int verseSub ) {
    for( Bookmark bm in bookmarks ) {
      if( bm.verseSub == verseSub )
        return bm;
    }
  }
  
  void bookmarkVerseUnderPreview( int nVol, int nStartVerse, String label) {
    for( Bookmark bookmark in bookmarks ) {
      if( bookmark.verseSub == nStartVerse ) {
        return;
      }
    }
    List<Bookmark> newBookmarks = [ new Bookmark(nVol, nStartVerse, label, true) ];
    bookmarks.forEach( (E) => E.selected = false);
    newBookmarks.addAll( bookmarks );
    newBookmarks.sort( (Bookmark bm1, Bookmark bm2) => bm1.verseSub.compareTo(bm2.verseSub) );
    bookmarks = newBookmarks;
  }
  
}

class Bookmark {
  int volume;
  int verseSub;
  String label;
  bool selected;
  
  Bookmark( this.volume, this.verseSub, this.label, this.selected );
  String get selectedClass => selected ? 'selectedBookmark' : '';
  
  String toString() => 'Bookmark($verseSub, $label, $selected)';
}

class ViewBookmarkEvent {
  int volume;
  int verseSub;
  String label;
  
  ViewBookmarkEvent( this.volume, this.verseSub, this.label );
}
