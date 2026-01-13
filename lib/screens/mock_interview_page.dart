import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../services/firebase_ai_service.dart';
import '../features/mock_interview/domain/entities/interview_question.dart';

final interviewFirebaseAIProvider = Provider<FirebaseAIService?>((ref) {
  // Firebase AI service uses Firebase authentication
  try {
    return FirebaseAIService();
  } catch (e) {
    // Log the error but don't crash the app
    // The service will be null if Firebase is not configured
    return null;
  }
});

enum InterviewState {
  greeting, // AI greeting and asking for field
  fieldSelected, // User has selected field, AI will ask questions
  questionAsked, // AI has asked a question with options
  waitingForAnswer, // Waiting for user to select an answer
}

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
  InterviewState _interviewState = InterviewState.greeting;
  String? _selectedField;
  InterviewQuestion? _currentQuestion;
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    // Don't auto-initialize - wait for user input
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startNewInterview() async {
    setState(() {
      _interviewState = InterviewState.greeting;
      _selectedField = null;
      _currentQuestion = null;
      _selectedAnswerIndex = null;
      _messages.clear();
    });
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
      final firebaseAI = ref.read(interviewFirebaseAIProvider);
      if (firebaseAI == null) {
        throw Exception('Firebase AI is not configured');
      }

      // Handle different interview states
      if (_interviewState == InterviewState.greeting) {
        // User provided their interview topic/field preference
        _selectedField = text;
        setState(() {
          _interviewState = InterviewState.fieldSelected;
        });
        
        // Add AI acknowledgment message
        setState(() {
          _messages.add(ChatMessage(
            text: 'Great! Let\'s start practicing for your $text interview. I\'ll ask you questions and provide feedback.',
            isUser: false,
          ));
        });
        _scrollToBottom();
        
        // Generate first question
        await _generateFirstQuestion(firebaseAI, text);
      } else if (_interviewState == InterviewState.waitingForAnswer && _selectedAnswerIndex != null) {
        // User selected an answer, generate next question
        await _generateNextQuestion(firebaseAI, _selectedAnswerIndex!);
        setState(() {
          _selectedAnswerIndex = null;
        });
      } else {
        // User typed a message during interview - treat as conversation
        final response = await firebaseAI.generateText(
          prompt: '''
You are an AI interview coach. The user is practicing for a $text interview.

User said: "$text"

Respond briefly and professionally. If they're asking a question, answer it. If they want to continue, acknowledge and move forward with the interview.
''',
        );
        
        setState(() {
          _messages.add(ChatMessage(text: response.trim(), isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: e.toString().contains('Firebase') || e.toString().contains('not configured')
              ? '⚠️ Firebase AI is not configured. Please ensure Firebase is properly set up to use AI interview features.'
              : 'I apologize, but I encountered an error. Could you please try again?',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _generateFirstQuestion(FirebaseAIService firebaseAI, String field) async {
    try {
      final jsonSchema = '''
{
  "type": "object",
  "properties": {
    "question": {
      "type": "string",
      "description": "The interview question"
    },
    "options": {
      "type": "array",
      "items": {"type": "string"},
      "minItems": 4,
      "maxItems": 4,
      "description": "Exactly 4 multiple choice options"
    },
    "correctAnswerIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 3,
      "description": "Index of the correct answer (0-3)"
    },
    "explanation": {
      "type": "string",
      "description": "Brief explanation of why the correct answer is right"
    }
  },
  "required": ["question", "options", "correctAnswerIndex", "explanation"]
}
''';

      final prompt = '''
Generate a mock interview question for someone practicing interviews for: $field

Create a relevant, professional interview question with exactly 4 multiple choice options. This should be a typical question asked in interviews for this specific role/field.

Requirements:
- Question should be clear and relevant to $field
- Provide exactly 4 options (A, B, C, D style)
- One option should be the clearly correct or best answer
- Options should be plausible and reasonable
- Include a brief explanation for the correct answer

Return the question in JSON format matching the schema.
''';

      final response = await firebaseAI.generateStructuredResponse(
        prompt: prompt,
        jsonSchema: jsonSchema,
      );

      final question = InterviewQuestion.fromJson(response);
      
      setState(() {
        _currentQuestion = question;
        _interviewState = InterviewState.questionAsked;
        _messages.add(ChatMessage(
          text: 'Great! Let\'s start with a question about $field:',
          isUser: false,
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      // Fallback to simple text generation if structured fails
      final fallbackResponse = await firebaseAI.generateText(
        prompt: '''
You are conducting a mock interview. The user wants to practice for: $field

Acknowledge their choice briefly (1 sentence) and ask the first interview question relevant to $field. Make it a typical question for this role/field.
''',
      );

      setState(() {
        _messages.add(ChatMessage(text: fallbackResponse.trim(), isUser: false));
        _interviewState = InterviewState.fieldSelected;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _generateNextQuestion(FirebaseAIService firebaseAI, int? selectedAnswerIndex) async {
    try {
      final jsonSchema = '''
{
  "type": "object",
  "properties": {
    "question": {
      "type": "string",
      "description": "The interview question"
    },
    "options": {
      "type": "array",
      "items": {"type": "string"},
      "minItems": 4,
      "maxItems": 4,
      "description": "Exactly 4 multiple choice options"
    },
    "correctAnswerIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 3,
      "description": "Index of the correct answer (0-3)"
    },
    "explanation": {
      "type": "string",
      "description": "Brief explanation of why the correct answer is right"
    }
  },
  "required": ["question", "options", "correctAnswerIndex", "explanation"]
}
''';

      String prompt;
      if (selectedAnswerIndex != null && _currentQuestion != null) {
        final wasCorrect = selectedAnswerIndex == _currentQuestion!.correctAnswerIndex;
        final selectedOption = _currentQuestion!.options[selectedAnswerIndex];
        
        prompt = '''
The user is practicing mock interviews for: ${_selectedField ?? 'their chosen interview'}

Previous question: ${_currentQuestion!.question}
User selected: $selectedOption (${wasCorrect ? 'Correct' : 'Incorrect'})

Generate the next interview question for this interview type. Create a relevant, professional interview question with exactly 4 multiple choice options.

Requirements:
- Question should be relevant to $_selectedField
- Provide exactly 4 options (A, B, C, D style)
- One option should be the clearly correct or best answer
- Options should be plausible and reasonable
- Include a brief explanation for the correct answer

Return the question in JSON format matching the schema.
''';
      } else {
        prompt = '''
Generate a mock interview question for someone practicing interviews for: ${_selectedField ?? 'their chosen interview'}

Create a relevant, professional interview question with exactly 4 multiple choice options. This should be a typical question asked in interviews for this role/field.

Requirements:
- Question should be clear and relevant to $_selectedField
- Provide exactly 4 options (A, B, C, D style)
- One option should be the clearly correct or best answer
- Options should be plausible and reasonable
- Include a brief explanation for the correct answer

Return the question in JSON format matching the schema.
''';
      }

      final response = await firebaseAI.generateStructuredResponse(
        prompt: prompt,
        jsonSchema: jsonSchema,
      );

      final question = InterviewQuestion.fromJson(response);
      
      setState(() {
        _currentQuestion = question;
        _interviewState = InterviewState.questionAsked;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      // Fallback to simple text generation if structured fails
      final fallbackResponse = await firebaseAI.generateText(
        prompt: '''
You are conducting a mock interview. The user is practicing for: ${_selectedField ?? 'their chosen interview'}

Ask the next interview question relevant to this interview type. Make it a typical question for this role/field.
''',
      );

      setState(() {
        _messages.add(ChatMessage(text: fallbackResponse.trim(), isUser: false));
        _interviewState = InterviewState.fieldSelected;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _selectAnswer(int index) {
    if (_currentQuestion == null || _isLoading) return;

    setState(() {
      _selectedAnswerIndex = index;
      _interviewState = InterviewState.waitingForAnswer;
      
      final wasCorrect = index == _currentQuestion!.correctAnswerIndex;
      final selectedOption = _currentQuestion!.options[index];
      
      _messages.add(ChatMessage(
        text: 'You selected: $selectedOption',
        isUser: true,
      ));
      
      // Show feedback
      String feedback = wasCorrect 
          ? '✅ Correct! ${_currentQuestion!.explanation ?? 'Well done!'}'
          : '❌ Not quite. ${_currentQuestion!.explanation ?? 'The correct answer is: ${_currentQuestion!.options[_currentQuestion!.correctAnswerIndex]}'}';
      
      _messages.add(ChatMessage(
        text: feedback,
        isUser: false,
      ));
      
      _isLoading = true;
    });
    _scrollToBottom();
    
    // Generate next question after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final firebaseAI = ref.read(interviewFirebaseAIProvider);
        if (firebaseAI != null) {
          _generateNextQuestion(firebaseAI, index);
        }
      }
    });
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
              _startNewInterview();
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
                          'What interview are you preparing for?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Type your answer below (e.g., "Software Engineer at Google", "Data Scientist", "Product Manager", etc.)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
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
                      return _buildMessageBubble(message, index);
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
              child: _interviewState == InterviewState.questionAsked
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: _interviewState == InterviewState.greeting
                                  ? 'What interview are you preparing for? (e.g., Software Engineer, Data Scientist, Product Manager...)'
                                  : 'Type your message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              filled: true,
                              fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey.shade100,
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _sendMessage(),
                            enabled: !_isLoading,
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

  Widget _buildMessageBubble(ChatMessage message, int index) {
    // If this is the last AI message and we have a current question, show the question with options
    if (!message.isUser && 
        index == _messages.length - 1 && 
        _currentQuestion != null && 
        _interviewState == InterviewState.questionAsked &&
        !_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.text.isNotEmpty) ...[
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    _currentQuestion!.question,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_currentQuestion!.options.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _selectAnswer(i),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryColor, width: 2),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + i), // A, B, C, D
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _currentQuestion!.options[i],
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Regular message bubble
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
