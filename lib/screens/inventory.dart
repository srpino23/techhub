import 'package:flutter/material.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});
  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final List<Map<String, dynamic>> _stockList = [];
  final List<String> _history = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _historySearchController =
      TextEditingController();
  final TextEditingController _dateSearchController = TextEditingController();
  final TextEditingController _teamSearchController = TextEditingController();

  int _quantity = 1;
  String _selectedTeam = 'AXON';

  void _addItem() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        String item = _controller.text.toLowerCase();
        int index = _stockList.indexWhere(
          (element) => element['item'].toLowerCase() == item,
        );
        if (index != -1) {
          _stockList[index]['quantity'] += _quantity;
        } else {
          _stockList.add({'item': item, 'quantity': _quantity});
        }
        String timestamp = DateTime.now().toString();
        _history.add(
          'Añadido: $item, Cantidad: $_quantity, Fecha y Hora: $timestamp',
        );
        _controller.clear();
        _quantity = 1;
      }
    });
  }

  void _removeItem() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        String item = _controller.text.toLowerCase();
        int index = _stockList.indexWhere(
          (element) => element['item'].toLowerCase() == item,
        );
        if (index != -1) {
          if (_stockList[index]['quantity'] > _quantity) {
            _stockList[index]['quantity'] -= _quantity;
          } else {
            _stockList.removeAt(index);
          }
          String timestamp = DateTime.now().toString();
          _history.add(
            'Retirado: $item, Cantidad: $_quantity, Equipo: $_selectedTeam, Fecha y Hora: $timestamp',
          );
        }
        _controller.clear();
        _quantity = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        backgroundColor: const Color(0xFF1b1b1f),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildInputSection(),
              const SizedBox(height: 16),
              const Text(
                'Lista de Materiales',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 8),
              _buildSearchField(_searchController, 'Buscar en materiales'),
              const SizedBox(height: 8),
              _buildStockList(),
              const SizedBox(height: 16),
              const Text(
                'Historial',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSearchField(
                      _historySearchController,
                      'Material',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSearchField(
                      _dateSearchController,
                      'Fecha (YYYY-MM-DD)',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSearchField(_teamSearchController, 'Equipo'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Item',
                fillColor: Color.fromARGB(255, 29, 29, 29),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed:
                      () => setState(
                        () => _quantity = (_quantity > 1) ? _quantity - 1 : 1,
                      ),
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedTeam,
              dropdownColor: Colors.black,
              onChanged:
                  (String? newValue) =>
                      setState(() => _selectedTeam = newValue!),
              items:
                  ['AXON', 'COM 1', 'COM 2', 'COM 3', 'ADMIN'].map((
                    String value,
                  ) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Añadir',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _removeItem,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Retirar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: hintText,
        fillColor: Color.fromARGB(255, 29, 29, 29),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildStockList() {
    return SizedBox(
      height: 200, // Altura máxima para la lista de materiales
      child: Card(
        color: const Color.fromARGB(255, 29, 29, 29),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _stockList.length,
          itemBuilder: (context, index) {
            if (_stockList[index]['item'].contains(
              _searchController.text.toLowerCase(),
            )) {
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_stockList[index]['item']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      '${_stockList[index]['quantity']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return SizedBox(
      height: 200, // Altura máxima para la lista de historial
      child: Card(
        color: const Color.fromARGB(255, 29, 29, 29),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _history.length,
          itemBuilder: (context, index) {
            if (_history[index].toLowerCase().contains(
                  _historySearchController.text.toLowerCase(),
                ) &&
                _history[index].contains(_dateSearchController.text) &&
                _history[index].toLowerCase().contains(
                  _teamSearchController.text.toLowerCase(),
                )) {
              return ListTile(
                title: Text(
                  _history[index],
                  style: const TextStyle(color: Colors.white),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
