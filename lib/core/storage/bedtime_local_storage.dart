import 'dart:convert';
import 'package:bedtime_stories/app_ui/login/models/bedtime_login_response.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BedtimeLocalStorage {
  static const _userData = "login_user";
  static const _menuRights = "menu_rights";
  static final ValueNotifier<int> selectedProjectChangeNotifier =
      ValueNotifier<int>(0);

  static void _notifySelectedProjectChanged() {
    selectedProjectChangeNotifier.value++;
  }

  /// ✅ Save Login User Session
  static Future<void> saveLoginUser(BedtimeLoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _userData,
      jsonEncode({
        "userId": response.user.nUserId,
        "username": response.user.cCusername,
        "email": response.user.cEmail,
        "companyId": response.user.nCompanyID,
      }),
    );

    await prefs.setString(
      _menuRights,
      jsonEncode(
        response.menuRights
            .map((e) => {
                  "module": e.cModule,
                  "menus": e.cMenus,
                })
            .toList(),
      ),
    );
  }

  /// ✅ Check if User Already Logged In (Splash Use)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userData) != null;
  }

  /// ✅ Get Stored User Data (Next Pages Use)
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_userData);

    if (data == null) return {};

    return jsonDecode(data);
  }

  /// ✅ Clear Only Session Data (Logout)
 static Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove(_userData);
 await prefs.remove(_menuRights);

  await prefs.remove(_selectedProjectId);
  await prefs.remove(_selectedProjectName);
  _notifySelectedProjectChanged();
}

  static const _selectedProjectId = "selected_project_id";
static const _selectedProjectName = "selected_project_name";

/// ✅ Save Selected Project
static Future<void> saveSelectedProject({
  required int projectId,
  required String projectName,
}) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt(_selectedProjectId, projectId);
  await prefs.setString(_selectedProjectName, projectName);
  _notifySelectedProjectChanged();
}

/// ✅ Get Selected Project Name
static Future<String> getSelectedProjectName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_selectedProjectName) ?? "";
}

/// ✅ Get Selected Project Id
static Future<int> getSelectedProjectId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_selectedProjectId) ?? 0;
}

/// ✅ Clear Selected Project (Optional)
static Future<void> clearSelectedProject() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_selectedProjectId);
  await prefs.remove(_selectedProjectName);
  _notifySelectedProjectChanged();
}
/// ✅ Get Logged Username
static Future<String> getUserName() async {
  final userData = await getUserData();
  return userData["username"] ?? "";
}

}
