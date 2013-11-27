import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';

import 'bible_model.dart';
import 'common_event.dart';

@CustomTag('quick-input')
class QuickInput extends PolymerElement {
  factory QuickInput() => new Element.tag('QuickInput');
  
  StreamControllerProvider<VerseEvent> streamControllerProvider;
  StreamController<VerseEvent> controller;
  Stream<VerseEvent> get onViewVerse => controller.stream;
  
  @observable String sQuickInput;
  
  QuickInput.created() : super.created() {
    streamControllerProvider = new StreamControllerProvider<VerseEvent>();
    controller = streamControllerProvider.getController();
    
    sQuickInput = '1.1.1';
    controller.add( new VerseEvent(1, 0) ); // Display the first verse
  }
  
  void updateQuickInput( Event evt ) {
    if( sQuickInput.isEmpty )
      return;
    
    int nVolume = 1, nChapter = 1, nVerse = 1;
    var nums = sQuickInput.split( '.' );
    if( nums.length > 0 )
      nVolume = int.parse( nums[0] );
    if( nums.length > 1 )
      nChapter = int.parse( nums[1] );
    if( nums.length > 2 )
      nVerse = int.parse( nums[2] );
    
    int verseSub = BibleModel.VsePtr( nVolume, nChapter, nVerse );
    controller.add( new VerseEvent(nVolume, verseSub) );
  }
}
