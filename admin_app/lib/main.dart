import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:speed_math_content/curriculum.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'speed-math-app-1'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: 'speed-math-app-1.firebaseapp.com'),
  ));
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Speed Math Admin',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: const AuthGate(),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final user = snapshot.data;
      if (user == null) {
        return const LoginScreen();
      }
      return RoleGate(user: user);
    },
  );
}

class RoleGate extends StatefulWidget {
  final User user;
  const RoleGate({super.key, required this.user});
  @override State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  bool _loading = true;

  @override void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('admins').doc(widget.user.uid).get();
      if (!doc.exists) {
        await _signOutWithError('Not authorized as an administrator');
        return;
      }
      final role = doc.data()?['role'];
      if (role != 'admin' && role != 'owner') {
        await _signOutWithError('Not authorized as an administrator');
        return;
      }
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      // Typically FirebaseException with permission-denied
      await _signOutWithError('Not authorized as an administrator');
    }
  }

  Future<void> _signOutWithError(String message) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const DashboardScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginState();
}
class _LoginState extends State<LoginScreen> {
  bool busy = false;
  String? error;

  Future<void> login() async {
    setState(() => busy = true);
    try {
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = e.message ?? 'Sign-in failed');
    } finally { 
      if (mounted) setState(() => busy = false); 
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Card(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.admin_panel_settings_rounded, size: 52),
        const SizedBox(height: 12),
        const Text('Speed Math Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 20),
        if (error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(error!, style: const TextStyle(color: Colors.red))),
        FilledButton.icon(
          onPressed: busy ? null : login, 
          icon: const Icon(Icons.login),
          label: Text(busy ? 'Signing in…' : 'Sign in with Google')
        ),
      ]),
    )))),
  );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Curriculum Admin', style: TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(onPressed: FirebaseAuth.instance.signOut, icon: const Icon(Icons.logout_rounded))]),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Draft → Validate → Publish', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Text('${CurriculumCatalog.topics.length} bundled curriculum topics are available as the initial seed.'),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopicListScreen())), icon: const Icon(Icons.library_books_rounded), label: const Text('Manage Topics')),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublishScreen())), icon: const Icon(Icons.publish_rounded), label: const Text('Publish Current Curriculum')),
    ]),
  );
}

class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Topics')),
    body: ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: CurriculumCatalog.topics.length,
      itemBuilder: (_, i) { final t = CurriculumCatalog.topics[i]; return Card(child: ListTile(title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${t.section.name} • ${t.level.name}'), trailing: const Icon(Icons.edit_rounded), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TopicEditorScreen(topic: t))))); },
    ),
  );
}

class TopicEditorScreen extends StatefulWidget {
  const TopicEditorScreen({super.key, required this.topic});
  final LessonTopic topic;
  @override State<TopicEditorScreen> createState() => _EditorState();
}
class _EditorState extends State<TopicEditorScreen> {
  late final TextEditingController summary, concepts, methods, examples, traps, practice;
  bool busy = false;
  @override void initState() { super.initState(); final t = widget.topic; summary = TextEditingController(text: t.summary); concepts = TextEditingController(text: t.concepts.join('\n')); methods = TextEditingController(text: t.methods.join('\n')); examples = TextEditingController(text: t.examples.join('\n')); traps = TextEditingController(text: t.traps.join('\n')); practice = TextEditingController(text: t.practice.join('\n')); }
  @override void dispose() { for (final c in [summary, concepts, methods, examples, traps, practice]) { c.dispose(); } super.dispose(); }
  List<String> lines(String value) => value.split('\n').map((x) => x.trim()).where((x) => x.isNotEmpty).toList();
  Future<void> save() async {
    setState(() => busy = true);
    try {
      final data = widget.topic.toMap();
      data['summary'] = summary.text.trim(); data['concepts'] = lines(concepts.text); data['methods'] = lines(methods.text); data['examples'] = lines(examples.text); data['traps'] = lines(traps.text); data['practice'] = lines(practice.text); data['updatedAt'] = FieldValue.serverTimestamp(); data['updatedBy'] = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('draftTopics').doc(widget.topic.id).set(data, SetOptions(merge: true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved')));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e'))); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.topic.title)), body: ListView(padding: const EdgeInsets.all(16), children: [field('Summary', summary), field('Concepts — one per line', concepts, 6), field('Methods — one per line', methods, 6), field('Examples — one per line', examples, 5), field('Common traps — one per line', traps, 5), field('Practice focus — one per line', practice, 4), const SizedBox(height: 14), FilledButton.icon(onPressed: busy ? null : save, icon: const Icon(Icons.save_rounded), label: Text(busy ? 'Saving…' : 'Save Draft'))]));
  Widget field(String label, TextEditingController c, [int lines = 3]) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: c, maxLines: lines, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));
}

class PublishScreen extends StatefulWidget { const PublishScreen({super.key}); @override State<PublishScreen> createState() => _PublishState(); }
class _PublishState extends State<PublishScreen> {
  bool busy = false; String? message;
  Future<void> publish() async {
    setState(() => busy = true);
    try {
      final drafts = await FirebaseFirestore.instance.collection('draftTopics').get();
      final byId = {for (final d in drafts.docs) d.id: d.data()};
      final topics = CurriculumCatalog.topics.map((t) => byId[t.id] ?? t.toMap()).toList();
      await FirebaseFirestore.instance.collection('publishedContent').doc('current').set({'schemaVersion': 1, 'version': DateTime.now().toUtc().toIso8601String(), 'publishedAt': FieldValue.serverTimestamp(), 'topics': topics});
      if (mounted) setState(() => message = 'Published ${topics.length} topics.');
    } catch (e) { if (mounted) setState(() => message = 'Publish failed: $e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Publish')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.publish_rounded, size: 54), const SizedBox(height: 12), const Text('Publish all current curriculum', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text('The user app reads only the published document and keeps the bundled curriculum as an offline fallback.'), const SizedBox(height: 18), FilledButton.icon(onPressed: busy ? null : publish, icon: const Icon(Icons.cloud_upload_rounded), label: Text(busy ? 'Publishing…' : 'Publish')), if (message != null) Padding(padding: const EdgeInsets.only(top: 14), child: Text(message!))])))));
}
