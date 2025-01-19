import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!; // Mendapatkan pengguna yang sedang login
  }

  // Fungsi untuk mengirim pesan
  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      return; // Jangan kirim pesan jika input kosong
    }

    await _firestore.collection('messages').add({
      'sender': _user.email ?? 'Anonymous',
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear(); // Bersihkan input setelah mengirim pesan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Customer"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _auth.signOut(); // Keluar dari akun
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Menampilkan daftar pesan dari Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageSender = message['sender'];
                  var messageText = message['message'];

                  var messageWidget =
                      MessageWidget(messageSender, messageText);
                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  children: messageWidgets,
                );
              },
            ),
          ),
          // Input untuk menulis pesan baru
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan pesan
class MessageWidget extends StatelessWidget {
  final String sender;
  final String message;

  MessageWidget(this.sender, this.message);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(sender, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
    );
  }
}
