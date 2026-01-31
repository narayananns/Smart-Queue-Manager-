import 'package:flutter/material.dart';
import '../../models/queue_item.dart';
import '../main/create_queue_screen.dart';

// -----------------------------------------------------------------------------
// State Management: QueueController
// -----------------------------------------------------------------------------
class QueueController extends ChangeNotifier {
  final List<QueueItem> _waitingQueue = [];
  QueueItem? _currentClient;
  bool _isProcessing = false;
  final int initialCount;

  QueueController({this.initialCount = 10}) {
    _initMockData();
  }

  // Getters
  List<QueueItem> get waitingQueue => List.unmodifiable(_waitingQueue);
  QueueItem? get currentClient => _currentClient;
  bool get isProcessing => _isProcessing;

  void _initMockData() {
    _waitingQueue.addAll(QueueItem.generateMockData(count: initialCount));
    notifyListeners();
  }

  // Start Next Client Logic
  void startNextClient(BuildContext context) {
    if (_waitingQueue.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No clients in queue")));
      return;
    }

    // Remove first item from waitingQueue
    final nextClient = _waitingQueue.removeAt(0);

    // Assign it to currentClient
    _currentClient = nextClient..status = QueueStatus.inProgress;
    _isProcessing = true;

    notifyListeners();
  }

  // Complete Current Client Logic
  void completeCurrentClient() {
    if (_currentClient != null) {
      _currentClient!.status = QueueStatus.completed;
      _currentClient = null;
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Add Participant Logic
  void addParticipant(String name, String type) {
    // Auto-generated Queue ID logic (Mocked for now)
    final newId =
        'Q-${100 + _waitingQueue.length + 10}'; // Offset to avoid clash
    final newItem = QueueItem(
      id: newId,
      name: name,
      type: type,
      joinedAt: DateTime.now(),
    );

    _waitingQueue.add(newItem);
    notifyListeners();
  }

  // Remove Participant
  void removeParticipant(String id) {
    _waitingQueue.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}

// -----------------------------------------------------------------------------
// Screen: LiveQueueScreen
// -----------------------------------------------------------------------------
class LiveQueueScreen extends StatefulWidget {
  final String branchName;
  final int initialQueueCount;

  const LiveQueueScreen({
    super.key,
    this.branchName = "Head Branch",
    this.initialQueueCount = 10,
  });

  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen> {
  late final QueueController _controller;
  // Local state for queue details - defaulting to mock values
  late String _branchName;
  String _category = "General";
  String _address = "123 Main St";
  String _description = "Best service in town";
  String _processTime = "15";

  @override
  void initState() {
    super.initState();
    _controller = QueueController(initialCount: widget.initialQueueCount);
    _branchName = widget.branchName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddParticipantSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddParticipantSheet(
          onSubmit: (name, type) {
            _controller.addParticipant(name, type);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_branchName),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              // Handle actions
              if (value == 'edit') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateQueueScreen(
                      isEditing: true,
                      initialQueueName: _branchName,
                      initialCategory: _category,
                      initialAddress: _address,
                      initialDescription: _description,
                      initialProcessTime: _processTime,
                    ),
                  ),
                );

                if (result != null && result is Map) {
                  setState(() {
                    _branchName = result['queueName'];
                    _category = result['category'];
                    _address = result['address'];
                    _description = result['description'];
                    _processTime = result['processTime'];
                  });
                }
              } else if (value == 'share') {
                // Share logic
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
                const PopupMenuItem<String>(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  _controller.isProcessing
                      ? "Client in Progress (1)"
                      : "No Client in Progress",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),

              // Current Client Section
              CurrentClientCard(
                client: _controller.currentClient,
                isProcessing: _controller.isProcessing,
                onComplete: _controller.completeCurrentClient,
              ),

              // Divider / Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  "Waiting Queue (${_controller.waitingQueue.length})",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),

              // Waiting List
              Expanded(
                child: _controller.waitingQueue.isEmpty
                    ? Center(
                        child: Text(
                          "Queue is empty",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _controller.waitingQueue.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final item = _controller.waitingQueue[index];
                          // Show start icon only for first item if no client is in progress
                          final showStartAction =
                              index == 0 && !_controller.isProcessing;

                          return QueueListItem(
                            item: item,
                            index: index + 1,
                            showStartAction: showStartAction,
                            onStart: () => _controller.startNextClient(context),
                            onRemove: () =>
                                _controller.removeParticipant(item.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddParticipantSheet,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.person_add),
        label: const Text("Add Participant"),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Widget: CurrentClientCard
// -----------------------------------------------------------------------------
class CurrentClientCard extends StatelessWidget {
  final QueueItem? client;
  final bool isProcessing;
  final VoidCallback onComplete;

  const CurrentClientCard({
    super.key,
    required this.client,
    required this.isProcessing,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (client == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(20),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 40,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Client in Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the play button on the waiting list to serve the next customer.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Client",
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client!.id,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  client!.type,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Started: ${TimeOfDay.fromDateTime(DateTime.now()).format(context)}", // Show simple time for demo
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Complete Client"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Widget: QueueListItem
// -----------------------------------------------------------------------------
class QueueListItem extends StatelessWidget {
  final QueueItem item;
  final int index;
  final bool showStartAction;
  final VoidCallback onStart;
  final VoidCallback onRemove;

  const QueueListItem({
    super.key,
    required this.item,
    required this.index,
    required this.showStartAction,
    required this.onStart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade50,
          child: Text(
            "#$index",
            style: const TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item.name, // Displaying Name here, ID could be secondary
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("${item.id} • ${item.type}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showStartAction)
              IconButton(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                color: Colors.green,
                iconSize: 32,
                tooltip: "Start Processing",
              ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.red.shade400,
              tooltip: "Remove from Queue",
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Widget: queueListItem
// -----------------------------------------------------------------------------
class AddParticipantSheet extends StatefulWidget {
  final Function(String name, String type) onSubmit;

  const AddParticipantSheet({super.key, required this.onSubmit});

  @override
  State<AddParticipantSheet> createState() => _AddParticipantSheetState();
}

class _AddParticipantSheetState extends State<AddParticipantSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = "General";
  final List<String> _types = ["General", "Priority", "VIP", "Consultation"];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _nameController.text.trim().isEmpty
            ? "Guest"
            : _nameController.text.trim(),
        _selectedType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Add Participant",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name (Optional)",
                hintText: "Guest Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: "Queue Type",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _types.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Add to Queue"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
