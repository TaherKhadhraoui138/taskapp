import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/custom_button.dart';
import '../main.dart'; // Import pour accéder à primaryColor et textColor

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskService _taskService = TaskService();

  late String _title;
  late String _description;
  late DateTime? _deadline;
  late TaskCategory _category;
  late TaskPriority _priority;
  late bool _hasDeadline;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _deadline = widget.task?.deadline;
    _category = widget.task?.category ?? TaskCategory.work;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _hasDeadline = _deadline != null;

    if (_deadline == null) {
      _deadline = _roundToNextQuarterHour(DateTime.now().add(const Duration(hours: 1)));
    }
  }

  DateTime _roundToNextQuarterHour(DateTime dateTime) {
    final minutes = dateTime.minute;
    final newMinutes = (minutes / 15).ceil() * 15;
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      newMinutes,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _deadline = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _deadline!.hour,
          _deadline!.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime.now()),
    );
    if (pickedTime != null) {
      setState(() {
        _deadline = DateTime(
          _deadline!.year,
          _deadline!.month,
          _deadline!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final Task newTask = Task(
        id: widget.task?.id,
        title: _title,
        description: _description,
        deadline: _hasDeadline ? _deadline : null,
        category: _category,
        priority: _priority,
        isCompleted: widget.task?.isCompleted ?? false,
      );

      if (widget.task == null) {
        await _taskService.addTask(newTask);
      } else {
        await _taskService.updateTask(newTask);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tâche $_title enregistrée avec succès !')),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  Widget _buildDateTimeSelector(BuildContext context, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: TaskCategory.values.map((category) {
        final isSelected = _category == category;
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(category.icon, size: 18, color: isSelected ? primaryColor : textColor),
              const SizedBox(width: 5),
              Text(category.toString().split('.').last.toUpperCase()),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _category = category;
              });
            }
          },
          backgroundColor: Colors.white,
          selectedColor: primaryColor.withOpacity(0.1),
          labelStyle: TextStyle(
            color: isSelected ? primaryColor : textColor,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: TaskPriority.values.map((priority) {
        final isSelected = _priority == priority;
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: priority.color,
                ),
              ),
              const SizedBox(width: 5),
              Text(priority.toString().split('.').last.toUpperCase()),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _priority = priority;
              });
            }
          },
          backgroundColor: Colors.white,
          selectedColor: priority.color.withOpacity(0.1),
          labelStyle: TextStyle(
            color: isSelected ? priority.color.darken(0.2) : textColor,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isSelected ? priority.color : Colors.grey.shade300,
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add task' : 'Edit task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'Le titre doit contenir au moins 3 caractères.';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Deadline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Switch(
                    value: _hasDeadline,
                    onChanged: (value) {
                      setState(() {
                        _hasDeadline = value;
                        if (value && _deadline == null) {
                          _deadline = _roundToNextQuarterHour(DateTime.now().add(const Duration(hours: 1)));
                        }
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              if (_hasDeadline) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateTimeSelector(
                        context,
                        DateFormat('d MMMM yyyy').format(_deadline!),
                            () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDateTimeSelector(
                        context,
                        DateFormat('HH:mm').format(_deadline!),
                            () => _selectTime(context),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _buildCategoryChips(),
              const SizedBox(height: 20),
              const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _buildPriorityChips(),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Save',
                onPressed: _saveTask,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
