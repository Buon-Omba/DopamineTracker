import 'package:flutter/material.dart';

class HealthGoalCard extends StatefulWidget {
  final String title;
  final String description;
  final double progress;
  final bool completed;
  final int timeRemaining; // in minutes

  const HealthGoalCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.completed,
    required this.timeRemaining,
  });

  @override
  _HealthGoalCardState createState() => _HealthGoalCardState();
}

class _HealthGoalCardState extends State<HealthGoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Animation duration
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTimeRemaining(int timeRemainingMinutes) {
    final int years = timeRemainingMinutes ~/ (525600); // Minutes in a year
    final int months =
        (timeRemainingMinutes % 525600) ~/ (43800); // Minutes in a month
    final int days =
        (timeRemainingMinutes % 43800) ~/ (1440); // Minutes in a day
    final int hours = (timeRemainingMinutes % 1440) ~/ 60; // Minutes in an hour
    final int minutes = timeRemainingMinutes % 60;

    final parts = <String>[
      if (years > 0) '$years year${years > 1 ? 's' : ''}',
      if (months > 0) '$months month${months > 1 ? 's' : ''}',
      if (days > 0) '$days day${days > 1 ? 's' : ''}',
      if (hours > 0) '$hours hour${hours > 1 ? 's' : ''}',
      if (minutes > 0) '$minutes minute${minutes > 1 ? 's' : ''}',
    ];

    // Return only the two biggest time units
    return parts.take(2).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  widget.completed ? Icons.check_circle : Icons.timelapse,
                  color: widget.completed ? Colors.green : Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.completed ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              widget.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Animated Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    minHeight: 8,
                    color: widget.completed ? Colors.green : Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.grey[300],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Time Remaining or Completed
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                widget.completed
                    ? '✅ Completed'
                    : '⏳ ${_formatTimeRemaining(widget.timeRemaining)} left',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: widget.completed ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
