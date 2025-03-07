import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

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
        backgroundColor: Colors.blue,
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
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Kalkulator'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
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

  void _handleKeyboardInput(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      String key = event.logicalKey.keyLabel;

      if (RegExp(r'^[0-9]$').hasMatch(key)) {
        _handleInput(key);
      } else if (key == 'Backspace') {
        _handleInput('Del');
      } else if (key == 'Enter' || key == '=') {
        _handleInput('=');
      } else if (key == 'Escape') {
        _handleInput('C');
      } else if (key == '+' || key == '-' || key == '*' || key == '/') {
        _handleInput(key == '*' ? '×' : key == '/' ? '÷' : key);
      } else if (key == '.') {
        _handleInput('.');
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyboardInput,
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxFontSize = 60;
                double minFontSize = 20;
                double currentFontSize = maxFontSize;

                TextPainter textPainter = TextPainter(
                  text: TextSpan(
                    text: _history + _display,
                    style: TextStyle(fontSize: currentFontSize),
                  ),
                  maxLines: null,
                  textDirection: TextDirection.ltr,
                );

                do {
                  textPainter.text = TextSpan(
                    text: _history + _display,
                    style: TextStyle(fontSize: currentFontSize),
                  );
                  textPainter.layout(maxWidth: constraints.maxWidth);

                  if (textPainter.height > constraints.maxHeight) {
                    currentFontSize -= 2;
                  } else {
                    break;
                  }
                } while (currentFontSize > minFontSize);

                return Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _history,
                          style: TextStyle(fontSize: currentFontSize * 0.6, color: Colors.grey),
                        ),
                        Text(
                          _display,
                          style: TextStyle(fontSize: currentFontSize, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Row(children: ['7', '8', '9', '÷'].map((e) => _buildButton(e, color: const Color.fromARGB(255, 100, 100, 100))).toList()),
                Row(children: ['4', '5', '6', '×'].map((e) => _buildButton(e, color: const Color.fromARGB(255, 100, 100, 100))).toList()),
                Row(children: ['1', '2', '3', '-'].map((e) => _buildButton(e, color: const Color.fromARGB(255, 100, 100, 100))).toList()),
                Row(children: ['C', '0', 'Del', '+'].map((e) => _buildButton(e, color: const Color.fromARGB(255, 100, 100, 100))).toList()),
                Row(children: [_buildButton('=')]),
              ],
            ),
          ),
        ],
      ),
    );
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Foto Profil
          ClipOval(
            child: Image.asset(
              'p.jpg',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 120,
                  color: Colors.grey,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Informasi Profil
          const Text(
            'Nama: ZF',
            style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 0)),
          ),
          const Text(
            'Email: ZF@gmail.com',
            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ],
    ),
);
}
}

