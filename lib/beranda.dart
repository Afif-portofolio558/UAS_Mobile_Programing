import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_model.dart';
import 'task_form.dart';
import 'task_detail.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart'; // <-- added import


Future<void> openWhatsApp(String phone, String message) async {
  final url = Uri.parse(
    'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}


final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotification() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

  await notificationPlugin.initialize(initSettings);
}


class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  final List<Task> _tasks = [];
  bool _isGrid = false;

  Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'task_channel',
    'Task Reminder',
    channelDescription: 'Notifikasi pengingat tugas',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails details =
      NotificationDetails(android: androidDetails);

  await notificationPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    details,
  );
}


  Future<void> _saveTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final taskJson =
      _tasks.map((task) => jsonEncode(task.toJson())).toList();
  await prefs.setStringList('tasks', taskJson);
}

Future<void> _loadTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final taskJson = prefs.getStringList('tasks');

  if (taskJson != null) {
    setState(() {
      _tasks.clear();
      _tasks.addAll(
        taskJson.map(
          (json) => Task.fromJson(jsonDecode(json)),
        ),
      );
    });
  }
}

@override
void initState() {
  super.initState();
  initNotification();
  _loadTasks();
}


 void _addTask(Task task) {
  setState(() {
    _tasks.add(task);
  });
  _saveTasks();

  showNotification(
    'Tugas Baru Ditambahkan',
    task.title,
  );

  // immediate notification (if NotificationService available)
  try {
    NotificationService.showNotification(
      id: task.id,
      title: 'Tugas Baru',
      body: task.title,
      payload: task.id.toString(), // ⬅ penting
    );
  } catch (_) {}

  // schedule reminder 10 minutes before deadline (safely)
  try {
    final scheduledTime = task.deadline.subtract(const Duration(minutes: 10));
    if (scheduledTime.isAfter(DateTime.now())) {
      NotificationService.scheduleNotification(
        id: task.id,
        title: 'Deadline Tugas',
        body: task.title,
        scheduledTime: scheduledTime,
        payload: task.id.toString(),
      );
    }
  } catch (_) {}
}


 void _updateTask(Task task) {
  final index = _tasks.indexWhere((t) => t.id == task.id);
  if (index != -1) {
    setState(() {
      _tasks[index] = task;
    });
    _saveTasks();

    showNotification(
      'Tugas Diperbarui',
      task.title,
    );
  }
}


  void _deleteTask(int id) {
  setState(() {
    _tasks.removeWhere((task) => task.id == id);
  });
  _saveTasks();
}


  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Apakah yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              _deleteTask(task.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple.shade600,
        title: const Text(
          'MyTask Manager',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              showNotification(
                'MyTask Manager',
                'Notifikasi berjalan dengan baik',
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isGrid ? Icons.list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _isGrid = !_isGrid);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade50, Colors.blue.shade50],
          ),
        ),
        child: _tasks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada tugas',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap tombol + untuk menambah tugas baru',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
            : _isGrid
                ? _buildGrid(isMobile)
                : _buildList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple.shade600,
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final task = await Navigator.push<Task>(
            context,
            MaterialPageRoute(
              builder: (_) => TaskForm(),
            ),
          );

          if (task != null) {
            _addTask(task);
          }
        },
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.deepPurple.shade400,
                  size: 18,
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetail(task: task),
                    ),
                  );

                  if (result is Task) {
                    _updateTask(result);
                  } else if (result == 'delete') {
                    _confirmDelete(task);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(bool isMobile) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 3,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final colors = [
          Colors.blue.shade100,
          Colors.purple.shade100,
          Colors.pink.shade100,
          Colors.green.shade100,
          Colors.orange.shade100,
          Colors.teal.shade100,
        ];

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskDetail(task: task),
                ),
              );

              if (result is Task) {
                _updateTask(result);
              } else if (result == 'delete') {
                _confirmDelete(task);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    colors[index % colors.length],
                    colors[index % colors.length].withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.task_alt,
                      color: Colors.deepPurple.shade400,
                      size: 32,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
