import 'package:flutter/material.dart';
import 'package:flutter_application_3/database/database_helper.dart';
import 'package:flutter_application_3/models/calculation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/cubit/history_cubit.dart';
import 'screens/history_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider( 
      create: (context) => HistoryCubit(),
      child: MaterialApp(
        title: 'Калькулятор простых процентов',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
      ),        
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _capitalController = TextEditingController();
  final _termController = TextEditingController();
  final _rateController = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _capitalController.dispose();
    _termController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _agreed) {
      double capital = double.parse(_capitalController.text);
      int term = int.parse(_termController.text);
      double rate = double.parse(_rateController.text);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            capital: capital,
            term: term,
            rate: rate,
          ),
        ),
      );
    } else if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Необходимо согласие на обработку данных')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Флоря Дмитрий Александрович'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _capitalController,
                decoration: const InputDecoration(labelText: 'Исходный капитал (₽)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите капитал';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Введите корректное положительное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _termController,
                decoration: const InputDecoration(labelText: 'Срок начисления (лет)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите срок';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Введите корректное целое положительное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(labelText: 'Годовая ставка (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите ставку';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Введите корректное положительное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text('Согласен на обработку персональных данных'),
                value: _agreed,
                onChanged: (bool? value) {
                  setState(() {
                    _agreed = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Рассчитать'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Экран с результатом
// Экран с результатом — обновленный
class ResultScreen extends StatefulWidget {
  final double capital;
  final int term;
  final double rate;

  const ResultScreen({
    super.key,
    required this.capital,
    required this.term,
    required this.rate,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final double result;

  @override
  void initState() {
    super.initState();
    result = widget.capital * (1 + (widget.rate / 100) * widget.term);

    // Сохраняем один раз при создании экрана
    _saveData();
  }

  Future<void> _saveData() async {
    // SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('last_result', result);

    // SQFlite через кубит
    final newCalc = Calculation(
      capital: widget.capital,
      term: widget.term,
      rate: widget.rate,
      result: result,
      createdAt: DateTime.now(),
    );
    context.read<HistoryCubit>().addCalculation(newCalc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат расчета'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Результат:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Исходный капитал: ${widget.capital.toStringAsFixed(2)} ₽'),
            const SizedBox(height: 8),
            Text('Срок: ${widget.term} лет'),
            const SizedBox(height: 8),
            Text('Ставка: ${widget.rate}%'),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'Итоговая сумма: ${result.toStringAsFixed(2)} ₽',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Назад'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}