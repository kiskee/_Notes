import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});
  
 @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      shape: const Border(bottom: BorderSide(color: Colors.white, width: 1)),
      title: Center(
        child: const Text(
          '_Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 45,
          ),
        ),
      ),
    );
  }
}
