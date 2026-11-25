import 'package:flutter/material.dart';

void main() {
  runApp(const UnitConverterApp());
}

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unit Converter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// UNIT MODEL
class Unit {
  final String name;
  final String symbol;
  final double factor;

  const Unit(this.name, this.symbol, this.factor);
}

// UNIT DATA
final Map<String, List<Unit>> unitData = {
  'Length': [
    Unit('Kilometre', 'km', 1000),
    Unit('Metre', 'm', 1),
    Unit('Centimetre', 'cm', 0.01),
    Unit('Millimetre', 'mm', 0.001),
    Unit('Mile', 'mi', 1609.344),
    Unit('Foot', 'ft', 0.3048),
    Unit('Inch', 'in', 0.0254),
  ],
  'Weight': [
    Unit('Kilogram', 'kg', 1),
    Unit('Gram', 'g', 0.001),
    Unit('Milligram', 'mg', 0.000001),
    Unit('Pound', 'lb', 0.45359237),
    Unit('Ounce', 'oz', 0.028349523125),
  ],
  'Temperature': [
    Unit('Celsius', '°C', 0),
    Unit('Fahrenheit', '°F', 0),
    Unit('Kelvin', 'K', 0),
  ],
};

// CONVERSION FUNCTION
double convertUnit(
  double value,
  Unit from,
  Unit to,
  String category,
) {
  if (category == 'Temperature') {
    double celsius;

    switch (from.symbol) {
      case '°C':
        celsius = value;
        break;
      case '°F':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'K':
        celsius = value - 273.15;
        break;
      default:
        throw ArgumentError('Invalid unit');
    }

    switch (to.symbol) {
      case '°C':
        return celsius;
      case '°F':
        return (celsius * 9 / 5) + 32;
      case 'K':
        return celsius + 273.15;
      default:
        throw ArgumentError('Invalid unit');
    }
  }

  return (value * from.factor) / to.factor;
}

// HOME SCREEN
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Length',
        'description': 'Convert length units',
        'icon': Icons.straighten,
      },
      {
        'title': 'Weight',
        'description': 'Convert weight units',
        'icon': Icons.scale,
      },
      {
        'title': 'Temperature',
        'description': 'Convert temperature units',
        'icon': Icons.thermostat,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Unit Converter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Choose a conversion category',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 18),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(18),
                      leading: Icon(
                        item['icon'] as IconData,
                        color: Colors.blue,
                        size: 35,
                      ),
                      title: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      subtitle: Text(
                        item['description'] as String,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConverterPage(
                              category: item['title'] as String,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CONVERTER SCREEN
class ConverterPage extends StatefulWidget {
  final String category;

  const ConverterPage({
    super.key,
    required this.category,
  });

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController controller =
      TextEditingController(text: '1');

  late Unit fromUnit;
  late Unit toUnit;

  String? errorMessage;
  double? result;

  @override
  void initState() {
    super.initState();

    final units = unitData[widget.category]!;

    fromUnit = units[0];
    toUnit = units[1];

    controller.addListener(convertValue);
    convertValue();
  }

  @override
  void dispose() {
    controller.removeListener(convertValue);
    controller.dispose();
    super.dispose();
  }

  // CONVERT VALUE
  void convertValue() {
    double? value = double.tryParse(controller.text.trim());

    if (value == null || !value.isFinite) {
      setState(() {
        errorMessage = controller.text.trim().isEmpty
            ? 'Please enter a value'
            : 'Please enter a valid number';

        result = null;
      });
      return;
    }

    double converted = convertUnit(
      value,
      fromUnit,
      toUnit,
      widget.category,
    );

    setState(() {
      result = converted;
      errorMessage = null;
    });
  }

  // SWAP UNITS
  void swapUnits() {
    setState(() {
      Unit temp = fromUnit;
      fromUnit = toUnit;
      toUnit = temp;
    });

    convertValue();
  }

  // DROPDOWN
  Widget unitDropdown({
    required Unit selectedUnit,
    required ValueChanged<Unit?> onChanged,
  }) {
    return DropdownButtonFormField<Unit>(
      value: selectedUnit,
      isExpanded: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      items: unitData[widget.category]!.map((unit) {
        return DropdownMenuItem<Unit>(
          value: unit,
          child: Text('${unit.name} (${unit.symbol})'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Converter'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),

            const Text(
              'Enter Value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter a number',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'From Unit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 10),

            unitDropdown(
              selectedUnit: fromUnit,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  fromUnit = value;
                });

                convertValue();
              },
            ),

            const SizedBox(height: 15),

            Center(
              child: IconButton.filled(
                onPressed: swapUnits,
                icon: const Icon(
                  Icons.swap_vert,
                  size: 30,
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'To Unit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 10),

            unitDropdown(
              selectedUnit: toUnit,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  toUnit = value;
                });

                convertValue();
              },
            ),

            const SizedBox(height: 30),

            // RESULT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Conversion Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    )
                  else
                    Text(
                      '${result == result!.roundToDouble() ? result!.toStringAsFixed(0) : result!.toStringAsFixed(4)} ${toUnit.symbol}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // RESET BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  controller.text = '1';
                  FocusScope.of(context).unfocus();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}