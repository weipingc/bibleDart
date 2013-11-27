import 'dart:html';

void main( ) {
  print( 'from spawned' );
  Window projectorWin;
  String projWinFeatures = 'location=no,menubar=no,status=no';
  projectorWin = window.open( 'projector.html', 'projector', projWinFeatures );
}