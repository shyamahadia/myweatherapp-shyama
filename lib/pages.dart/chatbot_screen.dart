import 'package:flutter/material.dart';
import 'chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  final String openAiApiKey;
  final String weatherApiKey;

  const ChatbotScreen({
    super.key,
    required this.openAiApiKey,
    required this.weatherApiKey,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages =
      []; // [{'sender':'user','text':'...'}]

  late ChatbotService _chatbotService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print("ChatbotScreen initState called");
    _chatbotService = ChatbotService(
      openAiApiKey: widget.openAiApiKey,
      weatherApiKey: widget.weatherApiKey,
    );
  }

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    print("Sending message: $input");

    setState(() {
      _messages.add({'sender': 'user', 'text': input});
      _isLoading = true;
      print("_isLoading set to true");
    });
    _controller.clear();

    try {
      final response = await _chatbotService.getResponse(input);
      print("Response received: $response");
      setState(() {
        _messages.add({'sender': 'bot', 'text': response});
      });
    } catch (e) {
      print("Error in getResponse: $e");
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': "Sorry, I couldn't process that.",
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
        print("_isLoading set to false");
      });
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['sender'] == 'user';
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message['text'] ?? '',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("ChatbotScreen build called");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Chatbot',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 21, 36, 44),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 110, 142, 157),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) {
                      if (!_isLoading) _sendMessage();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Need weather advice? Just ask!',
                      hintStyle: TextStyle(color: Colors.blueGrey),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
