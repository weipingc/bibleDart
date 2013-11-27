import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

import 'common_event.dart';

@CustomTag('bookmark-mgr')
class BookmarkMgr extends PolymerElement {
  factory BookmarkMgr() => new Element.tag('BookmarkMgr');
  ObservableList<Bookmark> bookmarks = new ObservableList<Bookmark>();
  
  StreamControllerProvider<VerseEvent> streamControllerProvider;
  StreamController<VerseEvent> controller;
  StreamController<VerseEvent> projController;
  Stream<VerseEvent> get onViewVerse => controller.stream;
  Stream<VerseEvent> get onProjectVerse => projController.stream;
  
  BookmarkMgr.created() : super.created() {
    streamControllerProvider = new StreamControllerProvider<VerseEvent>();
    projController = streamControllerProvider.getController();
    controller = streamControllerProvider.getController();
  }
  
  void bookmarkDblClicked( MouseEvent evt ) {
    Element tarEle = evt.target;
    _previewBookmark( tarEle );
  }
  
  void previewBookmark( MouseEvent evt ) {
    InputElement inputEle = getSelectedInputElement();
    if( inputEle != null ) {
      _previewBookmark( inputEle );
    }
  }
  
  void projectBookmark( MouseEvent evt ) {
    InputElement inputEle = getSelectedInputElement();
    if( inputEle != null ) {
      Bookmark bm = findBookmarkByVerseSub( inputEle );
      VerseEvent evt = new VerseEvent( bm.volume, bm.verseSub, bm.label );
      projController.add( evt );
    }
  }
  
  void deleteBookmark( MouseEvent evt ) {
    InputElement inputEle = getSelectedInputElement();
    if( inputEle != null ) {
      Bookmark bm = findBookmarkByVerseSub( inputEle );
      bookmarks.remove( bm );
    }
  }
  
  InputElement getSelectedInputElement() {
    ShadowRoot bookmarkMgrShadowRoot = getShadowRoot( 'bookmark-mgr' );
    List<InputElement> hisItemRadios = bookmarkMgrShadowRoot.querySelectorAll( '[name=bookmark]' );
    for( InputElement inputEle in hisItemRadios ) {
      if( inputEle.checked ) {
        return inputEle;
      }
    }
    return null;
  }
  
  void _previewBookmark( Element bmElement ) {
    Bookmark bm = findBookmarkByVerseSub( bmElement );
    VerseEvent evt = new VerseEvent( bm.volume, bm.verseSub, bm.label );
    controller.add( evt );
  }
  
  Bookmark findBookmarkByVerseSub( Element bmElement ) {
    int verseSub = int.parse( bmElement.id.split( '.' )[1] );
    for( Bookmark bm in bookmarks ) {
      if( bm.verseSub == verseSub )
        return bm;
    }
  }
  
  void bookmarkVerseUnderPreview( int nVol, int nStartVerse, String label) {
    bookmarks.forEach( (E) => E.selected = false);
    for( Bookmark bookmark in bookmarks ) {
      if( bookmark.verseSub == nStartVerse ) {
        bookmark.selected = true;
        return;
      }
    }
    bookmarks.add( new Bookmark(nVol, nStartVerse, label, true) );
    bookmarks.sort( (Bookmark bm1, Bookmark bm2) => bm1.verseSub.compareTo(bm2.verseSub) );
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
