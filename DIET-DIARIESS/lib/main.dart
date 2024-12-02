import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // For shimmer effect
import 'package:confetti/confetti.dart'; // For confetti animation

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: InputPage(toggleDarkMode: _toggleDarkMode, isDarkMode: _isDarkMode),
    );
  }
}

class InputPage extends StatefulWidget {
  final VoidCallback toggleDarkMode;
  final bool isDarkMode;

  InputPage({required this.toggleDarkMode, required this.isDarkMode});

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> with TickerProviderStateMixin {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _waterGoalController = TextEditingController();

  String _bmiMessage = '';
  String _suggestedFood = '';
  int _calories = 0;
  int _waterIntake = 0;
  int _dailyWaterGoal = 2000;
  bool _showConfetti = false;

  late ConfettiController _confettiController;

  // Quotes for motivation
  List<String> _quotes = [
    "Your body is your temple!",
    "Stay healthy, stay strong!",
    "Water is life!",
    "Eat healthy, live better!",
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _activityController.dispose();
    _waterGoalController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // Function to calculate BMI
  void _calculateBMI() {
    double weight = double.parse(_weightController.text);
    double height =
        double.parse(_heightController.text) / 100; // Convert cm to meters
    double bmi = weight / (height * height);

    if (bmi < 18.5) {
      _bmiMessage = 'Underweight - Let’s boost your intake!';
      _suggestedFood = 'Avocado Toast (250 calories), Smoothie (150 calories)';
      _calories = 400;
    } else if (bmi >= 18.5 && bmi < 24.9) {
      _bmiMessage = 'Normal weight - Keep it balanced!';
      _suggestedFood =
          'Salad with Chicken (350 calories), Fruit Bowl (200 calories)';
      _calories = 550;
    } else if (bmi >= 25 && bmi < 29.9) {
      _bmiMessage = 'Overweight - Let’s work on the diet!';
      _suggestedFood =
          'Grilled Fish (300 calories), Veggie Stir-Fry (200 calories)';
      _calories = 500;
    } else {
      _bmiMessage = 'Obese - Time for a healthier plan!';
      _suggestedFood =
          'Quinoa Salad (250 calories), Steamed Veggies (150 calories)';
      _calories = 400;
    }
  }

  // Function to add water intake
  void _addWaterIntake(int amount) {
    setState(() {
      _waterIntake += amount;
      if (_waterIntake >= _dailyWaterGoal) {
        _showConfetti = true;
        _confettiController.play();
        _bmiMessage += '\nGreat! You reached your water goal for today!';
      } else {
        _bmiMessage += '\nKeep going! Stay hydrated!';
      }
    });
  }

  // Function to calculate calories burned
  void _calculateCaloriesBurned() {
    int activityMinutes = int.parse(_activityController.text);
    int caloriesBurnedFromActivity = activityMinutes * 10; // Simple calculation
    setState(() {
      _calories += caloriesBurnedFromActivity;
      _bmiMessage += '\nYou burned $caloriesBurnedFromActivity calories!';
    });
  }

  // Navigate to result page
  void _navigateToResults() {
    _calculateBMI();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          bmiMessage: _bmiMessage,
          waterIntake: _waterIntake,
          suggestedFood: _suggestedFood,
          calories: _calories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double waterPercentage = _waterIntake / _dailyWaterGoal;

    return Scaffold(
      appBar: AppBar(
        title: Text('Water & Diet Tracker'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleDarkMode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Water Intake Progress Indicator
            LinearProgressIndicator(
              value: waterPercentage.clamp(
                  0.0, 1.0), // Clamp value between 0.0 and 1.0
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
            ),
            SizedBox(height: 10),
            Text(
              'Water Intake: $_waterIntake ml / $_dailyWaterGoal ml',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Input fields
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter your weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter your height (cm)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _waterGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Set daily water intake goal (ml)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Add Water Intake Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _addWaterIntake(250),
                  child: Text('Add 250 ml'),
                ),
                ElevatedButton(
                  onPressed: () => _addWaterIntake(500),
                  child: Text('Add 500 ml'),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _activityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Log physical activity (minutes)',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _calculateCaloriesBurned,
              child: Text('Calculate Calories Burned'),
            ),
            SizedBox(height: 20),
            Shimmer.fromColors(
              baseColor: Colors.blue,
              highlightColor: Colors.lightBlueAccent,
              child: ElevatedButton(
                onPressed: _navigateToResults,
                child: Text('Show Results'),
              ),
            ),
            SizedBox(height: 20),
            // Confetti animation
            if (_showConfetti)
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.1,
              ),
          ],
        ),
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final String bmiMessage;
  final int waterIntake;
  final String suggestedFood;
  final int calories;

  ResultsPage({
    required this.bmiMessage,
    required this.waterIntake,
    required this.suggestedFood,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Results'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'BMI Calculation:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              bmiMessage,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Suggested Food Options:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              suggestedFood,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Total Calories Burned: $calories',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
