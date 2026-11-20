//import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  /// 取得目前位置的非同步函式
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 檢查手機的定位服務 (GPS) 是否有開啟
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('定位服務未開啟，請至手機設定開啟 GPS。');
    }

    // 2. 檢查 App 的定位權限狀態
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 如果還沒取得權限，跳出系統視窗向使用者請求
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('使用者拒絕了定位權限。');
      }
    }

    // 3. 如果使用者勾選「永不再詢問」或去設定裡關閉了權限
    if (permission == LocationPermission.deniedForever) {
      return Future.error('定位權限已被永久拒絕，請至手機設定手動開啟。');
    }

    // 4. 權限皆通過，取得目前經緯度
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, // 高精準度 (GPS)
      ),
    );
  }

  static Future<String> determineAddress() async {
    final position = await determinePosition();
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isEmpty) {
      throw StateError('找不到目前位置的地址，請稍後再試。');
    }

    final placemark = placemarks.first;
    final parts = <String>[];
    for (final value in [
      placemark.administrativeArea,
      placemark.subAdministrativeArea,
      placemark.locality,
      placemark.subLocality,
      placemark.thoroughfare,
      placemark.subThoroughfare,
    ]) {
      final part = value?.trim();
      if (part != null && part.isNotEmpty && !parts.contains(part)) {
        parts.add(part);
      }
    }
    if (parts.isEmpty) {
      throw StateError('找不到目前位置的地址，請稍後再試。');
    }
    return parts.join('');
  }
}