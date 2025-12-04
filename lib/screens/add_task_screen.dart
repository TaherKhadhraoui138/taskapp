import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import '../widgets/custom_button.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';
import '../main.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TaskService _taskService = TaskService();
  final NotificationService _notificationService = NotificationService();
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
  bool _isGeneratingSubtasks = false;

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
        // Cancel old notification if task is updated
        await _notificationService.cancelScheduledNotification(newTask.id);
      }

      // Schedule notification 30 min before deadline
      if (_hasDeadline && newTask.deadline != null) {
        await _notificationService.scheduleDeadlineNotification(newTask);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Task "$_title" saved successfully!',
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.cyan,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _generateSubtasks() async {
    if (_title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for the task first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingSubtasks = true;
    });

    try {
      final existingSubtasks = _subtasks.map((s) => s.title).join(', ');
      final prompt =
          'You are a sub-task suggestion assistant. Given a main task title, its detailed description, and a list of existing sub-tasks, suggest the next single, logical sub-task. Do not repeat any of the existing sub-tasks. Main task title: "$_title", Main task description: "$_description", Existing sub-tasks: [$existingSubtasks]. Return only the text of the new sub-task suggestion, without any introductory text.';

      final response = await Gemini.instance.text(prompt);

      if (response != null && response.output != null) {
        // Clean the output to remove potential markdown like '*' or quotes
        final suggestion = response.output!.trim().replaceAll(RegExp(r'^"|"| ^\*|\*$'), '').trim();
        if (suggestion.isNotEmpty) {
          setState(() {
            _subtasks.add(Subtask(title: suggestion));
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate sub-tasks: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingSubtasks = false;
      });
    }
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Field with animation
          SlideAnimation(
            delay: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.coral.withOpacity(0.05),
                  ],
                ),
                boxShadow: AppShadows.small,
              ),
              child: TextFormField(
                initialValue: _title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: 'Task Title *',
                  labelStyle: TextStyle(color: AppColors.coral),
                  prefixIcon: ShaderMask(
                    shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
                    child: const Icon(Icons.title_rounded, color: Colors.white),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.coral, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'Title must be at least 3 characters.';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
                onChanged: (value) => _title = value,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Description Field
          SlideAnimation(
            delay: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.cyan.withOpacity(0.05),
                  ],
                ),
                boxShadow: AppShadows.small,
              ),
              child: TextFormField(
                initialValue: _description,
                maxLines: 3,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColors.cyan),
                  prefixIcon: ShaderMask(
                    shaderCallback: (bounds) => AppGradients.secondary.createShader(bounds),
                    child: const Icon(Icons.description_rounded, color: Colors.white),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.cyan, width: 2),
                  ),
                ),
                onSaved: (value) => _description = value ?? '',
                onChanged: (value) => _description = value,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Deadline Toggle
          SlideAnimation(
            delay: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    AppColors.purple.withOpacity(0.05),
                  ],
                ),
                boxShadow: AppShadows.small,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppGradients.accent.createShader(bounds),
                        child: const Icon(Icons.schedule_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text('Set Deadline', style: AppTextStyles.subtitle),
                    ],
                  ),
                  Switch.adaptive(
                    value: _hasDeadline,
                    onChanged: (value) {
                      setState(() {
                        _hasDeadline = value;
                        if (value && _deadline == null) {
                          _deadline = _roundToNextQuarterHour(DateTime.now().add(const Duration(hours: 1)));
                        }
                      });
                    },
                    activeColor: AppColors.purple,
                    activeTrackColor: AppColors.purple.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),

          if (_hasDeadline) ...[
            const SizedBox(height: 16),
            SlideAnimation(
              delay: const Duration(milliseconds: 350),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDateTimeSelector(
                      context,
                      DateFormat('d MMMM yyyy').format(_deadline!),
                      () => _selectDate(context),
                      Icons.calendar_today_rounded,
                      AppGradients.sunset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTimeSelector(
                      context,
                      DateFormat('HH:mm').format(_deadline!),
                      () => _selectTime(context),
                      Icons.access_time_rounded,
                      AppGradients.ocean,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SlideAnimation(
              delay: const Duration(milliseconds: 400),
              child: _buildSectionHeader('Recurrence', Icons.repeat_rounded, AppGradients.aurora),
            ),
            const SizedBox(height: 12),
            SlideAnimation(
              delay: const Duration(milliseconds: 450),
              child: _buildRecurrenceSelector(),
            ),
            if (_recurrenceType == RecurrenceType.custom) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: AppShadows.small,
                ),
                child: TextFormField(
                  initialValue: _recurrenceInterval?.toString() ?? '',
                  decoration: InputDecoration(
                    labelText: 'Repeat every (days)',
                    labelStyle: TextStyle(color: AppColors.purple),
                    prefixIcon: Icon(Icons.repeat_rounded, color: AppColors.purple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _recurrenceInterval = int.tryParse(value);
                  },
                ),
              ),
            ],
            if (_recurrenceType != RecurrenceType.none) ...[
              const SizedBox(height: 12),
              _buildRecurrenceEndDate(),
            ],
          ],
          const SizedBox(height: 24),

          // Category Section
          SlideAnimation(
            delay: const Duration(milliseconds: 500),
            child: _buildSectionHeader('Category', Icons.category_rounded, AppGradients.primary),
          ),
          const SizedBox(height: 12),
          SlideAnimation(
            delay: const Duration(milliseconds: 550),
            child: _buildCategoryChips(),
          ),
          const SizedBox(height: 24),

          // Priority Section
          SlideAnimation(
            delay: const Duration(milliseconds: 600),
            child: _buildSectionHeader('Priority', Icons.flag_rounded, AppGradients.sunset),
          ),
          const SizedBox(height: 12),
          SlideAnimation(
            delay: const Duration(milliseconds: 650),
            child: _buildPriorityChips(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Gradient gradient) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecurrenceEndDate() {
    return InkWell(
      onTap: () => _selectRecurrenceEndDate(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppColors.amber.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.small,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppGradients.sunset,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_busy_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  _recurrenceEndDate != null
                      ? 'Ends: ${DateFormat('d MMM yyyy').format(_recurrenceEndDate!)}'
                      : 'Set end date (optional)',
                  style: AppTextStyles.body.copyWith(
                    color: _recurrenceEndDate != null ? AppColors.charcoal : AppColors.grey,
                  ),
                ),
              ],
            ),
            if (_recurrenceEndDate != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _recurrenceEndDate = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtasksTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.cyan.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: AppShadows.medium,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          labelText: 'Add subtask',
                          labelStyle: TextStyle(color: AppColors.cyan),
                          prefixIcon: ShaderMask(
                            shaderCallback: (bounds) => AppGradients.secondary.createShader(bounds),
                            child: const Icon(Icons.add_task_rounded, color: Colors.white),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        onSubmitted: (_) => _addSubtask(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: _addSubtask,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppGradients.secondary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _generateSubtasks,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isGeneratingSubtasks
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(
                                'Suggest Sub-tasks',
                                style: AppTextStyles.button.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
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
                      PulseAnimation(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.cyan.withOpacity(0.1),
                                AppColors.purple.withOpacity(0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) => AppGradients.secondary.createShader(bounds),
                            child: const Icon(Icons.checklist_rounded, size: 48, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No subtasks yet',
                        style: AppTextStyles.subtitle.copyWith(color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Break down your task into smaller steps',
                        style: AppTextStyles.caption.copyWith(color: AppColors.grey),
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
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: subtask.isCompleted
                              ? [
                                  AppColors.cyan.withOpacity(0.1),
                                  AppColors.cyan.withOpacity(0.05),
                                ]
                              : [
                                  Colors.white,
                                  Colors.grey.shade50,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.small,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: GestureDetector(
                          onTap: () => _toggleSubtask(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: subtask.isCompleted ? AppGradients.secondary : null,
                              border: subtask.isCompleted
                                  ? null
                                  : Border.all(color: AppColors.cyan, width: 2),
                              boxShadow: subtask.isCompleted
                                  ? [
                                      BoxShadow(
                                        color: AppColors.cyan.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: subtask.isCompleted
                                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        title: Text(
                          subtask.title,
                          style: AppTextStyles.body.copyWith(
                            decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                            color: subtask.isCompleted ? AppColors.grey : AppColors.charcoal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.drag_handle_rounded, color: AppColors.grey.withOpacity(0.5)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _deleteSubtask(index),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                              ),
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

  Widget _buildDateTimeSelector(BuildContext context, String value, VoidCallback onTap, IconData icon, Gradient gradient) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              (gradient as LinearGradient).colors.first.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.small,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: (gradient).colors.first.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: RecurrenceType.values.map((type) {
        final isSelected = _recurrenceType == type;
        return GestureDetector(
          onTap: () {
            setState(() {
              _recurrenceType = type;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppGradients.aurora : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : AppShadows.small,
              border: isSelected ? null : Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.charcoal,
                ),
                const SizedBox(width: 6),
                Text(
                  type.displayName,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: TaskCategory.values.map((category) {
        final isSelected = _category == category;
        return GestureDetector(
          onTap: () {
            setState(() {
              _category = category;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppGradients.primary : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.coral.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : AppShadows.small,
              border: isSelected ? null : Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.charcoal,
                ),
                const SizedBox(width: 8),
                Text(
                  category.toString().split('.').last.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityChips() {
    final priorityGradients = {
      TaskPriority.low: [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
      TaskPriority.medium: [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
      TaskPriority.high: [const Color(0xFFF44336), const Color(0xFFE57373)],
    };

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: TaskPriority.values.map((priority) {
        final isSelected = _priority == priority;
        final colors = priorityGradients[priority]!;

        return GestureDetector(
          onTap: () {
            setState(() {
              _priority = priority;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: colors)
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors.first.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : AppShadows.small,
              border: isSelected ? null : Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : priority.color,
                    boxShadow: [
                      BoxShadow(
                        color: priority.color.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  priority.toString().split('.').last.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.charcoal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.coral.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppShadows.small,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
                          child: Text(
                            widget.task == null ? 'Create Task' : 'Edit Task',
                            style: AppTextStyles.heading2.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.small,
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppGradients.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coral.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.grey,
                      labelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Basic Info'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.checklist_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Subtasks'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tab Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBasicInfoTab(),
                        _buildSubtasksTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: _saveTask,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Save Task',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
