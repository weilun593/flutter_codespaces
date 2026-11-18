import 'package:flutter/material.dart';
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
}