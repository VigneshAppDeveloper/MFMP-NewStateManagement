import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_food_my_price/pages/Map/map_page.dart';
import 'package:my_food_my_price/pages/flash_sale_page.dart';
import 'package:my_food_my_price/pages/home_page.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/widgets/dilogue/dilogue.dart';

class AppPages extends StatefulWidget {
  final int initialTab;
  const AppPages({super.key, this.initialTab = 0});

  @override
  State<AppPages> createState() => AppPagesState();
}

class AppPagesState extends State<AppPages> {
  late int _currentIndex;
  DateTime? lastBackPressTime;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _pages.addAll([HomePage(), MapPage(), FlashSalePage()]);

    // set correct initial style
    _applyStatusBarStyle(_currentIndex);
  }

  // ---------- ADD THIS ----------
  void _applyStatusBarStyle(int index) {
    switch (index) {
      case 0: // Home
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ));
        break;

      case 1: // Map
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ));
        break;

      case 2: // Flash Sale
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ));
        break;
    }
  }
  // --------------------------------

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _applyStatusBarStyle(index); // apply style when switching tabs
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          _applyStatusBarStyle(0);
        } else {
          final now = DateTime.now();
          if (lastBackPressTime == null ||
              now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
            lastBackPressTime = now;
            AppDialogue.toast("Press back again to exit");
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(51),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(
                  assetPath: "assets/figmaIcons/homebottom.png",
                  label: 'Home',
                  index: 0,
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -22,
                        child: GestureDetector(
                          onTap: () {
                            final newIndex = _currentIndex == 1 ? 0 : 1;
                            _onTabSelected(newIndex);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _currentIndex == 1
                                      ? Icons.list_alt
                                      : Icons.map,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _currentIndex == 1 ? "List View" : "Map View",
                                style: TextStyle(
                                  color: _currentIndex == 1
                                      ? AppColor.maincolor
                                      : Colors.black,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                textScaler: const TextScaler.linear(1.0),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildNavItem(
                  assetPath: "assets/figmaIcons/offerbottom.png",
                  label: 'Flash Offer',
                  index: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    IconData? icon,
    String? assetPath,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index), // changed here
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (assetPath != null)
                Image.asset(
                  assetPath,
                  height: 24,
                  width: 24,
                  color: Colors.black,
                )
              else if (icon != null)
                Icon(icon, color: Colors.black, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColor.maincolor : Colors.black,
                  fontSize: 12,
                ),
                textScaler: const TextScaler.linear(1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}