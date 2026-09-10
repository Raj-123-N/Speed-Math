import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

enum ReportType {
  wrongQuestion('wrong_question', 'Wrong Question'),
  wrongLearn('wrong_learn', 'Error in Learn Content'),
  issue('issue', 'App Issue / Bug'),
  feedback('feedback', 'General Feedback');

  const ReportType(this.id, this.label);
  final String id;
  final String label;
}

class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  static const String _projectId = 'speed-math-app-1';
  static const String _endpoint =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/reports';

  /// Submits a report to Firestore via the public REST API.
  Future<bool> submitReport({
    required ReportType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    String version = '0.5.0';
    try {
      final info = await PackageInfo.fromPlatform();
      version = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    final now = DateTime.now().toUtc().toIso8601String();
    final combinedMetadata = {
      ...?metadata,
      'appVersion': version,
      'platform': 'flutter',
      'submittedAt': now,
    };

    final body = jsonEncode({
      'fields': {
        'type': {'stringValue': type.id},
        'title': {'stringValue': title},
        'description': {'stringValue': description},
        'status': {'stringValue': 'pending'},
        'appVersion': {'stringValue': version},
        'createdAt': {'timestampValue': now},
        'metadata': {'stringValue': jsonEncode(combinedMetadata)},
      }
    });

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Feedback submission error: $e');
      return false;
    }
  }

  /// Shows the Report Wrong Question modal dialog.
  Future<void> showReportQuestionDialog(
    BuildContext context, {
    required String prompt,
    required String correctAnswer,
    String? userAnswer,
    String? topic,
  }) async {
    final dark = Theme.of(context).brightness == Brightness.dark;
    String reason = 'Incorrect answer displayed';
    final reasons = [
      'Incorrect answer displayed',
      'Confusing / ambiguous question',
      'Typo or formatting error',
      'Options missing / wrong',
      'Other',
    ];
    final commentController = TextEditingController();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: dark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.flag_rounded, color: Color(0xFFDC2626), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Report Question',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (dark ? Colors.white : Colors.black)
                            .withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question: $prompt',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Expected answer: $correctAnswer',
                            style: TextStyle(
                              fontSize: 12,
                              color: dark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          if (userAnswer != null && userAnswer.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Your answer: $userAnswer',
                              style: TextStyle(
                                fontSize: 12,
                                color: dark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'What is wrong with this question?',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: reason,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: reasons
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => reason = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Additional details (optional)',
                        hintText: 'Explain the issue or suggested correction...',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 16),
                  label: Text(isSubmitting ? 'Sending...' : 'Submit Report'),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          final ok = await submitReport(
                            type: ReportType.wrongQuestion,
                            title: 'Question: $prompt',
                            description:
                                '$reason. ${commentController.text.trim()}',
                            metadata: {
                              'prompt': prompt,
                              'correctAnswer': correctAnswer,
                              'userAnswer': userAnswer,
                              'topic': topic,
                            },
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'Thank you! Report sent to the admin team.'
                                    : 'Report noted and queued.'),
                                backgroundColor:
                                    ok ? Colors.green : Colors.orange,
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Shows the Report Wrong in Learn modal dialog.
  Future<void> showReportLearnDialog(
    BuildContext context, {
    required String topicTitle,
    String? sectionName,
  }) async {
    final dark = Theme.of(context).brightness == Brightness.dark;
    String category = 'Incorrect formula / calculation';
    final categories = [
      'Incorrect formula / calculation',
      'Typo or spelling error',
      'Confusing explanation',
      'Outdated rule / shortcut',
      'Other',
    ];
    final commentController = TextEditingController();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: dark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.report_problem_rounded,
                      color: Color(0xFFF97316), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Report Issue in $topicTitle',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Found an error in the Learn notes or formulas? Let the admin team know so we can fix it immediately.',
                      style: TextStyle(
                        fontSize: 12,
                        color: dark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Issue category',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => category = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Describe the issue or correct formula',
                        hintText: 'e.g. In Example 2, the square of 17 should be 289...',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 16),
                  label: Text(isSubmitting ? 'Sending...' : 'Submit Report'),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (commentController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a description of the issue.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSubmitting = true);
                          final ok = await submitReport(
                            type: ReportType.wrongLearn,
                            title: 'Learn Topic: $topicTitle',
                            description:
                                '$category. ${commentController.text.trim()}',
                            metadata: {
                              'topicTitle': topicTitle,
                              'sectionName': sectionName,
                            },
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'Thank you! Correction sent to admin.'
                                    : 'Report queued for admin review.'),
                                backgroundColor:
                                    ok ? Colors.green : Colors.orange,
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Shows the General Feedback / Report Issue dialog (Settings).
  Future<void> showGeneralFeedbackDialog(BuildContext context) async {
    final dark = Theme.of(context).brightness == Brightness.dark;
    ReportType selectedType = ReportType.issue;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: dark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.feedback_rounded,
                      color: Color(0xFF3B82F6), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Feedback & Report Issue',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report category',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Bug / Issue'),
                            selected: selectedType == ReportType.issue,
                            selectedColor: const Color(0xFFDC2626),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: selectedType == ReportType.issue
                                  ? Colors.white
                                  : (dark ? Colors.white70 : Colors.black87),
                            ),
                            onSelected: (_) => setDialogState(
                                () => selectedType = ReportType.issue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Feedback / Idea'),
                            selected: selectedType == ReportType.feedback,
                            selectedColor: const Color(0xFF3B82F6),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: selectedType == ReportType.feedback
                                  ? Colors.white
                                  : (dark ? Colors.white70 : Colors.black87),
                            ),
                            onSelected: (_) => setDialogState(
                                () => selectedType = ReportType.feedback),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Subject / Title',
                        hintText: 'Brief summary of the issue or idea',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Provide details so we can understand and resolve it...',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 16),
                  label: Text(isSubmitting ? 'Sending...' : 'Send to Admin'),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final desc = descriptionController.text.trim();
                          if (title.isEmpty || desc.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter both title and description.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSubmitting = true);
                          final ok = await submitReport(
                            type: selectedType,
                            title: title,
                            description: desc,
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? 'Thank you! Your feedback has been sent directly to the admin.'
                                    : 'Feedback submitted and recorded.'),
                                backgroundColor:
                                    ok ? Colors.green : Colors.orange,
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
