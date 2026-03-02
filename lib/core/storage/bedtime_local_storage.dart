import 'dart:convert';

import 'package:bedtime_stories/app_ui/login/models/bedtime_login_response.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BedtimeLocalStorage {
  static const _userData = "login_user";
  static const _userId = "login_user_id";
  static const _menuRights = "menu_rights";
  static const _selectedProjectId = "selected_project_id";
  static const _selectedProjectName = "selected_project_name";
  static Map<String, dynamic>? _cachedUserData;
  static int? _cachedUserId;
  static Set<String>? _cachedPermissionSet;
  static Future<Map<String, dynamic>>? _userDataFuture;
  static Future<int?>? _userIdFuture;
  static Future<Set<String>>? _permissionSetFuture;

  static final ValueNotifier<int> selectedProjectChangeNotifier =
      ValueNotifier<int>(0);
  static final ValueNotifier<int> paymentDataChangeNotifier =
      ValueNotifier<int>(0);

  static void _notifySelectedProjectChanged() {
    selectedProjectChangeNotifier.value++;
  }

  static void notifyPaymentDataChanged() {
    paymentDataChangeNotifier.value++;
  }

  /// Save complete login payload + backward-compatible top-level user keys.
  static Future<void> saveLoginUser(BedtimeLoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();

    final loginPayload = response.toJson();
    loginPayload.addAll({
      // Backward compatibility for existing pages.
      "userId": response.user.nUserId,
      "username": response.user.cCusername,
      "email": response.user.cEmail,
      "companyId": response.user.nCompanyID,
    });

    final menuRightsPayload = response.menuRights.map((e) {
      final map = e.toJson();
      // Backward compatibility aliases.
      map["module"] = e.cModule;
      map["menus"] = e.cMenus;
      return map;
    }).toList();

    _cachedUserData = Map<String, dynamic>.from(loginPayload);
    _cachedUserId = response.user.nUserId;
    _cachedPermissionSet = _buildPermissionSet(menuRightsPayload);
    _userDataFuture = null;
    _userIdFuture = null;
    _permissionSetFuture = null;

    await prefs.setString(_userData, jsonEncode(loginPayload));
    await prefs.setInt(_userId, response.user.nUserId);
    await prefs.setString(_menuRights, jsonEncode(menuRightsPayload));
  }

  /// Check if user already logged in.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userData) != null;
  }

  /// Returns the stored login data map.
  static Future<Map<String, dynamic>> getUserData() async {
    final cached = _cachedUserData;
    if (cached != null) return cached;

    final inflight = _userDataFuture;
    if (inflight != null) return inflight;

    _userDataFuture = () async {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_userData);
      if (data == null) return <String, dynamic>{};

      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        _cachedUserData = decoded;
        return decoded;
      }
      if (decoded is Map) {
        final mapped = Map<String, dynamic>.from(decoded);
        _cachedUserData = mapped;
        return mapped;
      }
      return <String, dynamic>{};
    }();

    try {
      return await _userDataFuture!;
    } finally {
      _userDataFuture = null;
    }
  }

  static Future<int?> getUserId() async {
    final cachedUserId = _cachedUserId;
    if (cachedUserId != null && cachedUserId > 0) return cachedUserId;

    final inflight = _userIdFuture;
    if (inflight != null) return inflight;

    _userIdFuture = () async {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt(_userId);
      if (storedUserId != null && storedUserId > 0) {
        _cachedUserId = storedUserId;
        return storedUserId;
      }

      // Backward-compatible fallback for older saved sessions.
      final userData = await getUserData();
      final rawUserData = userData["user"];
      final nestedUser = rawUserData is Map ? rawUserData : null;
      final rawUserId =
          userData["userId"] ?? userData["nUserId"] ?? nestedUser?["nUserId"];
      final resolved = int.tryParse(rawUserId?.toString() ?? "") ?? 0;
      if (resolved > 0) {
        _cachedUserId = resolved;
        await prefs.setInt(_userId, resolved);
        return resolved;
      }
      return null;
    }();

    try {
      return await _userIdFuture!;
    } finally {
      _userIdFuture = null;
    }
  }

  /// Returns stored menu rights payload list.
  static Future<List<Map<String, dynamic>>> getMenuRightsData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_menuRights);
    if (data == null) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(data);
    if (decoded is! List) return <Map<String, dynamic>>[];

    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Set<String> _splitPermissions(String raw) {
    return raw
        .split(",")
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  static Set<String> _buildPermissionSet(List<Map<String, dynamic>> rights) {
    final permissionSet = <String>{};
    for (final row in rights) {
      final menusRaw = (row["cMenus"] ?? row["menus"] ?? "").toString();
      final modulesRaw = (row["cModule"] ?? row["module"] ?? "").toString();
      permissionSet.addAll(_splitPermissions(menusRaw));
      permissionSet.addAll(_splitPermissions(modulesRaw));
    }
    return permissionSet;
  }

  /// Flatten all permission tokens from cMenus/cModule stored payload.
  static Future<Set<String>> getMenuPermissionSet() async {
    final cached = _cachedPermissionSet;
    if (cached != null) return cached;

    final inflight = _permissionSetFuture;
    if (inflight != null) return inflight;

    _permissionSetFuture = () async {
      final rights = await getMenuRightsData();
      final permissionSet = _buildPermissionSet(rights);
      _cachedPermissionSet = permissionSet;
      return permissionSet;
    }();

    try {
      return await _permissionSetFuture!;
    } finally {
      _permissionSetFuture = null;
    }
  }

  static Future<bool> hasMenuPermission(String permission) async {
    final normalized = permission.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    final permissionSet = await getMenuPermissionSet();
    return permissionSet.contains(normalized);
  }

  static bool hasMenuPermissionSync(String permission) {
    final normalized = permission.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    final permissionSet = _cachedPermissionSet;
    if (permissionSet == null) return false;
    return permissionSet.contains(normalized);
  }

  /// Clear login session and selected project.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedUserData = null;
    _cachedUserId = null;
    _cachedPermissionSet = null;
    _userDataFuture = null;
    _userIdFuture = null;
    _permissionSetFuture = null;
    await prefs.remove(_userData);
    await prefs.remove(_userId);
    await prefs.remove(_menuRights);
    await prefs.remove(_selectedProjectId);
    await prefs.remove(_selectedProjectName);
    _notifySelectedProjectChanged();
  }

  /// Save selected project.
  static Future<void> saveSelectedProject({
    required int projectId,
    required String projectName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedProjectId, projectId);
    await prefs.setString(_selectedProjectName, projectName);
    _notifySelectedProjectChanged();
  }

  /// Get selected project name.
  static Future<String> getSelectedProjectName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedProjectName) ?? "";
  }

  /// Get selected project id.
  static Future<int> getSelectedProjectId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedProjectId) ?? 0;
  }

  /// Clear selected project (optional).
  static Future<void> clearSelectedProject() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedProjectId);
    await prefs.remove(_selectedProjectName);
    _notifySelectedProjectChanged();
  }

  /// Get logged username.
  static Future<String> getUserName() async {
    final userData = await getUserData();
    return userData["username"] ?? "";
  }
}
