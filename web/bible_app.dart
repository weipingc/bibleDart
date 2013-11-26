import 'dart:html';
import 'package:polymer/polymer.dart';

import 'bible_model.dart';
import 'common_event.dart';
import 'quick_input.dart';
import 'bookmark_mgr.dart';
import 'verse_selector.dart';
import 'verse_previewer.dart';

@CustomTag('bible-app')
class BibleApp extends PolymerElement {
  factory BibleApp() => new Element.tag('BibleApp');
  QuickInput quickInput;
  BookmarkMgr bookmarkMgr;
  VerseSelector verseSelector;
  VersePreviewer versePreviewer;
  
  @observable String sQuickInput;
  
  BibleApp.created() : super.created() {
    // printMaxValues();  // For debug
    ShadowRoot shadowRoot = getShadowRoot( 'bible-app' );
    bookmarkMgr = shadowRoot.querySelector( '#bookmarkMgr' );
    quickInput  = shadowRoot.querySelector( '#quickInput' );
    verseSelector = shadowRoot.querySelector( '#verseSelector' );
    versePreviewer = shadowRoot.querySelector( '#versePreviewer' );
    bookmarkMgr.onViewBookmark.listen( handleViewBookmark );
       quickInput.onViewVerse.listen( handleViewVerse );
    verseSelector.onViewVerse.listen( handleViewVerse );
    versePreviewer.onBookmarkVerse.listen( handleSaveBookmark );
     
    sQuickInput = '1.1.1';
    versePreviewer.updateVersesByVerseSub( 1, 0, 'Input'  );
  }
  
  void updateQuickInput( Event evt ) {
    if( sQuickInput.isEmpty ) {
      return;
    }
    int nVolume, nChapter, nVerse;
    var nums = sQuickInput.split( '.' );
    if( nums.length > 0 ) {
      nVolume = int.parse( nums[0] );
    } else {
      nVolume = 1;
    }
    if( nums.length > 1 ) {
      nChapter = int.parse( nums[1] );
    } else {
      nChapter = 1;
    }
    if( nums.length > 2 ) {
      nVerse = int.parse( nums[2] );
    } else {
      nVerse = 1;
    }
    
    int verseSub = BibleModel.VsePtr(nVolume, nChapter, nVerse);
    versePreviewer.updateVersesByVerseSub( nVolume, verseSub, 'Input' );
  }
  
  void handleSaveBookmark( BookmarkVerseEvent evt ) {
    bookmarkMgr.bookmarkVerseUnderPreview( evt.volume, evt.verseSub, evt.label );
  }
  
  void handleViewBookmark( ViewBookmarkEvent evt ) {
    versePreviewer.updateVersesByVerseSub( evt.volume, evt.verseSub, 'Bookmark' );
  }
  
  void handleViewVerse( ViewVerseEvent evt ) {
    versePreviewer.updateVersesByVerseSub( evt.volume, evt.verseSub, 'Selector' );
  }
  
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
