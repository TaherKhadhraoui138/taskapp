import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../widgets/custom_button.dart';
import '../main.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TaskService _taskService = TaskService();
  final TextEditingController _subtaskController = TextEditingController();

  late String _title;
  late String _description;
  late DateTime? _deadline;
  late TaskCategory _category;
  late TaskPriority _priority;
  late bool _hasDeadline;
  late List<Subtask> _subtasks;
  late RecurrenceType _recurrenceType;
  late int? _recurrenceInterval;
  late DateTime? _recurrenceEndDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _deadline = widget.task?.deadline;
    _category = widget.task?.category ?? TaskCategory.work;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _hasDeadline = _deadline != null;
    _subtasks = List.from(widget.task?.subtasks ?? []);
    _recurrenceType = widget.task?.recurrenceType ?? RecurrenceType.none;
    _recurrenceInterval = widget.task?.recurrenceInterval;
    _recurrenceEndDate = widget.task?.recurrenceEndDate;
    _tabController = TabController(length: 2, vsync: this);

    if (_deadline == null) {
      _deadline = _roundToNextQuarterHour(DateTime.now().add(const Duration(hours: 1)));
    }
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    _tabController.dispose();
    super.dispose();
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

  Future<void> _selectRecurrenceEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _recurrenceEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _recurrenceEndDate = pickedDate;
      });
    }
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isNotEmpty) {
      setState(() {
        _subtasks.add(Subtask(title: _subtaskController.text.trim()));
        _subtaskController.clear();
      });
    }
  }

  void _toggleSubtask(int index) {
    setState(() {
      _subtasks[index] = _subtasks[index].copyWith(
        isCompleted: !_subtasks[index].isCompleted,
      );
    });
  }

  void _deleteSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
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
        subtasks: _subtasks,
        recurrenceType: _recurrenceType,
        recurrenceInterval: _recurrenceType == RecurrenceType.custom ? _recurrenceInterval : null,
        recurrenceEndDate: _recurrenceType != RecurrenceType.none ? _recurrenceEndDate : null,
      );

      if (widget.task == null) {
        await _taskService.addTask(newTask);
      } else {
        await _taskService.updateTask(newTask);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Task "$_title" saved successfully!'),
              ],
            ),
            backgroundColor: secondaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: _title,
            decoration: const InputDecoration(
              labelText: 'Title *',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.length < 3) {
                return 'Title must be at least 3 characters.';
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
              prefixIcon: Icon(Icons.description),
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
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDateTimeSelector(
                    context,
                    DateFormat('HH:mm').format(_deadline!),
                        () => _selectTime(context),
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Recurrence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _buildRecurrenceSelector(),
            if (_recurrenceType == RecurrenceType.custom) ...[
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _recurrenceInterval?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Repeat every (days)',
                  prefixIcon: Icon(Icons.repeat),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _recurrenceInterval = int.tryParse(value);
                },
              ),
            ],
            if (_recurrenceType != RecurrenceType.none) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _selectRecurrenceEndDate(context),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_busy, color: primaryColor),
                          const SizedBox(width: 10),
                          Text(
                            _recurrenceEndDate != null
                                ? 'Ends: ${DateFormat('d MMM yyyy').format(_recurrenceEndDate!)}'
                                : 'Set end date (optional)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      if (_recurrenceEndDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _recurrenceEndDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),
          const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _buildCategoryChips(),
          const SizedBox(height: 20),
          const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _buildPriorityChips(),
        ],
      ),
    );
  }

  Widget _buildSubtasksTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subtaskController,
                  decoration: const InputDecoration(
                    labelText: 'Add subtask',
                    prefixIcon: Icon(Icons.add_task),
                  ),
                  onSubmitted: (_) => _addSubtask(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: primaryColor,
                iconSize: 32,
                onPressed: _addSubtask,
              ),
            ],
          ),
        ),
        Expanded(
          child: _subtasks.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checklist, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No subtasks yet',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Break down your task into smaller steps',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
          )
              : ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _subtasks.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _subtasks.removeAt(oldIndex);
                _subtasks.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final subtask = _subtasks[index];
              return Container(
                key: ValueKey(subtask.id),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => _toggleSubtask(index),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: subtask.isCompleted ? secondaryColor : Colors.transparent,
                        border: Border.all(color: secondaryColor, width: 2),
                      ),
                      child: subtask.isCompleted
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  title: Text(
                    subtask.title,
                    style: TextStyle(
                      decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                      color: subtask.isCompleted ? Colors.grey : textColor,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.drag_handle, color: Colors.grey.shade400),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteSubtask(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector(BuildContext context, String value, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RecurrenceType.values.map((type) {
        final isSelected = _recurrenceType == type;
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(type.icon, size: 16, color: isSelected ? primaryColor : textColor),
              const SizedBox(width: 4),
              Text(type.displayName),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _recurrenceType = type;
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
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic Info', icon: Icon(Icons.info_outline)),
            Tab(text: 'Subtasks', icon: Icon(Icons.checklist)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildSubtasksTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CustomButton(
          text: 'Save Task',
          onPressed: _saveTask,
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