import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'task_model.dart';
import 'task_form.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TaskDetail extends StatelessWidget {
  final Task task;
  const TaskDetail({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple.shade600,
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _showDeleteDialog(context);
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 20 : 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.task_alt,
                                color: Colors.white,
                                size: isMobile ? 32 : 40,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: isMobile ? 20 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Dibuat: ${DateTime.now().toString().split(' ')[0]}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Description Section
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
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
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      child: Text(
                        task.description,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),

                // Kontak Row (WhatsApp, Call, Email)
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        openWhatsApp(context, '6285290883295', task.title);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Buttons
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildEditButton(context, isMobile),
                      const SizedBox(height: 12),
                      _buildDeleteButtonSecondary(context),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditButton(context, isMobile),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDeleteButtonSecondary(context),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context, bool isMobile) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade600,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 12 : 16,
          horizontal: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      onPressed: () async {
        final updatedTask = await Navigator.push<Task>(
          context,
          MaterialPageRoute(
            builder: (_) => TaskForm(task: task),
          ),
        );

        if (updatedTask != null) {
          Navigator.pop(context, updatedTask);
        }
      },
      icon: const Icon(Icons.edit, color: Colors.white),
      label: Text(
        'Edit',
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDeleteButtonSecondary(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 24,
        ),
        side: BorderSide(color: Colors.red.shade600, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        _showDeleteDialog(context);
      },
      icon: Icon(Icons.delete, color: Colors.red.shade600),
      label: Text(
        'Hapus',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red.shade600,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Tugas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus tugas ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, 'delete');
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> openWhatsApp(BuildContext context, String phone, String message) async {
    final encoded = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$phone?text=$encoded');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka WhatsApp')));
    }
  }

  Future<void> callPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal melakukan panggilan')));
    }
  }

  Future<void> sendEmail(BuildContext context, String toEmail, String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query: 'subject=${Uri.encodeComponent(subject)}',
    );
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka email')));
    }
  }
}
