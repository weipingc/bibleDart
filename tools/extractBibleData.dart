import 'dart:io';

main( List<String> args) {
  if( args.length != 1 ) {
    print( 'Usage: extractBibleData.dart <bible text file>' );
    return;
  }
  String inputFileName = args[0];
  
  File inputFile = new File( inputFileName );
  inputFile.readAsLines().then( (List<String> lines) => processLines(lines) );
}

processLines( List<String> verses ) {
  List<int> CumNumOfChpPerVol = [];
  List<int> CumNumOfVrsPerChp = [];
  String currVolAbrev = '';
  String nextVolAbrev;
  String currChap = '';
  String nextChap;
  RegExp chapVerseRE = new RegExp( r'\d+.\d+' );
  int chapCnt = 0;
  for( int verseCnt=0; verseCnt<verses.length; verseCnt++ ) {
    String verse = verses[verseCnt];
    Match match = chapVerseRE.firstMatch( verse );
    nextVolAbrev = verse.substring( 0, match.start );
    nextChap = match.group( 0 ).split( ':' )[0];
    if( currVolAbrev != nextVolAbrev ) {
      CumNumOfChpPerVol.add( chapCnt++ );
      currVolAbrev = nextVolAbrev;
      CumNumOfVrsPerChp.add( verseCnt );
      currChap = nextChap;
      continue;
    }
    if( currChap != nextChap ) {
      CumNumOfVrsPerChp.add( verseCnt );
      currChap = nextChap;
      chapCnt++;
      continue;
    }
  }
  
  print( 'CumNumOfVrsPerChp=$CumNumOfVrsPerChp' );
  
  print( 'CumNumOfVrsPerChp=[');
  String line = '';
  for( int cnt=1; cnt<=CumNumOfVrsPerChp.length; cnt++ ) {
    if( cnt%10 == 0 ) {
      print( line );
      line = '';
    }
    line += '${CumNumOfVrsPerChp[cnt-1]}, ';
  };
  print( line );
}
