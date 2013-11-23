library bible.web.app;

import 'dart:html';
import 'package:polymer/polymer.dart';

import 'bibleUtil.dart';
import 'verse_previewer.dart';

@CustomTag('bookmark-mgr')
class BookmarkMgr extends PolymerElement {
  factory BookmarkMgr() => new Element.tag('BookmarkMgr');
  VersePreviewer versePreviewer;
  
  @observable List<Bookmark> bookmarks = [];
  
  BookmarkMgr.created() : super.created() {
  }
  
  void bookmarkClicked( MouseEvent evt ) {
//    hisItem.selected=true;
  }
  
  void bookmarkDblClicked( MouseEvent evt ) {
    Element tarEle = evt.target;
    _previewBookmark( tarEle );
  }
  
  void previewBookmark( MouseEvent evt ) {
    ShadowRoot bibleAppShadowRoot = getShadowRoot( 'bible-app' );
    List<InputElement> hisItemRadios = bibleAppShadowRoot.querySelectorAll( '[name=bookmark]' );
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
    
//    continue_from_here
    
    
    ShadowRoot bibleAppShadowRoot = getShadowRoot( 'bible-app' );
    versePreviewer = bibleAppShadowRoot.querySelector( '#versePreviewer' );
    versePreviewer.updateVersesByVerseSub(bm.volume, verseSub, 'Bookmark');
  }
  
  Bookmark findBookmarkByVerseSub( int verseSub ) {
    for( Bookmark bm in bookmarks ) {
      if( bm.verseSub == verseSub )
        return bm;
    }
  }
  
  void bookmarkVerseUnderPreview() {
    ShadowRoot bibleAppShadowRoot = getShadowRoot( 'bible-app' );
    versePreviewer = getShadowRoot( 'bible-app' ).querySelector( '#versePreviewer' );
    versePreviewer = bibleAppShadowRoot.querySelector( '#versePreviewer' );
    VerseItem firstVerse = versePreviewer.verseList[0];
    for( Bookmark bookmark in bookmarks ) {
      if( bookmark.verseSub == firstVerse.verseSub ) {
        return;
      }
    }
    String verseText = firstVerse.verseText;
    String bookmarkLabel = getTitleFromVerseText( verseText );
    List<Bookmark> newBookmarks = [ new Bookmark(versePreviewer.nVolume, firstVerse.verseSub, bookmarkLabel, true) ];
    bookmarks.forEach( (E) => E.selected = false);
    newBookmarks.addAll( bookmarks );
    newBookmarks.sort( (Bookmark bm1, Bookmark bm2) => int.parse(bm1.verseSub).compareTo( int.parse(bm2.verseSub) ) );
    bookmarks = newBookmarks;
  }
  
  String getTitleFromVerseText( String verseText ) {
    return "${versePreviewer.nVolume}.${verseText.substring(0, verseText.indexOf(' ') )}";
  }
}

class BookmarkEvent {
  
}
