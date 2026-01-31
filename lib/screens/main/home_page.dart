import 'package:flutter/material.dart';
import '../auth_screens/login_screen.dart';
import 'create_queue_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _queueIdController = TextEditingController();

  @override
  void dispose() {
    _queueIdController.dispose();
    super.dispose();
  }

  void _handleJoinQueue() {
    if (_queueIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Queue Link or ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Logic to join queue would go here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joining Queue: ${_queueIdController.text}')),
    );
  }

  void _handleMenuSelection(String value) {
    if (!mounted) return;

    if (value == 'Logout') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected: $value')));
    // Navigate to respective screens if they exist
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          "Smart Q Manager",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notifications clicked")),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'Invite Friends',
                  child: ListTile(
                    leading: Icon(Icons.person_add, color: Colors.deepPurple),
                    title: Text('Invite Friends'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'Rate Smart Queue',
                  child: ListTile(
                    leading: Icon(Icons.star, color: Colors.deepPurple),
                    title: Text('Rate Smart Queue'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'Contact Us',
                  child: ListTile(
                    leading: Icon(Icons.contact_mail, color: Colors.deepPurple),
                    title: Text('Contact Us'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'Terms And Conditions',
                  child: ListTile(
                    leading: Icon(Icons.article, color: Colors.deepPurple),
                    title: Text('Terms And Conditions'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'Privacy and Policy',
                  child: ListTile(
                    leading: Icon(Icons.privacy_tip, color: Colors.deepPurple),
                    title: Text('Privacy and Policy'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'About',
                  child: ListTile(
                    leading: Icon(Icons.info, color: Colors.deepPurple),
                    title: Text('About'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'Logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.deepPurple),
                    title: Text('Logout'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: h * 0.05),
              // Header Image or Illustration could go here
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.people_alt,
                    size: 50,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              SizedBox(height: h * 0.03),
              const Text(
                "We are here to assist you\nwith the Queue Manager",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: h * 0.015),
              const Text(
                "Focus on what matters , Let us manage the queue for you!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: h * 0.05),
              TextField(
                controller: _queueIdController,
                decoration: const InputDecoration(
                  labelText: "Enter the Queue Link Or Id",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  hintText: "e.g. 12345 or https://...",
                ),
              ),
              SizedBox(height: h * 0.03),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _handleJoinQueue,
                child: const Text(
                  "Join Queue",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: h * 0.02),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.deepPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.deepPurple,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("QR Scan clicked")),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text(
                  "Scan QR code",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateQueueScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Create a Queue"),
      ),
    );
  }
}
