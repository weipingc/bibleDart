import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:angular/angular.dart';

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
    String projWinFeatures = 'location=no,menubar=no,status=no';
    Window projWin = window.open( 'projector.html', 'projector', projWinFeatures );
    Document docObj = projWin.document;
    print( 'Project window open?' );
    docObj.writeln('<!DOCTYPE HTML>\n<HEAD>\n<TITLE>Verse projection</TITLE>\n'
        +'<meta http-equiv="Content-Type" content="text/html; charset=big5"/>\n<style type="text/css">body{font-size: 40pt; padding-left: 2cm;}</style>\n</HEAD>'
        +'<BODY BGCOLOR=WHITE TEXT=BLACK>');
      var text = 'In the beginning, God created the heavens and the earth';
      docObj.writeln( text );
      docObj.writeln('</P>\n</BODY>\n</HTML>');
      docObj.close();

    /*
    String projWinFeatures = 'location=no,menubar=no,status=no';
    Window projectorWin = window.open( 'about:blank', 'projector', projWinFeatures );
    print( 'Project window open?' );
    DivElement newChild = new DivElement();
    newChild.innerHtml = '<h1>Hi</h1>';
    projectorWin.document.append(newChild);
    */
    /* The above solution did not work:
      Uncaught Error: HierarchyRequestError: Internal Dartium Exception
      #1      BibleApp._handleProjectVerseEvent ( bible_app.dart:65:33)
     */

    /* This solution didn't work either, no output from spawned.dart
    Future<Isolate> fut = Isolate.spawnUri( new Uri.file(
        'http://127.0.0.1:3030/bibleDart/web/spawned.dart'), [], 'msg_to_subwin' );
    fut.then( (Isolate val) {
      print( '[fut.then] val=$val' );
    });
    */

    /* The third solution also fails, got this error: The built-in library 'dart:io' is not available on Dartium.
    io.File projFile = new io.File( 'projFile.html' );
    projFile.openWrite( mode: io.FileMode.WRITE, encoding: UTF8 );
    projFile.writeAsStringSync( '<!DOCTYPE html><html><head><title>Projector</title></head><body><h1>Hi</h1></body></html>' );
    String projWinFeatures = 'location=no,menubar=no,status=no';
    Window projectorWin = window.open( 'projFile.html', 'projector', projWinFeatures );
    print( 'Project window open?' );
    */
  }
}
