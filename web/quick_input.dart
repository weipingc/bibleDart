import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';

import 'bible_model.dart';
import 'common_event.dart';

@CustomTag('quick-input')
class QuickInput extends PolymerElement {
  factory QuickInput() => new Element.tag('QuickInput');
  
  bool _listening = false;
  bool _cancelled = false;
  void listenning() { _listening = true; }
  void paused()     { _listening = false; }
  void cancelled()  { _cancelled = true; }
  StreamController<ViewVerseEvent> controller;
  Stream<ViewVerseEvent> get onViewVerse => controller.stream;
  
  @observable String sQuickInput;
  
  QuickInput.created() : super.created() {
    controller = new StreamController<ViewVerseEvent>(
        onListen: listenning,
        onPause:  paused,
        onResume: listenning,
        onCancel: cancelled
      );
     
    sQuickInput = '1.1.1';
    controller.add( new ViewVerseEvent(1, 0) );
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
    controller.add( new ViewVerseEvent(nVolume, verseSub) );
  }
  
}
