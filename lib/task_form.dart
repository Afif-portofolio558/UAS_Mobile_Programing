import 'package:flutter/material.dart';
import 'task_model.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  const TaskForm({super.key, this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _deadline; // ⬅️ DEADLINE

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _deadline = widget.task!.deadline;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih deadline')),
      );
      return;
    }

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      deadline: _deadline!,
    );

    Navigator.pop(context, task);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple.shade600,
        title: Text(
          widget.task == null ? 'Tambah Tugas Baru' : 'Edit Tugas',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade400,
                            Colors.deepPurple.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        widget.task == null ? Icons.add_task : Icons.edit_note,
                        color: Colors.white,
                        size: isMobile ? 32 : 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title Section
                  Text(
                    'Judul Tugas',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul tugas tidak boleh kosong';
                      }
                      if (value.length < 3) {
                        return 'Judul minimal 3 karakter';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Masukkan judul tugas',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.title,
                        color: Colors.deepPurple.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade200,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade600,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  Text(
                    'Deskripsi Tugas',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Deskripsi tugas tidak boleh kosong';
                      }
                      if (value.length < 5) {
                        return 'Deskripsi minimal 5 karakter';
                      }
                      return null;
                    },
                    minLines: 5,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Masukkan deskripsi tugas',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Icon(
                          Icons.description,
                          color: Colors.deepPurple.shade400,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade200,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade600,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Deadline picker
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.calendar_today,
                        color: _deadline == null ? Colors.white : Colors.yellow,
                      ),
                      label: Text(
                        _deadline == null
                            ? 'Pilih Deadline'
                            : 'Deadline: ${_deadline!.day}-${_deadline!.month}-${_deadline!.year} '
                              '${_deadline!.hour}:${_deadline!.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _deadline == null ? Colors.deepPurple : Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _pickDeadline,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 12 : 16,
                            ),
                            side: BorderSide(
                              color: Colors.grey.shade400,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade600,
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _save,
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime.now()),
    );

    if (time == null) return;

    setState(() {
      _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }
}
