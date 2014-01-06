#!/usr/bin/env dart

import 'package:args/args.dart';

import 'package:polymer/builder.dart';

void main(args) {
  build(entryPoints: ['web/index.html'], options: parseOptions(args));
}
