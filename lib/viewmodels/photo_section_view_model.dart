import 'package:flutter/material.dart';

class PhotoSectionViewModel extends ChangeNotifier {
  PhotoSectionViewModel();

  final List<String> photos = [];

  String selectedAlbumName = '';

  bool get hasSelectedAlbum => selectedAlbumName.isNotEmpty;

  String get selectAlbumText {
    return hasSelectedAlbum
        ? selectedAlbumName
        : "Please select photo album before your trip start";
  }

  void selectAlbum() {
    // TODO: later open album picker
    selectedAlbumName = "My Trip Album";
    notifyListeners();
  }
}
