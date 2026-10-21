import 'package:flutter/material.dart';

/// @desc 底部Tab切换状态
class TabProvider extends ChangeNotifier {
  int _tabIndex = 0;
  // 是否隐藏底部导航（进入子页面时）
  bool _isHide = false;

  int get tabIndex => _tabIndex;
  bool get isHide => _isHide;

  void updateTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  void updateHide(bool hide) {
    _isHide = hide;
    notifyListeners();
  }
}
