import 'package:tools/tools.dart';

final List<MarketplaceModule> marketplaceRegistry = [
  MarketplaceModule(
    id: 'auth-firebase',
    name: 'Firebase Auth Elite',
    description:
        'Complete Authentication system with Firebase, UI, and Repository.',
    dependencies: ['firebase_auth', 'google_sign_in'],
    files: {
      'lib/core/services/auth/auth_service.dart': '''
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Stream<User?> get user => _auth.authStateChanges();
  
  Future<void> signOut() => _auth.signOut();
}
''',
    },
  ),
  MarketplaceModule(
    id: 'chat-ui-base',
    name: 'Standard Chat UI',
    description: 'Scaffold a basic chat interface with message bubbles.',
    dependencies: ['flutter_chat_ui', 'flutter_chat_types'],
    files: {
      'lib/shared/widgets/chat_bubble.dart': '''
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: const TextStyle(color: Colors.white)));
  }
}
''',
    },
  ),
];
