import 'dart:io';

import 'package:mealy/models/tag.dart';
import 'package:mealy/models/tezina.dart';

class Recept {
  final String ime;
  final String opis;
  final int brOsoba;
  final int vrPripreme;
  final Tezina tezina;
  final List<String> sastojci;
  final List<String> koraci;
  final List<Tag> tagovi;
  final File? slika;

  Recept({
    required this.ime,
    required this.opis,
    required this.brOsoba,
    required this.vrPripreme,
    required this.tezina,
    required this.sastojci,
    required this.koraci,
    required this.tagovi,
    this.slika,
  });
}
