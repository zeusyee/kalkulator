import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(720, 1280),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _calculationHistory = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
        backgroundColor: Colors.teal,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Calculator(onCalculation: (result) {
            setState(() {
              _calculationHistory.add(result);
            });
          }),
          CalculationHistory(calculationHistory: _calculationHistory),
          const UserProfileDisplay(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Kalkulator'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  final Function(String) onCalculation;
  const Calculator({super.key, required this.onCalculation});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _display = '0';
  String _history = '';

  void _handleInput(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _history = '';
      } else if (value == 'Del') {
        _display = _display.length > 1 ? _display.substring(0, _display.length - 1) : '0';
      } else if (value == '±') {
        _display = (double.parse(_display) * -1).toString();
      } else if (value == '.') {
        if (!_display.contains('.')) _display += '.';
      } else if (value == '=') {
        try {
          final expression = _display.replaceAll('×', '*').replaceAll('÷', '/');
          final evalResult = Parser().parse(expression).evaluate(EvaluationType.REAL, ContextModel());
          _history = '$_display = ';
          _display = evalResult % 1 == 0 ? evalResult.toInt().toString() : evalResult.toString();
          widget.onCalculation('$_history$_display');
        } catch (e) {
          _display = 'Error';
        }
      } else {
        _display = _display == '0' ? value : _display + value;
      }
    });
  }

  Widget _buildButton(String text, {Color color = Colors.grey}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => _handleInput(text),
          child: Text(text, style: const TextStyle(fontSize: 42)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
  Expanded(
    flex: 2,
    child: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.all(24),
      child: FittedBox(
        fit: BoxFit.scaleDown, // Mengecilkan teks secara otomatis jika penuh
        child: Text(
          _display,
          style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w100),
        ),
      ),
    ),
  ),

          Expanded(
            flex: 5,
            child: Column(
              children: [
                Row(children: ['7', '8', '9', '÷'].map((e) => _buildButton(e, color: Colors.orange)).toList()),
                Row(children: ['4', '5', '6', '×'].map((e) => _buildButton(e, color: Colors.orange)).toList()),
                Row(children: ['1', '2', '3', '-'].map((e) => _buildButton(e, color: Colors.orange)).toList()),
                Row(children: ['C', '0', 'Del', '+'].map((e) => _buildButton(e, color: Colors.orange)).toList()),
                Row(children: [_buildButton('=')]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CalculationHistory extends StatelessWidget {
  final List<String> calculationHistory;
  const CalculationHistory({super.key, required this.calculationHistory});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: calculationHistory.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(calculationHistory[index]),
        );
      },
    );
  }
}

class UserProfileDisplay extends StatelessWidget {
  const UserProfileDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Foto Profil
          const CircleAvatar(
            radius: 50, // Ukuran foto profil
            backgroundImage: AssetImage('asset/p.jpg'), // Ganti dengan foto pengguna
            backgroundColor: Colors.grey, // Jika tidak ada gambar, gunakan warna abu-abu
          ),
          const SizedBox(height: 16), // Jarak antara foto profil dan teks

          // Informasi Profil
          const Text(
            'Profil Pengguna',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 10),

          // Nama dan Email dalam ListTile
          const Card(
            elevation: 2, // Efek bayangan pada kartu
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.teal),
              title: Text('Nama'),
              subtitle: Text('ZF'),
            ),
          ),
          const SizedBox(height: 5),

          const Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.email, color: Colors.teal),
              title: Text('Email'),
              subtitle: Text('ZF@example.com'),
            ),
          ),
        ],
      ),
    );
  }
}

