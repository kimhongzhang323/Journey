import 'dart:async';
import 'dart:convert';
import 'dart:ui_web' as ui_web;
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
  final String? url;
  final String? label;
  final String? service;
  final List<Map<String, dynamic>>? locations;
  final double? mapLat;
  final double? mapLng;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    this.type = 'text',
    this.checklist,
    this.quickActions,
    this.url,
    this.label,
    this.service,
    this.locations,
    this.mapLat,
    this.mapLng,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChecklistItem {
  String title;
  bool isChecked;
  ChecklistItem({required this.title, this.isChecked = false});
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isVoiceMode = false;
  bool _isSpeaking = false;
  int _mapCounter = 0;
  String? _googleMapsApiKey;
  
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
    _fetchApiKey();
  }

  Future<void> _fetchApiKey() async {
    try {
      final response = await http.get(Uri.parse('$_backendUrl/config'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _googleMapsApiKey = data['google_maps_api_key']);
      }
    } catch (e) {
      // Use fallback - maps won't work without key
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessages = {
      'english': "Hi! I'm Journey, your Government Services Assistant. Ask me about IC, passport, tax, or find nearby offices!",
      'malay': "Hai! Saya Journey, pembantu perkhidmatan kerajaan. Tanya pasal IC, pasport, cukai, atau cari pejabat berdekatan!",
      'chinese': "你好！我是Journey，政府服务助手。问我关于IC、护照、税务，或找附近的办事处！",
      'tamil': "வணக்கம்! நான் Journey, அரசு சேவை உதவியாளர். IC, பாஸ்போர்ட், வரி பற்றி கேளுங்கள்!",
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
      'english': ["🪪 I lost my IC", "📍 Find nearest JPN", "🌐 JPN Website", "📘 Lost passport"],
      'malay': ["🪪 IC saya hilang", "📍 Cari JPN", "🌐 Laman web JPN", "📘 Pasport hilang"],
      'chinese': ["🪪 IC不见了", "📍 找附近JPN", "🌐 JPN网站", "📘 护照丢了"],
      'tamil': ["🪪 IC காணாமல்", "📍 JPN கண்டுபிடி", "🌐 JPN இணையம்", "📘 பாஸ்போர்ட்"],
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

  void _openUrl(String url) {
    html.window.open(url, '_blank');
  }

  String _registerMapView(double lat, double lng, String query) {
    final viewId = 'google-map-${_mapCounter++}';
    final iframe = html.IFrameElement()
      ..src = 'https://www.google.com/maps/embed/v1/search?key=$_googleMapsApiKey&q=$query&center=$lat,$lng&zoom=13'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true;
    
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) => iframe);
    return viewId;
  }

  Future<void> _findNearbyOffice(String service) async {
    setState(() => _isLoading = true);
    
    try {
      final position = await html.window.navigator.geolocation.getCurrentPosition();
      final lat = position.coords!.latitude!;
      final lng = position.coords!.longitude!;
      
      final response = await http.post(
        Uri.parse('$_backendUrl/find-office'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'service': service, 'latitude': lat, 'longitude': lng}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data['results'] as List).map((e) => e as Map<String, dynamic>).toList();
        
        setState(() {
          _messages.add(ChatMessage(
            content: "Found ${results.length} nearby ${service.toUpperCase()} offices:",
            isUser: false,
            type: 'locations',
            locations: results,
            mapLat: lat.toDouble(),
            mapLng: lng.toDouble(),
            url: data['website'],
            label: 'Visit Official Website',
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'API error');
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(content: "Error: $e", isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _sendMessage([String? overrideMessage]) async {
    final text = overrideMessage ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() { _messages.add(ChatMessage(content: text, isUser: true)); _isLoading = true; });
    _controller.clear();
    _scrollToBottom();

    try {
      final responseData = await _apiService.chat(text, language: _selectedLanguage);
      final responseText = responseData['response'] ?? 'No response';
      final type = responseData['type'] ?? 'text';

      if (type == 'location' && responseData['service'] != null) {
        setState(() {
          _messages.add(ChatMessage(content: responseText, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
        await _findNearbyOffice(responseData['service']);
        return;
      }

      List<ChecklistItem>? checklistItems;
      if (type == 'checklist' && responseData['checklist'] != null) {
        checklistItems = (responseData['checklist'] as List).map((item) => ChecklistItem(title: item.toString())).toList();
      }

      setState(() {
        _messages.add(ChatMessage(
          content: responseText,
          isUser: false,
          type: type,
          checklist: checklistItems,
          url: responseData['url'],
          label: responseData['label'],
        ));
        _isLoading = false;
      });
      _scrollToBottom();
      if (_isVoiceMode) _speakText(responseText);
    } catch (e) {
      setState(() { _messages.add(ChatMessage(content: "Unable to connect: $e", isUser: false)); _isLoading = false; });
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
            const SizedBox(height: 20),
            ..._languages.entries.map((e) => ListTile(
              leading: Text(e.value.split(' ')[0], style: const TextStyle(fontSize: 28)),
              title: Text(e.value.split(' ')[1]),
              trailing: _selectedLanguage == e.key ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () { setState(() { _selectedLanguage = e.key; _addWelcomeMessage(); }); Navigator.pop(context); },
            )),
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
        title: const Text('Journey', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          if (_isSpeaking) Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.volume_up, color: Colors.white, size: 16), SizedBox(width: 4), Text('Speaking', style: TextStyle(color: Colors.white, fontSize: 12))])),
          GestureDetector(onTap: _showLanguageSelector, child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)), child: Text(_languages[_selectedLanguage]!, style: const TextStyle(fontSize: 14)))),
          GestureDetector(onTap: () { setState(() => _isVoiceMode = !_isVoiceMode); _showSnackBar(_isVoiceMode ? '🎤 Voice ON' : '🔇 Voice OFF'); }, child: Container(margin: const EdgeInsets.only(right: 16), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _isVoiceMode ? Colors.black : Colors.grey[100], borderRadius: BorderRadius.circular(20)), child: Icon(_isVoiceMode ? Icons.mic : Icons.mic_none, color: _isVoiceMode ? Colors.white : Colors.grey[600], size: 20))),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        child: Column(crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: msg.isUser ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(msg.content, style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87, fontSize: 16, height: 1.5)),
              if (msg.checklist != null) ...[const SizedBox(height: 12), ...msg.checklist!.map((item) => _buildCheckItem(item))],
              // Embedded Map
              if (msg.locations != null && msg.mapLat != null && msg.mapLng != null) ...[
                const SizedBox(height: 12),
                _buildEmbeddedMap(msg.mapLat!, msg.mapLng!, msg.service ?? 'JPN'),
              ],
              if (msg.locations != null) ...[const SizedBox(height: 12), ...msg.locations!.take(3).map((loc) => _buildLocationCard(loc))],
              if (msg.url != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _openUrl(msg.url!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(msg.label ?? 'Open Link', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],
            ]),
          ),
          if (msg.quickActions != null) Padding(padding: const EdgeInsets.only(top: 10), child: Wrap(spacing: 8, runSpacing: 8, children: msg.quickActions!.map((a) => GestureDetector(onTap: () => _sendMessage(a.replaceAll(RegExp(r'[^\w\s\u4e00-\u9fff\u0B80-\u0BFF]'), '').trim()), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[300]!)), child: Text(a, style: const TextStyle(fontSize: 13))))).toList())),
        ]),
      ),
    );
  }

  Widget _buildEmbeddedMap(double lat, double lng, String query) {
    final viewId = _registerMapView(lat, lng, query);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: HtmlElementView(viewType: viewId),
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> loc) {
    return GestureDetector(
      onTap: () => _openUrl(loc['maps_url'] ?? ''),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.location_on, color: Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(loc['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 2),
            Text(loc['address'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            if (loc['rating'] != null) Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 4), Text('${loc['rating']}', style: TextStyle(color: Colors.grey[600], fontSize: 12))]),
          ])),
          const Icon(Icons.chevron_right, color: Colors.grey),
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
          Expanded(child: Text(item.title, style: TextStyle(color: item.isChecked ? Colors.grey : Colors.black87, decoration: item.isChecked ? TextDecoration.lineThrough : null))),
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
        Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 18), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)), child: TextField(controller: _controller, decoration: InputDecoration(hintText: _selectedLanguage == 'malay' ? 'Taip mesej...' : _selectedLanguage == 'chinese' ? '输入信息...' : 'Message...', hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none), onSubmitted: (_) => _sendMessage()))),
        const SizedBox(width: 10),
        GestureDetector(onTap: () => _sendMessage(), child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.arrow_upward, color: Colors.white))),
      ])),
    );
  }
}
