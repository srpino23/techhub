import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'inventory.dart';
import 'task.dart';

class Options extends StatefulWidget {
  final VoidCallback toggleLogin;

  const Options({super.key, required this.toggleLogin});

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).push(_createRoute(const Inventory()));
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Card(
              color: Color(0xFF1b1b1f),
              child: Center(
                child: Icon(
                  LucideIcons.archive,
                  color: Color(0xFFf56565),
                  size: 40,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              widget.toggleLogin();
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Card(
              color: Color(0xFF1b1b1f),
              child: Center(
                child: Icon(
                  LucideIcons.logOut,
                  color: Color(0xFFf56565),
                  size: 40,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(_createRoute(const Task()));
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Card(
              color: Color(0xFF1b1b1f),
              child: Center(
                child: Icon(
                  LucideIcons.clipboardCheck,
                  color: Color(0xFFf56565),
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: Container(
            color: Colors.black, // Color de fondo oscuro
            child: child,
          ),
        );
      },
    );
  }
}
