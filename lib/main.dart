import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import 'screens/home.dart';
import 'screens/options.dart';
import 'screens/new_report.dart';
import 'screens/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogged = false;
  bool isLoading = true; // Añadir esta línea
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkLoggedInStatus();
  }

  Future<void> _checkLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user');
    if (user != null) {
      final bool canCheckBiometrics = await auth.canCheckBiometrics;
      final bool isBiometricSupported = await auth.isDeviceSupported();
      if (canCheckBiometrics && isBiometricSupported) {
        try {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: '',
            options: const AuthenticationOptions(biometricOnly: true),
          );
          if (didAuthenticate) {
            setState(() {
              isLogged = true;
            });
          }
        } on PlatformException catch (e) {
          // Use a logging framework or handle the error appropriately
          debugPrint('Error during authentication: $e');
        }
      }
    }
    setState(() {
      isLoading = false; // Añadir esta línea
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '[ Tech HUB ]',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFf56565)),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(
            0xFFf56565,
          ), // Cambiar el color del indicador activo
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Colors.white);
            }
            return const TextStyle(color: Colors.grey);
          }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.black87);
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
      ),
      home:
          isLoading // Añadir esta línea
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Añadir esta línea
              : isLogged
              ? MyHomePage(title: '[ Tech HUB ]', toggleLogin: _toggleLogin)
              : Login(toggleLogin: _toggleLogin),
    );
  }

  void _toggleLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (isLogged == false) {
        isLogged = true;
      } else {
        isLogged = false;
        prefs.remove('user');
      }
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.toggleLogin});

  final String title;
  final VoidCallback toggleLogin;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[Home(), Options(toggleLogin: widget.toggleLogin)];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    Navigator.of(context).push(_createRoute(const NewReport()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
          child: AppBar(
            backgroundColor: const Color(0xFF1b1b1f),
            surfaceTintColor: Colors.transparent,
            elevation: 0.0,
            title: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      floatingActionButton: SizedBox(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: _onFabPressed,
            shape: const CircleBorder(),
            backgroundColor: Color(0xFFf56565),
            child: const Icon(LucideIcons.plus, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomAppBar(
          color: const Color(0xFF1b1b1f),
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(LucideIcons.book, color: Colors.white),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.layoutGrid, color: Colors.white),
                label: 'Opciones',
              ),
            ],
          ),
        ),
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
          child: Container(color: Colors.black, child: child),
        );
      },
    );
  }
}
