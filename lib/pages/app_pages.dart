import 'package:flutter/material.dart';
import 'package:my_food_my_price/pages/Map/map_page.dart';
import 'package:my_food_my_price/pages/flash_sale_page.dart';
import 'package:my_food_my_price/pages/home_page.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';

class AppPages extends StatefulWidget {
  const AppPages({super.key});

  @override
  State<AppPages> createState() => _AppPagesState();
}

class _AppPagesState extends State<AppPages> {
  int _currentIndex = 0;

  final List<Widget> _pages = [HomePage(),MapPage(),FlashSalePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
              const SizedBox(width: 130), // space for FAB
              _buildNavItem(
               assetPath: "assets/figmaIcons/offerbottom.png",
                label: 'Flash Sale',
                index: 2,
              ),
            ],
          ),
        ),
      ),
     floatingActionButton: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = _currentIndex == 1 ? 0 : 1;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _currentIndex == 1 ? Icons.list_alt : Icons.map,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                _currentIndex == 1 ? 'List View' : 'Map View',
                style: Styles.textSmall(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textScaler: const TextScaler.linear(1.0),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem({
  IconData? icon,            // optional
  String? assetPath,         // optional
  required String label,
  required int index,
}) {
  final isSelected = _currentIndex == index;

  return Expanded(
    child: InkWell(
      onTap: () => setState(() => _currentIndex = index),
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
                color: Colors.black, // remove if you want original colors
              )
            else if (icon != null)
              Icon(
                icon,
                color: Colors.black,
                size: 24,
              ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColor.maincolor : Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}