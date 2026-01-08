import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/gemini_service.dart';

final interviewGeminiProvider = Provider<GeminiService?>((ref) {
  // API key is handled by GeminiService constructor via GeminiConfig
  try {
    return GeminiService();
  } catch (e) {
    // Log the error but don't crash the app
    // The service will be null if API key is not configured
    return null;
  }
});

class MockInterviewPage extends ConsumerStatefulWidget {
  const MockInterviewPage({super.key});

  @override
  ConsumerState<MockInterviewPage> createState() => _MockInterviewPageState();
}

class _MockInterviewPageState extends ConsumerState<MockInterviewPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _selectedInterviewType = 'Technical';

  @override
  void initState() {
    super.initState();
    _initializeInterview();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeInterview() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final geminiService = ref.read(interviewGeminiProvider);
      if (geminiService == null) {
        throw Exception('Gemini API key is not configured');
      }
      
      final greeting = await geminiService.generateText(
        prompt: '''
You are conducting a ${_selectedInterviewType ?? 'Technical'} interview. Start with a friendly greeting and ask the first interview question. 
Keep it conversational and professional. Ask ONE question at a time.
''',
      );

      setState(() {
        _messages.add(ChatMessage(text: greeting, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: e.toString().contains('API key') 
              ? '⚠️ Gemini API key is not configured. Please configure your API key in settings to use AI interview features.\n\nWelcome! I\'m your interview coach. Let\'s start: Tell me about yourself.'
              : 'Welcome! I\'m your AI interview coach. Let\'s start with a question: Tell me about yourself.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final geminiService = ref.read(interviewGeminiProvider);
      if (geminiService == null) {
        throw Exception('Gemini API key is not configured');
      }
      
      final conversationHistory = _messages.map((m) => m.text).join('\n');
      
      final response = await geminiService.generateText(
        prompt: '''
You are conducting a ${_selectedInterviewType ?? 'Technical'} interview. 

Previous conversation:
$conversationHistory

Based on the candidate's response, provide:
1. Brief acknowledgment (1 sentence)
2. Ask the next relevant interview question
3. Keep it natural and conversational
4. Ask ONE question at a time

Type: ${_selectedInterviewType}
''',
      );

      setState(() {
        _messages.add(ChatMessage(text: response.trim(), isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: e.toString().contains('API key') 
              ? '⚠️ Gemini API key is not configured. Please configure your API key to use AI interview features.'
              : 'I apologize, but I encountered an error. Could you please rephrase your answer?',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _endInterview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Interview?'),
        content: const Text('Are you sure you want to end this interview session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              _initializeInterview();
            },
            child: const Text('Start New Interview'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Interview'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedInterviewType = value;
                _messages.clear();
              });
              _initializeInterview();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Technical', child: Text('Technical')),
              const PopupMenuItem(value: 'HR/Behavioral', child: Text('HR/Behavioral')),
              const PopupMenuItem(value: 'System Design', child: Text('System Design')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedInterviewType ?? 'Technical'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _endInterview,
            tooltip: 'New Interview',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'AI Mock Interview',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Practice your interview skills with AI',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your answer...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser ? AppTheme.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}
