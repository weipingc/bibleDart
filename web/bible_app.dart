import 'dart:isolate';
import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';

import 'common_event.dart';
import 'quick_input.dart';
import 'bookmark_mgr.dart';
import 'verse_selector.dart';
import 'verse_previewer.dart';
import 'bible_projector.dart';

@CustomTag('bible-app')
class BibleApp extends PolymerElement {
  factory BibleApp() => new Element.tag('BibleApp');
  QuickInput  _quickInput;
  BookmarkMgr _bookmarkMgr;
  VerseSelector  _verseSelector;
  VersePreviewer _versePreviewer;
  
  BibleApp.created() : super.created() {
    ShadowRoot shadowRoot = getShadowRoot( 'bible-app' );
    _quickInput  = shadowRoot.querySelector( '#quickInput' );
    _bookmarkMgr = shadowRoot.querySelector( '#bookmarkMgr' );
    _verseSelector  = shadowRoot.querySelector( '#verseSelector' );
    _versePreviewer = shadowRoot.querySelector( '#versePreviewer' );
    
    _quickInput.onViewVerse.listen( _viewInputedVerse );
    _bookmarkMgr.onViewVerse.listen( _viewBookmarkedVerse );
    _verseSelector.onViewVerse.listen( _viewSelectedVerse );
    _versePreviewer.onSaveVerse.listen( _saveVerse );
    
    _bookmarkMgr.onProjectVerse.listen( _projectBookmarkedVerse );
  }
  
  void _saveVerse( VerseEvent evt ) {
    _bookmarkMgr.bookmarkVerseUnderPreview( evt.volume, evt.verseSub, evt.label );
  }
  
  void _viewInputedVerse( VerseEvent evt ) {
    _handleViewVerseEvent( evt, "Input" );
  }
  
  void _viewBookmarkedVerse( VerseEvent evt ) {
    _handleViewVerseEvent( evt, "Bookmark" );
  }
  
  void _viewSelectedVerse( VerseEvent evt ) {
    _handleViewVerseEvent( evt, "Selector" );
  }
  
  void _handleViewVerseEvent( VerseEvent evt, String source ) {
    _versePreviewer.updateVersesByVerseSub( evt.volume, evt.verseSub, source );
  }
  
  void _projectBookmarkedVerse( VerseEvent evt ) {
    _handleProjectVerseEvent( evt, "Bookmark" );
  }
  
  void _handleProjectVerseEvent( VerseEvent evt, String source ) {
    Future<Isolate> fut = Isolate.spawnUri( new Uri.file(
        'http://localhost:8000/spawned.dart'), [], 'msg_to_subwin' );
    fut.then( (Isolate val) {
      print( '[fut.then] val=$val' );
    });
  }
}
