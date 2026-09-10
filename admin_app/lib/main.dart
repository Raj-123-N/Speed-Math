import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:speed_math_content/curriculum.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
      appId: String.fromEnvironment('FIREBASE_APP_ID'),
      messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
      projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'speed-math-app-1'),
      authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: 'speed-math-app-1.firebaseapp.com'),
    ),
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Math Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
          primary: const Color(0xFF4F46E5),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth & Role Gates
// ─────────────────────────────────────────────────────────────────────────────

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        return RoleGate(user: user);
      },
    );
  }
}

class RoleGate extends StatefulWidget {
  final User user;
  const RoleGate({super.key, required this.user});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  bool _loading = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.user.uid)
          .get();
      if (!doc.exists) {
        await _signOutWithError('Access Denied: You are not authorized as an administrator.');
        return;
      }
      final role = doc.data()?['role'] as String?;
      if (role != 'admin' && role != 'owner') {
        await _signOutWithError('Access Denied: Invalid administrator privileges ($role).');
        return;
      }
      if (mounted) {
        setState(() {
          _role = role;
          _loading = false;
        });
      }
    } catch (e) {
      await _signOutWithError('Authorization Error: Access denied.');
    }
  }

  Future<void> _signOutWithError(String message) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4F46E5)),
              SizedBox(height: 16),
              Text(
                'Verifying admin credentials…',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }
    return MainAdminShell(user: widget.user, role: _role ?? 'admin');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Login Screen
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Sign-in failed');
    } catch (e) {
      if (mounted) setState(() => _error = 'An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Speed Math Admin',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Curriculum Management & User Feedback Portal',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 28),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  FilledButton(
                    onPressed: _busy ? null : _login,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login_rounded, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Sign in with Google',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Restricted to registered administrators only.\nUnauthorized access attempts are blocked by security rules.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
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

// ─────────────────────────────────────────────────────────────────────────────
// Responsive Main Shell
// ─────────────────────────────────────────────────────────────────────────────

class MainAdminShell extends StatefulWidget {
  final User user;
  final String role;
  const MainAdminShell({super.key, required this.user, required this.role});

  @override
  State<MainAdminShell> createState() => _MainAdminShellState();
}

class _MainAdminShellState extends State<MainAdminShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 850;

    final pages = [
      CurriculumDashboard(user: widget.user, role: widget.role),
      FeedbackReportsView(user: widget.user, role: widget.role),
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            // Left Rail
            Container(
              width: 260,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Speed Math',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Admin Console',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const SizedBox(height: 16),
                  // Nav Items
                  _NavTile(
                    icon: Icons.menu_book_rounded,
                    label: 'Curriculum & Drafts',
                    badge: '${CurriculumCatalog.topics.length}',
                    isSelected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _NavTile(
                    icon: Icons.feedback_outlined,
                    label: 'User Reports & Feedback',
                    badgeStream: FirebaseFirestore.instance
                        .collection('reports')
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    isSelected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  const Spacer(),
                  // User Profile & Sign Out
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF4F46E5),
                              backgroundImage: widget.user.photoURL != null
                                  ? NetworkImage(widget.user.photoURL!)
                                  : null,
                              child: widget.user.photoURL == null
                                  ? Text(
                                      (widget.user.displayName ?? widget.user.email ?? 'A')[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.user.displayName ?? 'Administrator',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      widget.role.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF818CF8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFCBD5E1),
                            side: const BorderSide(color: Color(0xFF475569)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 16),
                          label: const Text('Sign Out', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Main Content Area
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      );
    }

    // Narrow / Mobile view
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Curriculum',
          ),
          NavigationDestination(
            icon: Icon(Icons.feedback_outlined),
            selectedIcon: Icon(Icons.feedback_rounded),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Stream<QuerySnapshot>? badgeStream;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeStream,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: badgeStream != null
            ? StreamBuilder<QuerySnapshot>(
                stream: badgeStream,
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              )
            : (badge != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null),
        onTap: onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View 1: Curriculum & Drafts Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class CurriculumDashboard extends StatefulWidget {
  final User user;
  final String role;
  const CurriculumDashboard({super.key, required this.user, required this.role});

  @override
  State<CurriculumDashboard> createState() => _CurriculumDashboardState();
}

class _CurriculumDashboardState extends State<CurriculumDashboard> {
  String _searchQuery = '';
  LearningSection? _filterSection;

  @override
  Widget build(BuildContext context) {
    final allTopics = CurriculumCatalog.topics;
    final filteredTopics = allTopics.where((t) {
      if (_filterSection != null && t.section != _filterSection) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return t.title.toLowerCase().contains(q) ||
            t.summary.toLowerCase().contains(q) ||
            t.section.name.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Curriculum Management',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A)),
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => _openPublishDialog(context),
            icon: const Icon(Icons.cloud_upload_rounded, size: 18),
            label: const Text('Publish Curriculum', style: TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('draftTopics').snapshots(),
        builder: (context, draftSnapshot) {
          final draftDocs = draftSnapshot.data?.docs ?? [];
          final draftIds = draftDocs.map((d) => d.id).toSet();

          return CustomScrollView(
            slivers: [
              // Metric Cards Banner
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _StatCard(
                        title: 'Total Topics',
                        value: '${allTopics.length}',
                        icon: Icons.menu_book_rounded,
                        color: const Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 14),
                      _StatCard(
                        title: 'Modified Drafts',
                        value: '${draftIds.length}',
                        subtitle: draftIds.isNotEmpty ? 'Unpublished changes' : 'Synchronized',
                        icon: Icons.edit_note_rounded,
                        color: draftIds.isNotEmpty ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 14),
                      _StatCard(
                        title: 'Sections',
                        value: '${LearningSection.values.length}',
                        icon: Icons.category_rounded,
                        color: const Color(0xFF06B6D4),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter & Search Controls
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _searchQuery = v),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                                hintText: 'Search topics by title, summary, keyword…',
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          DropdownButton<LearningSection?>(
                            value: _filterSection,
                            hint: const Text('All Sections'),
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Sections')),
                              ...LearningSection.values.map(
                                (s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase())),
                              ),
                            ],
                            onChanged: (s) => setState(() => _filterSection = s),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Topic List Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Topics (${filteredTopics.length})',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                ),
              ),

              // Topics Grid/List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final topic = filteredTopics[index];
                      final isDraft = draftIds.contains(topic.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TopicEditorScreen(topic: topic),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.calculate_outlined, color: Color(0xFF4F46E5), size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            topic.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (isDraft)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'DRAFT MODIFIED',
                                                style: TextStyle(
                                                  color: Color(0xFFD97706),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        topic.summary,
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _Pill(label: topic.section.name.toUpperCase(), color: const Color(0xFF6366F1)),
                                          const SizedBox(width: 6),
                                          _Pill(label: topic.level.name.toUpperCase(), color: const Color(0xFF0EA5E9)),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${topic.concepts.length} concepts • ${topic.methods.length} methods',
                                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredTopics.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openPublishDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const PublishCurriculumDialog());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View 2: User Reports & Feedback Screen
// ─────────────────────────────────────────────────────────────────────────────

class FeedbackReportsView extends StatefulWidget {
  final User user;
  final String role;
  const FeedbackReportsView({super.key, required this.user, required this.role});

  @override
  State<FeedbackReportsView> createState() => _FeedbackReportsViewState();
}

class _FeedbackReportsViewState extends State<FeedbackReportsView> {
  String _statusFilter = 'pending'; // 'all', 'pending', 'resolved'
  String _typeFilter = 'all'; // 'all', 'wrong_question', 'wrong_learn', 'issue', 'feedback'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Feedback & Issue Reports',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Failed to load reports: ${snapshot.error}', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
          }

          final rawDocs = snapshot.data?.docs ?? [];

          // Client-side sort by createdAt descending
          final docs = List<QueryDocumentSnapshot>.from(rawDocs)
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>? ?? {};
              final bData = b.data() as Map<String, dynamic>? ?? {};
              final aDate = _parseDate(aData['createdAt']);
              final bDate = _parseDate(bData['createdAt']);
              return bDate.compareTo(aDate);
            });

          // Compute Counts
          int pendingCount = 0;
          int resolvedCount = 0;
          int wrongQuestionCount = 0;
          int wrongLearnCount = 0;

          for (final d in docs) {
            final data = d.data() as Map<String, dynamic>? ?? {};
            final status = data['status'] as String? ?? 'pending';
            final type = data['type'] as String? ?? '';
            if (status == 'pending') pendingCount++;
            if (status == 'resolved') resolvedCount++;
            if (type == 'wrong_question') wrongQuestionCount++;
            if (type == 'wrong_learn') wrongLearnCount++;
          }

          // Filter
          final filtered = docs.where((d) {
            final data = d.data() as Map<String, dynamic>? ?? {};
            final status = data['status'] as String? ?? 'pending';
            final type = data['type'] as String? ?? '';
            final title = data['title'] as String? ?? '';
            final desc = data['description'] as String? ?? '';
            final metaStr = data['metadata'] as String? ?? '';

            if (_statusFilter != 'all' && status != _statusFilter) return false;
            if (_typeFilter != 'all' && type != _typeFilter) return false;

            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              final match = title.toLowerCase().contains(q) ||
                  desc.toLowerCase().contains(q) ||
                  metaStr.toLowerCase().contains(q);
              if (!match) return false;
            }
            return true;
          }).toList();

          return CustomScrollView(
            slivers: [
              // Summary Metrics Row
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _StatCard(
                        title: 'Pending Action',
                        value: '$pendingCount',
                        icon: Icons.pending_actions_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 14),
                      _StatCard(
                        title: 'Wrong Questions',
                        value: '$wrongQuestionCount',
                        icon: Icons.quiz_rounded,
                        color: const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 14),
                      _StatCard(
                        title: 'Learn Content Errors',
                        value: '$wrongLearnCount',
                        icon: Icons.auto_stories_rounded,
                        color: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(width: 14),
                      _StatCard(
                        title: 'Resolved',
                        value: '$resolvedCount',
                        icon: Icons.task_alt_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Controls
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => setState(() => _searchQuery = v),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                                    hintText: 'Search by question, formula, topic, or description…',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Status:',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569)),
                              ),
                              _FilterChip(
                                label: 'Pending ($pendingCount)',
                                isSelected: _statusFilter == 'pending',
                                color: const Color(0xFFF59E0B),
                                onSelected: () => setState(() => _statusFilter = 'pending'),
                              ),
                              _FilterChip(
                                label: 'Resolved ($resolvedCount)',
                                isSelected: _statusFilter == 'resolved',
                                color: const Color(0xFF10B981),
                                onSelected: () => setState(() => _statusFilter = 'resolved'),
                              ),
                              _FilterChip(
                                label: 'All (${docs.length})',
                                isSelected: _statusFilter == 'all',
                                color: const Color(0xFF64748B),
                                onSelected: () => setState(() => _statusFilter = 'all'),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Type:',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569)),
                              ),
                              _FilterChip(
                                label: 'All Types',
                                isSelected: _typeFilter == 'all',
                                color: const Color(0xFF4F46E5),
                                onSelected: () => setState(() => _typeFilter = 'all'),
                              ),
                              _FilterChip(
                                label: 'Wrong Question',
                                isSelected: _typeFilter == 'wrong_question',
                                color: const Color(0xFFEF4444),
                                onSelected: () => setState(() => _typeFilter = 'wrong_question'),
                              ),
                              _FilterChip(
                                label: 'Learn Content',
                                isSelected: _typeFilter == 'wrong_learn',
                                color: const Color(0xFF8B5CF6),
                                onSelected: () => setState(() => _typeFilter = 'wrong_learn'),
                              ),
                              _FilterChip(
                                label: 'App Issue',
                                isSelected: _typeFilter == 'issue',
                                color: const Color(0xFFEC4899),
                                onSelected: () => setState(() => _typeFilter = 'issue'),
                              ),
                              _FilterChip(
                                label: 'Feedback',
                                isSelected: _typeFilter == 'feedback',
                                color: const Color(0xFF06B6D4),
                                onSelected: () => setState(() => _typeFilter = 'feedback'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Reports List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                sliver: filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline_rounded, size: 56, color: Colors.green.shade300),
                                const SizedBox(height: 12),
                                const Text(
                                  'No reports matching this filter',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF475569)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Everything looks clean and resolved.',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = filtered[index];
                            final data = doc.data() as Map<String, dynamic>? ?? {};
                            return _ReportItemCard(
                              docId: doc.id,
                              data: data,
                              userRole: widget.role,
                            );
                          },
                          childCount: filtered.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is String) {
      final parsed = DateTime.tryParse(val);
      if (parsed != null) return parsed;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report Item Card
// ─────────────────────────────────────────────────────────────────────────────

class _ReportItemCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String userRole;

  const _ReportItemCard({
    required this.docId,
    required this.data,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final type = data['type'] as String? ?? 'feedback';
    final status = data['status'] as String? ?? 'pending';
    final title = data['title'] as String? ?? 'Report';
    final desc = data['description'] as String? ?? '';
    final appVersion = data['appVersion'] as String? ?? '';
    final createdAt = data['createdAt'];

    Map<String, dynamic> metadata = {};
    if (data['metadata'] is String) {
      try {
        metadata = jsonDecode(data['metadata'] as String) as Map<String, dynamic>;
      } catch (_) {}
    } else if (data['metadata'] is Map<String, dynamic>) {
      metadata = data['metadata'] as Map<String, dynamic>;
    }

    final isResolved = status == 'resolved';

    // Visual attributes per type
    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    switch (type) {
      case 'wrong_question':
        typeColor = const Color(0xFFEF4444);
        typeIcon = Icons.quiz_rounded;
        typeLabel = 'WRONG QUESTION';
        break;
      case 'wrong_learn':
        typeColor = const Color(0xFF8B5CF6);
        typeIcon = Icons.auto_stories_rounded;
        typeLabel = 'LEARN CONTENT ERROR';
        break;
      case 'issue':
        typeColor = const Color(0xFFEC4899);
        typeIcon = Icons.bug_report_rounded;
        typeLabel = 'APP BUG / ISSUE';
        break;
      default:
        typeColor = const Color(0xFF06B6D4);
        typeIcon = Icons.lightbulb_outline_rounded;
        typeLabel = 'USER FEEDBACK';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type Pill, Status Pill, Timestamp, Action Buttons
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, color: typeColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        typeLabel,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isResolved
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isResolved ? 'RESOLVED' : 'PENDING',
                    style: TextStyle(
                      color: isResolved ? const Color(0xFF059669) : const Color(0xFFD97706),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (appVersion.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text('v$appVersion', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ],
                const Spacer(),
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title & Description
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                desc,
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
              ),
            ],

            // Context details depending on report type
            if (type == 'wrong_question' && metadata.containsKey('question')) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Question: ',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF475569)),
                        ),
                        Expanded(
                          child: Text(
                            metadata['question']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (metadata['userAnswer'] != null) ...[
                          Text(
                            'User Answer: ${metadata['userAnswer']}  •  ',
                            style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                          ),
                        ],
                        if (metadata['correctAnswer'] != null) ...[
                          Text(
                            'Correct Answer: ${metadata['correctAnswer']}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w700),
                          ),
                        ],
                        if (metadata['topic'] != null) ...[
                          const Spacer(),
                          Text(
                            'Topic: ${metadata['topic']}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (type == 'wrong_learn' && metadata.containsKey('topicTitle')) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark_outline_rounded, size: 16, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 8),
                    Text(
                      'Topic: ${metadata['topicTitle']}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
                    ),
                    if (metadata['sectionName'] != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '•  Section: ${metadata['sectionName']}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 10),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showRawDetailsDialog(context, metadata),
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('View Raw Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _toggleResolve(context, isResolved),
                  icon: Icon(
                    isResolved ? Icons.replay_rounded : Icons.check_circle_outline_rounded,
                    size: 16,
                  ),
                  label: Text(isResolved ? 'Reopen' : 'Mark Resolved'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isResolved ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                    side: BorderSide(
                      color: isResolved ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete Report',
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleResolve(BuildContext context, bool currentlyResolved) async {
    try {
      await FirebaseFirestore.instance.collection('reports').doc(docId).update({
        'status': currentlyResolved ? 'pending' : 'resolved',
        'resolvedAt': currentlyResolved ? null : FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Report?'),
        content: const Text('This will permanently delete this report entry from Firestore.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await FirebaseFirestore.instance.collection('reports').doc(docId).delete();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showRawDetailsDialog(BuildContext context, Map<String, dynamic> metadata) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(data['title'] as String? ?? 'Report Details'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Report ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(docId, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(data['description'] as String? ?? 'None'),
                const SizedBox(height: 10),
                const Text('Metadata Payload:', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    const JsonEncoder.withIndent('  ').convert(metadata),
                    style: const TextStyle(color: Color(0xFF38BDF8), fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  String _formatDate(dynamic val) {
    if (val == null) return '';
    DateTime dt;
    if (val is Timestamp) {
      dt = val.toDate();
    } else if (val is String) {
      final parsed = DateTime.tryParse(val);
      if (parsed == null) return val;
      dt = parsed;
    } else {
      return val.toString();
    }
    final local = dt.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${pad(local.month)}-${pad(local.day)} ${pad(local.hour)}:${pad(local.minute)}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Topic Editor Screen
// ─────────────────────────────────────────────────────────────────────────────

class TopicEditorScreen extends StatefulWidget {
  final LessonTopic topic;
  const TopicEditorScreen({super.key, required this.topic});

  @override
  State<TopicEditorScreen> createState() => _TopicEditorState();
}

class _TopicEditorState extends State<TopicEditorScreen> {
  late final TextEditingController summary;
  late final TextEditingController concepts;
  late final TextEditingController methods;
  late final TextEditingController examples;
  late final TextEditingController traps;
  late final TextEditingController practice;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final t = widget.topic;
    summary = TextEditingController(text: t.summary);
    concepts = TextEditingController(text: t.concepts.join('\n'));
    methods = TextEditingController(text: t.methods.join('\n'));
    examples = TextEditingController(text: t.examples.join('\n'));
    traps = TextEditingController(text: t.traps.join('\n'));
    practice = TextEditingController(text: t.practice.join('\n'));
  }

  @override
  void dispose() {
    summary.dispose();
    concepts.dispose();
    methods.dispose();
    examples.dispose();
    traps.dispose();
    practice.dispose();
    super.dispose();
  }

  List<String> _lines(String val) =>
      val.split('\n').map((x) => x.trim()).where((x) => x.isNotEmpty).toList();

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final data = widget.topic.toMap();
      data['summary'] = summary.text.trim();
      data['concepts'] = _lines(concepts.text);
      data['methods'] = _lines(methods.text);
      data['examples'] = _lines(examples.text);
      data['traps'] = _lines(traps.text);
      data['practice'] = _lines(practice.text);
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['updatedBy'] = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance
          .collection('draftTopics')
          .doc(widget.topic.id)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Draft saved successfully'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          FilledButton.icon(
            onPressed: _busy ? null : _save,
            icon: const Icon(Icons.save_rounded, size: 18),
            label: Text(_busy ? 'Saving…' : 'Save Draft'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _field('Summary', summary, 3),
              _field('Concepts (one per line)', concepts, 6),
              _field('Methods (one per line)', methods, 6),
              _field('Examples (one per line)', examples, 5),
              _field('Common Traps (one per line)', traps, 5),
              _field('Practice Focus (one per line)', practice, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, int lines) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          TextField(
            controller: c,
            maxLines: lines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Publish Dialog
// ─────────────────────────────────────────────────────────────────────────────

class PublishCurriculumDialog extends StatefulWidget {
  const PublishCurriculumDialog({super.key});

  @override
  State<PublishCurriculumDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<PublishCurriculumDialog> {
  bool _busy = false;
  String? _message;

  Future<void> _publish() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final drafts = await FirebaseFirestore.instance.collection('draftTopics').get();
      final byId = {for (final d in drafts.docs) d.id: d.data()};
      final topics = CurriculumCatalog.topics.map((t) => byId[t.id] ?? t.toMap()).toList();

      await FirebaseFirestore.instance.collection('publishedContent').doc('current').set({
        'schemaVersion': 1,
        'version': DateTime.now().toUtc().toIso8601String(),
        'publishedAt': FieldValue.serverTimestamp(),
        'topics': topics,
      });

      if (mounted) {
        setState(() => _message = 'Successfully published ${topics.length} topics (${drafts.docs.length} customized drafts included).');
      }
    } catch (e) {
      if (mounted) setState(() => _message = 'Publish failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cloud_upload_rounded, color: Color(0xFF4F46E5)),
          SizedBox(width: 10),
          Text('Publish Curriculum to Live App'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Publishing compiles all base topics and any customized draft topics into the single live publishedContent/current document.',
              style: TextStyle(height: 1.4, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 12),
            const Text(
              'The user app automatically fetches this payload when online, ensuring fast updates without requiring a Google Play Store release.',
              style: TextStyle(height: 1.4, color: Color(0xFF64748B), fontSize: 13),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _message!.startsWith('Success')
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.startsWith('Success') ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        FilledButton.icon(
          onPressed: _busy ? null : _publish,
          icon: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload_rounded, size: 18),
          label: Text(_busy ? 'Publishing…' : 'Confirm & Publish'),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }
}
