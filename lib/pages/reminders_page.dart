import 'package:flutter/material.dart';

import 'package:elura_skincare_app/models/reminders.dart'; // Replace with your actual project name

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<Reminder> _reminders = [
    Reminder('Morning Routine', '8:00 am', false),
    Reminder('Sunscreen', '12:00 am', true),
    Reminder('Evening Routine', '5:00 pm', false),
  ];

  final TextEditingController _descController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFEFE7E1),
          title: const Text(
            'Add Reminder',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(
                  color: Color(0xFF9B8780),
                ),
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B8780)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B8780)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Time',
                style: TextStyle(
                  color: Color(0xFF9B8780),
                ),
              ),
              TextField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B8780)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF9B8780)),
                  ),
                ),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    _timeController.text = time.format(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _descController.clear();
                _timeController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF9B8780)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9B8780),
              ),
              onPressed: () {
                if (_descController.text.isNotEmpty && _timeController.text.isNotEmpty) {
                  setState(() {
                    _reminders.add(Reminder(
                      _descController.text,
                      _timeController.text,
                      false,
                    ));
                  });
                  _descController.clear();
                  _timeController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF7F5),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAF7F5),
        elevation: 0,
        title: const Text(
          'Reminders',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color(0xFF9B8780),
            ),
            onPressed: _showAddDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF9B8780),
            ),
            onSelected: (value) {
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'sort', child: Text('Sort')),
              const PopupMenuItem(value: 'select', child: Text('Select')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFEFE7E1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                title: Text(
                  reminder.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    reminder.time,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9B8780),
                    ),
                  ),
                ),
                trailing: Switch(
                  value: reminder.enabled,
                  activeColor: Color(0xFF9B8780),
                  onChanged: (bool value) {
                    setState(() {
                      reminder.enabled = value;
                    });
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}