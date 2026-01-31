import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../screens/main/create_queue_screen.dart';
import 'live_queue_screen.dart';

class QueueDetailsScreen extends StatefulWidget {
  final String queueName;
  final String queueId;
  final String category;

  const QueueDetailsScreen({
    super.key,
    required this.queueName,
    required this.queueId,
    required this.category,
  });

  @override
  State<QueueDetailsScreen> createState() => _QueueDetailsScreenState();
}

class _QueueDetailsScreenState extends State<QueueDetailsScreen> {
  final GlobalKey _qrKey = GlobalKey();

  // Local state
  late String _queueName;
  late String _category;
  String _address = "123 Main St";
  String _description = "Best service in town";
  String _processTime = "15";

  @override
  void initState() {
    super.initState();
    _queueName = widget.queueName;
    _category = widget.category;
  }

  String get _queueLink => "https://koku.app/queue/${widget.queueId}";

  Future<void> _saveQrCode() async {
    try {
      if (!await Gal.hasAccess()) {
        await Gal.requestAccess();
      }

      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("QR Code saved to Gallery"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving QR Code: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddParticipantDialog() {
    final TextEditingController peopleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Participant"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("How many people would you like to add to the queue?"),
              const SizedBox(height: 20),
              TextField(
                controller: peopleController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Number Of People",
                  hintText: "Eg : 20",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (peopleController.text.isNotEmpty) {
                  Navigator.pop(context); // Close dialog

                  int count = int.tryParse(peopleController.text) ?? 10;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LiveQueueScreen(
                        branchName: _queueName,
                        initialQueueCount: count,
                      ),
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Added ${peopleController.text} people to the queue",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_queueName),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateQueueScreen(
                      isEditing: true,
                      initialQueueName: _queueName,
                      initialCategory: _category,
                      initialAddress: _address,
                      initialDescription: _description,
                      initialProcessTime: _processTime,
                    ),
                  ),
                );

                if (result != null && result is Map) {
                  setState(() {
                    _queueName = result['queueName'];
                    _category = result['category'];
                    _address = result['address'];
                    _description = result['description'];
                    _processTime = result['processTime'];
                  });
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // No Participant Image/Icon placeholder if needed, or just text
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 10),
            const Text(
              "No Participant Yet!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Please share the queue link or Copy the ID.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Queue Link Section
            _buildInfoCard(
              context,
              label: "Queue Link",
              value: _queueLink,
              icon: Icons.share,
              onAction: () async {
                await Share.share('Join my queue "$_queueName" at $_queueLink');
              },
            ),

            const SizedBox(height: 10),

            // Queue ID Section
            _buildInfoCard(
              context,
              label: "Queue ID",
              value: widget.queueId,
              icon: Icons.copy,
              onAction: () {
                Clipboard.setData(ClipboardData(text: widget.queueId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Queue ID copied to clipboard")),
                );
              },
            ),

            const SizedBox(height: 20),

            // QR Code Section
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: _queueLink,
                      version: QrVersions.auto,
                      size: 200.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.deepPurple,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Scan Me",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ), // End of RepaintBoundary

            const SizedBox(height: 20),

            // Print Button
            OutlinedButton.icon(
              onPressed: _saveQrCode,
              icon: const Icon(Icons.print_rounded),
              label: const Text("Print QR Code"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddParticipantDialog,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          "Add Participant",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAction,
            icon: Icon(icon, color: Colors.deepPurple),
            tooltip: label == "Queue Link" ? "Share Link" : "Copy ID",
          ),
        ],
      ),
    );
  }
}
