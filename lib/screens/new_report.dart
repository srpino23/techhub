import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart' as geolocator;

import 'dart:io';
import 'package:location/location.dart';

class NewReport extends StatefulWidget {
  const NewReport({super.key});

  @override
  NewReportState createState() => NewReportState();
}

class NewReportState extends State<NewReport> {
  final List<XFile> _images = [];
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final Location _location = Location();
  String? _selectedWorkType;
  final List<String> _workTypes = [
    'Preventivo',
    'Recambio',
    'Correctivo',
    'Reubicación',
    'Retiro de Sistema',
    'Instalación',
  ];
  bool _usedSupplies = false;
  final List<Map<String, dynamic>> _selectedSupplies = [];
  final List<String> _availableSupplies = [
    'Cable UTP',
    'Conector RJ45',
    'Switch 8 puertos',
    'Cámara de seguridad',
    'Fuente 12V 2A',
    'Adaptador PoE',
    'Tornillos',
    'Cinta aisladora',
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
    );
    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  Future<void> _assignAutomaticLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    if (kIsWeb) {
      final geolocator.Position position = await geolocator
          .Geolocator.getCurrentPosition(
        locationSettings: geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _locationController.text =
            '${position.latitude}, ${position.longitude}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación asignada automáticamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.greenAccent,
        ),
      );
    } else {
      serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      final LocationData locationData = await _location.getLocation();

      if (!mounted) return;

      setState(() {
        _locationController.text =
            '${locationData.latitude}, ${locationData.longitude}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación asignada automáticamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.greenAccent,
        ),
      );
    }
  }

  void _addSupplyField() {
    setState(() {
      _selectedSupplies.add({
        'name': null,
        'quantity': TextEditingController(),
      });
    });
  }

  void _removeSupplyField(int index) {
    setState(() {
      _selectedSupplies.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('New Report'),
        backgroundColor: const Color(0xFF1b1b1f),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Complete the Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Ubicación
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _assignAutomaticLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Asignar Ubicación Automáticamente'),
                  ),
                  const SizedBox(height: 20),

                  // Tipo de trabajo
                  DropdownButtonFormField<String>(
                    value: _selectedWorkType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Trabajo',
                    ),
                    items:
                        _workTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedWorkType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Aclaraciones / Trabajo realizado
                  TextField(
                    controller: _remarksController,
                    decoration: const InputDecoration(
                      labelText: 'Trabajo Realizado',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Checkbox para materiales
                  Row(
                    children: [
                      Checkbox(
                        value: _usedSupplies,
                        onChanged: (bool? value) {
                          setState(() {
                            _usedSupplies = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        'Utilizó Materiales',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Lista de materiales
                  if (_usedSupplies)
                    Column(
                      children: [
                        for (int i = 0; i < _selectedSupplies.length; i++)
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedSupplies[i]['name'],
                                  decoration: const InputDecoration(
                                    labelText: 'Material Utilizado',
                                  ),
                                  items:
                                      _availableSupplies.map((String supply) {
                                        return DropdownMenuItem<String>(
                                          value: supply,
                                          child: Text(supply),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedSupplies[i]['name'] = newValue;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _selectedSupplies[i]['quantity'],
                                  decoration: const InputDecoration(
                                    labelText: 'Cantidad',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeSupplyField(i),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _addSupplyField,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar Material'),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Botón de foto
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Sacar Foto'),
                  ),
                  const SizedBox(height: 20),

                  // Mostrar imágenes si se han tomado
                  if (_images.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          _images.map((image) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  kIsWeb
                                      ? Image.network(
                                        image.path,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.file(
                                        File(image.path),
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                            );
                          }).toList(),
                    ),
                  if (_images.isNotEmpty) const SizedBox(height: 20),

                  // Botón Enviar
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reporte Enviado'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar Reporte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
