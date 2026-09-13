import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

class DevicePhotoAlbum {
  const DevicePhotoAlbum({
    required this.id,
    required this.name,
    required this.assetCount,
    this.coverBytes,
  });

  final String id;
  final String name;
  final int assetCount;
  final Uint8List? coverBytes;
}

class PhotoAlbumService {
  Future<List<DevicePhotoAlbum>> getAlbums() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (!permission.hasAccess) {
      throw Exception('PHOTO_PERMISSION_DENIED');
    }

    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: false,
    );

    final albums = <DevicePhotoAlbum>[];

    for (final path in paths) {
      final count = await path.assetCountAsync;

      Uint8List? coverBytes;

      if (count > 0) {
        final assets = await path.getAssetListRange(start: 0, end: 1);

        if (assets.isNotEmpty) {
          coverBytes = await assets.first.thumbnailDataWithSize(
            const ThumbnailSize(180, 180),
          );
        }
      }

      albums.add(
        DevicePhotoAlbum(
          id: path.id,
          name: path.name,
          assetCount: count,
          coverBytes: coverBytes,
        ),
      );
    }

    return albums;
  }

  Future<AssetPathEntity?> getAlbumById(String albumId) async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: false,
    );

    for (final path in paths) {
      if (path.id == albumId) {
        return path;
      }
    }

    return null;
  }

  Future<List<AssetEntity>> getPhotosFromAlbum(String albumId) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );

    final album = albums.where((item) => item.id == albumId).firstOrNull;

    if (album == null) {
      return [];
    }

    final count = await album.assetCountAsync;

    if (count == 0) {
      return [];
    }

    return album.getAssetListRange(start: 0, end: count);
  }
}
