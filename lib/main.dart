import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: DigitalPetApp()));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 100;

  Timer? hungerTimer;
  Timer? winTimer;
  int happyDuration = 0;

  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Auto hunger every 30 seconds
    hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel += 5;
        _checkLimits();
        _checkGameState();
      });
    });

    // Track win condition (every second)
    winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (happinessLevel > 80) {
        happyDuration++;
        if (happyDuration >= 180) {
          _showDialog("🎉 You Win!", "Your pet stayed happy for 3 minutes!");
          winTimer?.cancel();
        }
      } else {
        happyDuration = 0;
      }
    });
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    winTimer?.cancel();
    super.dispose();
  }

  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      hungerLevel += 5;
      energyLevel -= 10;
      _checkLimits();
      _checkGameState();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 15;
      happinessLevel += 5;
      _checkLimits();
      _checkGameState();
    });
  }

  void _sleepPet() {
    setState(() {
      energyLevel += 20;
      hungerLevel += 5;
      _checkLimits();
    });
  }

  void _checkLimits() {
    happinessLevel = happinessLevel.clamp(0, 100);
    hungerLevel = hungerLevel.clamp(0, 100);
    energyLevel = energyLevel.clamp(0, 100);
  }

  void _checkGameState() {
    if (hungerLevel == 100 && happinessLevel <= 10) {
      _showDialog("💀 Game Over", "Your pet was too hungry and unhappy.");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Color _moodColor(double happiness) {
    if (happiness > 70) {
      return Colors.green;
    } else if (happiness >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String _moodText() {
    if (happinessLevel > 70) {
      return "Happy 😊";
    } else if (happinessLevel >= 30) {
      return "Neutral 😐";
    } else {
      return "Unhappy 😢";
    }
  }

  void _setPetName() {
    setState(() {
      petName = nameController.text;
      nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Digital Pet")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Name Input
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Enter Pet Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _setPetName, child: Text("Set Name")),

              SizedBox(height: 20),

              Text(
                petName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              // Mood Indicator
              Text(_moodText(), style: TextStyle(fontSize: 20)),

              SizedBox(height: 20),

              // ColorFiltered Pet Image
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _moodColor(happinessLevel.toDouble()),
                  BlendMode.modulate,
                ),
                child: Image.asset('assets/pet_image.png', height: 200),
              ),

              SizedBox(height: 30),

              // Happiness Bar
              Text("Happiness"),
              LinearProgressIndicator(
                value: happinessLevel / 100,
                minHeight: 10,
                color: Colors.blue,
              ),
              SizedBox(height: 15),

              // Hunger Bar
              Text("Hunger"),
              LinearProgressIndicator(
                value: hungerLevel / 100,
                minHeight: 10,
                color: Colors.red,
              ),
              SizedBox(height: 15),

              // Energy Bar (Advanced Feature)
              Text("Energy"),
              LinearProgressIndicator(
                value: energyLevel / 100,
                minHeight: 10,
                color: Colors.orange,
              ),

              SizedBox(height: 30),

              ElevatedButton(onPressed: _playWithPet, child: Text("Play")),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _feedPet, child: Text("Feed")),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _sleepPet, child: Text("Sleep")),
            ],
          ),
        ),
      ),
    );
  }
}
