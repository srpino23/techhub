import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  List<dynamic> cameras = [];
  String? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCameras();
    Timer.periodic(Duration(seconds: 5), (timer) {
      fetchCameras();
    });
  }

  Future<void> fetchCameras() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = prefs.getString('user');
    if (user != null) {
      final userData = json.decode(user!);
      debugPrint(userData['team']);
      final response = await http.get(
        Uri.parse(
          'http://74280601d366.sn.mynetname.net:2300/api/camera/getCameras',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          cameras =
              json
                  .decode(response.body)
                  .where(
                    (camera) =>
                        camera['status'] == 'offline' &&
                        camera['liable'].toString().toLowerCase() ==
                            userData['team'].toString().toLowerCase(),
                  )
                  .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cameras');
      }
    } else {
      throw Exception('User data is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: cameras.length,
          itemBuilder: (context, index) {
            return Card(
              color: const Color(0xFF1b1b1f),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              cameras[index]['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf56565),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            "Fuera de linea",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(LucideIcons.network, color: Colors.white),
                        const SizedBox(width: 4.0),
                        Text(
                          '${cameras[index]['ip']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(LucideIcons.video, color: Colors.white),
                        const SizedBox(width: 4.0),
                        Text(
                          _translateCameraType(cameras[index]['type']),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _translateCameraType(String type) {
    switch (type) {
      case 'Dome':
        return 'Domo';
      case 'Fixed':
        return 'Fija';
      case 'LPR':
        return 'LPR';
      case 'Button':
        return 'Botón';
      default:
        return type;
    }
  }
}
