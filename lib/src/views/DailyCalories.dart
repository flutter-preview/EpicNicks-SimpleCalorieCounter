import 'package:calorie_tracker/src/dto/FoodItemEntry.dart';
import 'package:calorie_tracker/src/extensions/datetime_extensions.dart';
import 'package:calorie_tracker/src/helpers/DatabaseHelper.dart';
import 'package:flutter/material.dart';

class Entry {
  TextField textField;
  TextEditingController controller;
  int dbId;

  Entry({required this.textField, required this.controller, required this.dbId});

  void dispose() {
    controller.dispose();
    textField.focusNode?.dispose();
  }
}

class DailyCaloriesPage extends StatefulWidget {
  const DailyCaloriesPage({super.key});

  @override
  State<DailyCaloriesPage> createState() => _DailyCaloriesPageState();
}

class _DailyCaloriesPageState extends State<DailyCaloriesPage> {
  List<Entry> entries = [];

  Future<void> loadItems() async {
    final foodItemEntries = await DatabaseHelper.instance.getFoodItems(DateTime.now().dateOnly);
    setState(() {
      entries = foodItemEntries.map((e) {
        final focusNode = FocusNode();
        final controller = TextEditingController()..text = e.calorieExpression;
        return Entry(
          controller: controller,
          dbId: e.id!,
          textField: TextField(
            controller: controller,
            cursorColor: Colors.black,
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              filled: true,
              fillColor: Color.fromARGB(200, 255, 255, 255),
            ),
            keyboardType: TextInputType.text,
            focusNode: focusNode,
            onChanged: (value) async {
              // force update
              await DatabaseHelper.instance
                  .update(FoodItemEntry(id: e.id, calorieExpression: value, date: DateTime.now().dateOnly));
              setState(() {});
            },
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                addTextField();
                focusNode.unfocus();
              }
            },
            onEditingComplete: () {
              focusNode.unfocus();
            },
          ),
        );
      }).toList();
    });
  }

  Future<void> addTextField() async {
    await DatabaseHelper.instance.add(FoodItemEntry(calorieExpression: "", date: DateTime.now().dateOnly));
    await loadItems();
    if (entries.isNotEmpty) {
      FocusScope.of(context).unfocus();
      entries[entries.length - 1].textField.focusNode?.requestFocus();
    }
  }

  Future<void> clearTextFields() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("AlertDialog"),
            content: const Text("Really CLEAR the List?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Continue"),
                onPressed: () async {
                  List<int> ids = entries.map((e) => e.dbId).toList();
                  for (int id in ids) {
                    DatabaseHelper.instance.delete(id);
                  }
                  Navigator.of(context).pop();
                  await loadItems();
                },
              ),
            ],
          );
        });
  }

  Future<void> deleteTextField(int id) async {
    FocusScope.of(context).unfocus();
    await DatabaseHelper.instance.delete(id);
    await loadItems();
  }

  int totalCalories() {
    int total = 0;
    for (var item in entries) {
      total += evaluateFoodItem(item.controller.text).round();
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  @override
  void dispose() {
    super.dispose();
    for (var entry in entries) {
      entry.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text("Total Calories: ${totalCalories()}")),
        ),
        body: Column(
          children: [
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: [Colors.white70, Colors.orange.shade100],
                        stops: const [0, 1],
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: entries[index].textField,
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              deleteTextField(entries[index].dbId);
                            },
                          ),
                        );
                      },
                    ))),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 0.25)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  color: Colors.green,
                  onPressed: () {
                    addTextField();
                  },
                  icon: const Icon(Icons.add_sharp)),
              IconButton(
                  color: Colors.red,
                  onPressed: () {
                    clearTextFields();
                  },
                  icon: const Icon(Icons.delete_forever))
            ],
          ),
        ));
  }
}
