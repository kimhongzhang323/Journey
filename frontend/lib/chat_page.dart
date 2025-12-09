import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class ChatMessage {
  final String content;
  final bool isUser;
  final String type;
  final List<ChecklistItem>? checklist;
  final List<String>? quickActions;
  final DateTime timestamp;

  ChatMessage({required this.content, required this.isUser, this.type = 'text', this.checklist, this.quickActions, DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();
}

class ChecklistItem {
  String title;
  bool isChecked;
  String? action;
  ChecklistItem({required this.title, this.isChecked = false, this.action});
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isVoiceMode = false;
  bool _isSpeaking = false;
  
  String _selectedLanguage = 'english';
  final Map<String, String> _languages = {
    'english': '🇬🇧 English',
    'malay': '🇲🇾 Malay',
    'chinese': '🇨🇳 Chinese',
    'tamil': '🇮🇳 Tamil',
  };

  static const String _backendUrl = 'http://127.0.0.1:8000';

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessages = {
      'english': "Hi! I'm your Government Services Assistant. What can I help you with today lah?",
      'malay': "Hai! Saya pembantu perkhidmatan kerajaan. Macam mana saya boleh bantu hari ni?",
      'chinese': "你好！我是政府服务助手。今天我可以帮你什么啦？",
      'tamil': "வணக்கம்! நான் அரசு சேவை உதவியாளர். இன்று நான் எப்படி உதவ முடியும்?",
    };
    
    _messages.clear();
    _messages.add(ChatMessage(
      content: welcomeMessages[_selectedLanguage]!,
      isUser: false,
      quickActions: _getQuickActions(),
    ));
  }

  List<String> _getQuickActions() {
    final actions = {
      'english': ["🪪 I lost my IC", "🔄 Renew my IC", "📘 Lost passport"],
      'malay': ["🪪 IC saya hilang", "🔄 Baharu IC", "📘 Pasport hilang"],
      'chinese': ["🪪 我的IC不见了", "🔄 更新IC", "📘 护照丢了"],
      'tamil': ["🪪 IC காணாமல்", "🔄 IC புதுப்பி", "📘 பாஸ்போர்ட்"],
    };
    return actions[_selectedLanguage]!;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _speakText(String text) async {
    if (!_isVoiceMode || text.isEmpty) return;
    setState(() => _isSpeaking = true);
    
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'language': _selectedLanguage}),
      );

      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes], 'audio/mpeg');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final audio = html.AudioElement(url);
        audio.onEnded.listen((_) { html.Url.revokeObjectUrl(url); if (mounted) setState(() => _isSpeaking = false); });
        audio.onError.listen((_) { html.Url.revokeObjectUrl(url); if (mounted) setState(() => _isSpeaking = false); });
        await audio.play();
      } else {
        setState(() => _isSpeaking = false);
      }
    } catch (e) {
      setState(() => _isSpeaking = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.black87, duration: const Duration(seconds: 2)));
  }

  void _sendMessage([String? overrideMessage]) async {
    final text = overrideMessage ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() { _messages.add(ChatMessage(content: text, isUser: true)); _isLoading = true; });
    _controller.clear();
    _scrollToBottom();

    try {
      // Pass language to chat API
      final responseData = await _apiService.chat(text, language: _selectedLanguage);
      final responseText = responseData['response'] ?? 'No response';
      final type = responseData['type'] ?? 'text';

      List<ChecklistItem>? checklistItems;
      if (type == 'checklist' && responseData['checklist'] != null) {
        checklistItems = (responseData['checklist'] as List).map((item) {
          return ChecklistItem(title: item.toString());
        }).toList();
      }

      setState(() {
        _messages.add(ChatMessage(content: responseText, isUser: false, type: type, checklist: checklistItems));
        _isLoading = false;
      });
      _scrollToBottom();
      if (_isVoiceMode) _speakText(responseText);
    } catch (e) {
      setState(() { _messages.add(ChatMessage(content: "Unable to connect.", isUser: false)); _isLoading = false; });
      _scrollToBottom();
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Chat & Voice will use this language', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 20),
            ..._languages.entries.map((e) => ListTile(
              leading: Text(e.value.split(' ')[0], style: const TextStyle(fontSize: 28)),
              title: Text(e.value.split(' ')[1], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              trailing: _selectedLanguage == e.key ? const Icon(Icons.check_circle, color: Colors.green, size: 24) : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = e.key;
                  _addWelcomeMessage();
                });
                Navigator.pop(context);
                _showSnackBar('Language: ${e.value}');
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Assistant', style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
        actions: [
          if (_isSpeaking) Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.volume_up, color: Colors.white, size: 16), SizedBox(width: 4), Text('Speaking', style: TextStyle(color: Colors.white, fontSize: 12))])),
          GestureDetector(
            onTap: _showLanguageSelector,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
              child: Text(_languages[_selectedLanguage]!, style: const TextStyle(fontSize: 14)),
            ),
          ),
          GestureDetector(
            onTap: () { setState(() => _isVoiceMode = !_isVoiceMode); _showSnackBar(_isVoiceMode ? '🎤 Voice ON' : '🔇 Voice OFF'); },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _isVoiceMode ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(20)),
              child: Icon(_isVoiceMode ? Icons.mic : Icons.mic_none, color: _isVoiceMode ? Colors.white : Colors.grey[600], size: 20),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(controller: _scrollController, padding: const EdgeInsets.all(16), itemCount: _messages.length, itemBuilder: (context, index) => _buildMessage(_messages[index]))),
        if (_isLoading) _buildTyping(),
        _buildInput(),
      ]),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: Column(crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: msg.isUser ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(msg.content, style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87, fontSize: 16, height: 1.5)),
              if (msg.checklist != null) ...[const SizedBox(height: 16), ...msg.checklist!.map((item) => _buildCheckItem(item))],
            ]),
          ),
          if (msg.quickActions != null) Padding(padding: const EdgeInsets.only(top: 10), child: Wrap(spacing: 8, runSpacing: 8, children: msg.quickActions!.map((a) => GestureDetector(onTap: () => _sendMessage(a.replaceAll(RegExp(r'[^\w\s\u4e00-\u9fff\u0B80-\u0BFF]'), '').trim()), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[300]!)), child: Text(a, style: const TextStyle(fontSize: 13))))).toList())),
        ]),
      ),
    );
  }

  Widget _buildCheckItem(ChecklistItem item) {
    return GestureDetector(
      onTap: () => setState(() => item.isChecked = true),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: item.isChecked ? Colors.green.withOpacity(0.1) : Colors.grey[50], borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(width: 22, height: 22, decoration: BoxDecoration(color: item.isChecked ? Colors.green : Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: item.isChecked ? Colors.green : Colors.grey[300]!, width: 2)), child: item.isChecked ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
          const SizedBox(width: 12),
          Expanded(child: Text(item.title, style: TextStyle(color: item.isChecked ? Colors.grey : Colors.black87, fontSize: 14, decoration: item.isChecked ? TextDecoration.lineThrough : null))),
        ]),
      ),
    );
  }

  Widget _buildTyping() {
    return Container(margin: const EdgeInsets.only(left: 16, bottom: 12), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (_) => Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)))));
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: SafeArea(top: false, child: Row(children: [
        Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 18), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)), child: TextField(controller: _controller, decoration: InputDecoration(hintText: _selectedLanguage == 'malay' ? 'Taip mesej...' : _selectedLanguage == 'chinese' ? '输入信息...' : _selectedLanguage == 'tamil' ? 'செய்தி...' : 'Message...', hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none), onSubmitted: (_) => _sendMessage()))),
        const SizedBox(width: 10),
        GestureDetector(onTap: () => _sendMessage(), child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.arrow_upward, color: Colors.white))),
      ])),
    );
  }
}
