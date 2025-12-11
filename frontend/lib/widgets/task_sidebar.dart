import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/agentic_models.dart';

/// Floating task button that expands to show a compact task panel
class TaskButton extends StatefulWidget {
  final List<AgenticTask> tasks;
  final Function(String taskId) onCancelTask;
  final Function(String taskId) onAdvanceTask;
  final Function(String taskId) onSelectTask;
  final Function(AgenticTask task, TaskStep step) onUpload;
  final Function(AgenticTask task, TaskStep step) onPayment; // Add callback

  const TaskButton({
    super.key,
    required this.tasks,
    required this.onCancelTask,
    required this.onAdvanceTask,
    required this.onSelectTask,
    required this.onUpload,
    required this.onPayment, // Required callback
  });

  @override
  State<TaskButton> createState() => _TaskButtonState();
}

class _TaskButtonState extends State<TaskButton> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }



  @override
  Widget build(BuildContext context) {
    final activeTasks = widget.tasks.where((t) => t.isActive).toList();
    final hasActiveTasks = activeTasks.isNotEmpty;

    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expanded panel
          if (_isExpanded)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                alignment: Alignment.bottomRight,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildTaskPanel(activeTasks),
                ),
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Main floating button
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: hasActiveTasks
                      ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                      : [Colors.grey.shade600, Colors.grey.shade700],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (hasActiveTasks ? const Color(0xFF6366F1) : Colors.black).withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedRotation(
                    turns: _isExpanded ? 0.125 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.checklist_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  // Badge for task count
                  if (hasActiveTasks && !_isExpanded)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${activeTasks.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskPanel(List<AgenticTask> tasks) {
    return Container(
      width: 280,
      constraints: const BoxConstraints(maxHeight: 350),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.checklist_rounded,
                    color: Color(0xFF6366F1),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Active Tasks',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${tasks.length}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          
          // Task list
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 40,
                    color: Colors.white.withAlpha(60),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active tasks',
                    style: TextStyle(
                      color: Colors.white.withAlpha(120),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: tasks.length,
                itemBuilder: (context, index) => _buildTaskItem(tasks[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(AgenticTask task) {
    final progress = task.progressPercentage;
    final step = task.currentStepDetails;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(task.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Cancel button
              GestureDetector(
                onTap: () {
                  _toggle();
                  widget.onCancelTask(task.id);
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.red.withAlpha(200),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Current step title
          if (step != null)
            Text(
              'Step ${task.currentStep}: ${step.title}',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          
          // Step description
          if (step != null) ...[
            const SizedBox(height: 4),
            Text(
              step.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Autofill indicator
          if (step?.hasAutofill == true) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(40),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_fix_high, size: 10, color: Colors.green.withAlpha(200)),
                  const SizedBox(width: 4),
                  Text(
                    'Auto-fill from your ID',
                    style: TextStyle(
                      color: Colors.green.withAlpha(200),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 10),
          
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 0.7 ? Colors.green : const Color(0xFF6366F1),
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Action buttons row
          Row(
            children: [
              // Primary action button (link or advance)
              if (step?.hasLink == true)
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onSelectTask(task.id), // This will open in chat
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981), // Solid Green
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.open_in_new, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              step?.actionLabel ?? 'Open Link',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (step?.requiresUpload == true) {
                        widget.onUpload(task, step!);
                      } else if (step?.requiresPayment == true) {
                         // Trigger payment
                         widget.onPayment(task, step!);
                      } else {
                        widget.onAdvanceTask(task.id);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1), // Solid Indigo
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            step?.requiresUpload == true ? Icons.upload_file : Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            step?.actionLabel ?? (step?.requiresUpload == true ? 'Upload' : 'Mark Done'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Mark done button (when there's a link)
              if (step?.hasLink == true) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => widget.onAdvanceTask(task.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Visible Grey
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Icon(Icons.check, size: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

