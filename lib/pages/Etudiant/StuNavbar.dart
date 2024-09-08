import 'package:flutter/material.dart';

class StuNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const StuNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white, // White for the navbar background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            index: 0,
            isSelected: selectedIndex == 0,
            label: 'Acceuil',
            onTap: () {
              if (selectedIndex != 0) {
                onTabSelected(0); // Redirect to home only if not already on the home page
              }
            },
          ),
          _buildNavItem(
            icon: Icons.calendar_today_outlined,
            index: 1,
            isSelected: selectedIndex == 1,
            label: 'Seances',
            onTap: () => onTabSelected(1),
          ),
          _buildNavItem(
            icon: Icons.chat_bubble_outline,
            index: 2,
            isSelected: selectedIndex == 2,
            label: 'Messages',
            onTap: () => onTabSelected(2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isSelected,
    required String label,
    required Function() onTap,
  }) {
    // Colors for selected and unselected items
    final Color selectedColor = const Color(0xFF1C6DD0); // Blue for the selected button
    final Color unselectedColor = Color(0xFF1C6DD0); // Grayed blue for unselected buttons

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : unselectedColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
