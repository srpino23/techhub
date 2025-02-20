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
  final TextEditingController _historySearchController = TextEditingController();
  final TextEditingController _dateSearchController = TextEditingController();
  final TextEditingController _teamSearchController = TextEditingController();

  int _quantity = 1;
  String _selectedTeam = 'AXON';

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        String item = _controller.text.toLowerCase();
        int index = _stockList.indexWhere((element) => element['item'].toLowerCase() == item);
        if (index != -1) {
          _stockList[index]['quantity'] += _quantity;
        } else {
          _stockList.add({'item': item, 'quantity': _quantity});
        }
        _history.add('+ Añadido: $item, Cantidad: $_quantity, Fecha y Hora: ${DateTime.now()}');
        _controller.clear();
        _quantity = 1;
      });
    }
  }

  void _removeItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        String item = _controller.text.toLowerCase();
        int index = _stockList.indexWhere((element) => element['item'].toLowerCase() == item);
        if (index != -1) {
          if (_stockList[index]['quantity'] > _quantity) {
            _stockList[index]['quantity'] -= _quantity;
          } else {
            _stockList.removeAt(index);
          }
          _history.add('- Retirado: $item, Cantidad: $_quantity, Equipo: $_selectedTeam, Fecha y Hora: ${DateTime.now()}');
        }
        _controller.clear();
        _quantity = 1;
      });
    }
  }

  List<Map<String, dynamic>> _filteredStockList() {
    String query = _searchController.text.toLowerCase();
    return _stockList.where((item) => item['item'].toLowerCase().contains(query)).toList();
  }

  List<String> _filteredHistory() {
    String materialQuery = _historySearchController.text.toLowerCase();
    String dateQuery = _dateSearchController.text;
    String teamQuery = _teamSearchController.text.toLowerCase();

    return _history.where((entry) {
      bool matchesMaterial = materialQuery.isEmpty || entry.toLowerCase().contains(materialQuery);
      bool matchesDate = dateQuery.isEmpty || entry.contains(dateQuery);
      bool matchesTeam = teamQuery.isEmpty || entry.toLowerCase().contains(teamQuery);
      return matchesMaterial && matchesDate && matchesTeam;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildInputSection(),
              const SizedBox(height: 16),
              _buildSectionTitle('Lista de Materiales'),
              _buildSearchField(_searchController, 'Buscar en materiales'),
              _buildStockList(),
              const SizedBox(height: 16),
              _buildSectionTitle('Historial'),
              Row(
                children: [
                  Expanded(child: _buildSearchField(_historySearchController, 'Material')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSearchField(_dateSearchController, 'Fecha (YYYY-MM-DD)')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSearchField(_teamSearchController, 'Equipo')),
                ],
              ),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Item',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildQuantitySelector(),
            const SizedBox(height: 10),
            _buildDropdownTeamSelector(),
            const SizedBox(height: 10),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.white),
          onPressed: () => setState(() => _quantity = (_quantity > 1) ? _quantity - 1 : 1),
        ),
        Text('$_quantity', style: const TextStyle(fontSize: 18, color: Colors.white)),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () => setState(() => _quantity++),
        ),
      ],
    );
  }

  Widget _buildDropdownTeamSelector() {
    return DropdownButton<String>(
      value: _selectedTeam,
      dropdownColor: Colors.black,
      onChanged: (String? newValue) => setState(() => _selectedTeam = newValue!),
      items: ['AXON', 'COM 1', 'COM 2', 'COM 3', 'ADMIN'].map((String value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _addItem,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          icon: const Icon(Icons.add),
          label: const Text('Añadir', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton.icon(
          onPressed: _removeItem,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          icon: const Icon(Icons.remove),
          label: const Text('Retirar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSearchField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildStockList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredStockList().length,
      itemBuilder: (context, index) {
        var item = _filteredStockList()[index];
        return ListTile(
          title: Text(item['item'], style: const TextStyle(color: Colors.white)),
          trailing: Text('Cantidad: ${item['quantity']}', style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredHistory().length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_filteredHistory()[index], style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }
}
