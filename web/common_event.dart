import 'dart:async';

class VerseEvent {
  int volume;
  int verseSub;
  String label;
  
  VerseEvent( this.volume, this.verseSub, [this.label] );
}

class StreamControllerProvider<Evt> {
  StreamController<Evt> getController() {
    bool _listening = false;
    bool _cancelled = false;
    void listenning() { _listening = true; }
    void paused()     { _listening = false; }
    void cancelled()  { _cancelled = true; }
    StreamController<Evt> controller = new StreamController<Evt>(
        onListen: listenning,
        onPause:  paused,
        onResume: listenning,
        onCancel: cancelled
      );
    return controller;
  }
}
