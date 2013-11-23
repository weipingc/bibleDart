library bible.web.app;

import 'dart:html';
import 'package:polymer/polymer.dart';

import 'bibleUtil.dart';
import 'bible-model.dart';

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
  
  VersePreviewer.created() : super.created() {
    print( '[VersePreviewer.created] Enter' );
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
