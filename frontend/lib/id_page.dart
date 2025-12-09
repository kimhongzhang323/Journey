import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class IdPage extends StatefulWidget {
  const IdPage({super.key});

  @override
  State<IdPage> createState() => _IdPageState();
}

class _IdPageState extends State<IdPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _idData;
  bool _isLoading = true;
  bool _isTravelMode = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // QR auto-refresh
  Timer? _qrRefreshTimer;
  int _qrTimestamp = DateTime.now().millisecondsSinceEpoch;
  int _qrCountdown = 30;

  final Map<String, dynamic> _passportData = {
    'passport_number': 'A12345678',
    'nationality': 'MALAYSIA',
    'issue_date': '2022-01-15',
    'expiry_date': '2032-01-14',
  };

  final List<Map<String, dynamic>> _visas = [
    {'country': 'Singapore', 'code': 'sg', 'type': 'Visa Free', 'expiry': '2030-12-31'},
    {'country': 'Japan', 'code': 'jp', 'type': 'Tourist Visa', 'expiry': '2025-03-15'},
    {'country': 'United States', 'code': 'us', 'type': 'B1/B2 Visa', 'expiry': '2025-01-20'},
    {'country': 'United Kingdom', 'code': 'gb', 'type': 'Tourist Visa', 'expiry': '2026-06-30'},
    {'country': 'Australia', 'code': 'au', 'type': 'ETA', 'expiry': '2025-08-10'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _loadIdData();
    _startQrRefreshTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _qrRefreshTimer?.cancel();
    super.dispose();
  }

  void _startQrRefreshTimer() {
    _qrRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _qrCountdown--;
        if (_qrCountdown <= 0) {
          _qrTimestamp = DateTime.now().millisecondsSinceEpoch;
          _qrCountdown = 30;
        }
      });
    });
  }

  String _getQrData(String type) {
    if (type == 'ic') {
      return 'did:my:${_idData?['id_number'] ?? ''}:$_qrTimestamp:verify';
    } else {
      return 'passport:my:${_passportData['passport_number']}:$_qrTimestamp:verify';
    }
  }

  Future<void> _loadIdData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('digital_id_data');
    if (cachedData != null) {
      setState(() { _idData = jsonDecode(cachedData); _isLoading = false; });
      _animationController.forward();
    }
    try {
      final freshData = await _apiService.getDigitalId();
      await prefs.setString('digital_id_data', jsonEncode(freshData));
      setState(() { _idData = freshData; _isLoading = false; });
      if (!_animationController.isCompleted) _animationController.forward();
    } catch (e) {
      if (_idData == null) setState(() => _isLoading = false);
    }
  }

  Color _getExpiryColor(String expiryDateStr) {
    try {
      final expiry = DateTime.parse(expiryDateStr);
      final diff = expiry.difference(DateTime.now()).inDays;
      if (diff < 0) return Colors.red[700]!;
      if (diff < 30) return Colors.red;
      if (diff < 90) return Colors.orange;
      if (diff < 180) return Colors.amber[700]!;
      if (diff < 365) return Colors.green[600]!;
      return Colors.green;
    } catch (e) { return Colors.grey; }
  }

  String _getExpiryLabel(String expiryDateStr) {
    try {
      final expiry = DateTime.parse(expiryDateStr);
      final diff = expiry.difference(DateTime.now()).inDays;
      if (diff < 0) return 'EXPIRED';
      if (diff < 30) return 'Expires soon';
      if (diff < 90) return '${(diff / 30).floor()}mo left';
      return 'Valid';
    } catch (e) { return ''; }
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  String _getDeviceInfo() {
    if (kIsWeb) return 'Web';
    try { return Platform.operatingSystem.toUpperCase(); } catch (e) { return 'Device'; }
  }

  void _showFullscreen(String type) {
    final isIc = type == 'ic';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FullscreenView(
        isIc: isIc,
        idData: _idData,
        passportData: _passportData,
        getQrData: _getQrData,
        getCurrentDateTime: _getCurrentDateTime,
        getDeviceInfo: _getDeviceInfo,
        qrCountdown: _qrCountdown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
          : _idData == null ? _buildEmptyState() : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text('No ID Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          TextButton(onPressed: _loadIdData, style: TextButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)), child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(_isTravelMode ? 'Travel Mode' : 'Digital ID', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    _buildModeToggle(),
                  ]),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _isTravelMode ? _buildTravelMode() : _buildIdMode()),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _buildWatermark()),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(24)),
      child: Row(children: [_buildToggleButton('ID', Icons.badge, !_isTravelMode), _buildToggleButton('Travel', Icons.flight, _isTravelMode)]),
    );
  }

  Widget _buildToggleButton(String label, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isTravelMode = label == 'Travel'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: isActive ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(20), boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : null),
        child: Row(children: [Icon(icon, size: 16, color: isActive ? Colors.black : Colors.grey[500]), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 13, color: isActive ? Colors.black : Colors.grey[500], fontWeight: isActive ? FontWeight.w600 : FontWeight.normal))]),
      ),
    );
  }

  Widget _buildIdMode() {
    return Column(key: const ValueKey('id_mode'), children: [
      GestureDetector(onTap: () => _showFullscreen('ic'), child: _buildIcCard()),
      const SizedBox(height: 12),
      Text('Tap card to view fullscreen', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      const SizedBox(height: 24),
      _buildQrSection('ic'),
      const SizedBox(height: 32),
      _buildDetailsSection(),
    ]);
  }

  Widget _buildTravelMode() {
    return Column(key: const ValueKey('travel_mode'), crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(onTap: () => _showFullscreen('passport'), child: _buildPassportCard()),
      const SizedBox(height: 12),
      Text('Tap card to view fullscreen', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      const SizedBox(height: 24),
      _buildQrSection('passport'),
      const SizedBox(height: 32),
      const Text('Available Visas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      ..._visas.map((visa) => _buildVisaCard(visa)),
    ]);
  }

  Widget _buildIcCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Image.asset('assets/images/IC.jpg', width: double.infinity, height: 220, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 220, color: Colors.grey[300], child: const Center(child: Icon(Icons.credit_card, size: 48)))),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)])))),
          Positioned(top: 16, left: 16, child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.asset('assets/images/countryFlag/my.png', width: 32, height: 22, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 32, height: 22, color: Colors.grey))), const SizedBox(width: 8), Text('MALAYSIA', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1))])),
          Positioned(top: 16, right: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.9), borderRadius: BorderRadius.circular(20)), child: const Text('VERIFIED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)))),
          Positioned(bottom: 20, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_idData!['name'] ?? 'Name', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(_idData!['id_number'] ?? 'ID', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, letterSpacing: 1.5))])),
        ]),
      ),
    );
  }

  Widget _buildPassportCard() {
    final expiryColor = _getExpiryColor(_passportData['expiry_date']);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Image.asset('assets/images/passport.png', width: double.infinity, height: 240, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 240, color: Colors.indigo[100], child: const Center(child: Icon(Icons.menu_book, size: 48)))),
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.8)])))),
          Positioned(top: 16, left: 16, child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.asset('assets/images/countryFlag/my.png', width: 32, height: 22, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 32, height: 22, color: Colors.grey))), const SizedBox(width: 8), const Text('PASSPORT', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1))])),
          Positioned(top: 16, right: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: expiryColor.withOpacity(0.9), borderRadius: BorderRadius.circular(20)), child: Text(_getExpiryLabel(_passportData['expiry_date']), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)))),
          Positioned(bottom: 20, left: 20, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_idData!['name'] ?? 'Name', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Row(children: [_buildPassportDetail('Passport No.', _passportData['passport_number']), const SizedBox(width: 32), _buildPassportDetail('Expiry', _passportData['expiry_date'], color: expiryColor)])])),
        ]),
      ),
    );
  }

  Widget _buildPassportDetail(String label, String value, {Color? color}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)), const SizedBox(height: 4), Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w600))]);
  }

  Widget _buildVisaCard(Map<String, dynamic> visa) {
    final expiryColor = _getExpiryColor(visa['expiry']);
    final expiryLabel = _getExpiryLabel(visa['expiry']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/countryFlag/${visa['code']}.png', width: 40, height: 28, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 40, height: 28, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.flag, size: 16, color: Colors.grey)))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(visa['country'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(visa['type'], style: TextStyle(fontSize: 13, color: Colors.grey[500]))])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: expiryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(expiryLabel, style: TextStyle(color: expiryColor, fontSize: 11, fontWeight: FontWeight.w600))), const SizedBox(height: 4), Text(visa['expiry'], style: TextStyle(fontSize: 12, color: Colors.grey[400]))]),
      ]),
    );
  }

  Widget _buildQrSection(String type) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(children: [
        Text(type == 'ic' ? 'MyKad Verification' : 'Passport Verification', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        const SizedBox(height: 16),
        QrImageView(data: _getQrData(type), version: QrVersions.auto, size: 180),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.refresh, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text('Auto-refresh in ${_qrCountdown}s', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDetailsSection() {
    final expiryColor = _getExpiryColor(_idData!['valid_until'] ?? '2030-12-31');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(children: [_buildDetailRow('Country', _idData!['country'] ?? 'N/A'), _buildDetailRow('Valid Until', _idData!['valid_until'] ?? 'N/A', valueColor: expiryColor), _buildDetailRow('Status', 'Active', valueColor: Colors.green)]),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 15)), Text(value, style: TextStyle(color: valueColor ?? Colors.black87, fontSize: 15, fontWeight: FontWeight.w500))]),
    );
  }

  Widget _buildWatermark() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFFF5F5F7).withOpacity(0), const Color(0xFFF5F5F7)])),
      child: SafeArea(top: false, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)), child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [Icon(Icons.verified_user, size: 14, color: Colors.grey[500]), const SizedBox(width: 8), Text('${_getCurrentDateTime()} • ${_getDeviceInfo()}', style: TextStyle(color: Colors.grey[500], fontSize: 11))]))),
    );
  }
}

// Fullscreen View Widget with Full Page Watermark
class _FullscreenView extends StatefulWidget {
  final bool isIc;
  final Map<String, dynamic>? idData;
  final Map<String, dynamic> passportData;
  final String Function(String) getQrData;
  final String Function() getCurrentDateTime;
  final String Function() getDeviceInfo;
  final int qrCountdown;

  const _FullscreenView({
    required this.isIc,
    required this.idData,
    required this.passportData,
    required this.getQrData,
    required this.getCurrentDateTime,
    required this.getDeviceInfo,
    required this.qrCountdown,
  });

  @override
  State<_FullscreenView> createState() => _FullscreenViewState();
}

class _FullscreenViewState extends State<_FullscreenView> {
  late Timer _refreshTimer;
  late String _currentTime;
  late int _qrTimestamp;
  int _countdown = 30;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.getCurrentDateTime();
    _qrTimestamp = DateTime.now().millisecondsSinceEpoch;
    _countdown = widget.qrCountdown;
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = widget.getCurrentDateTime();
        _countdown--;
        if (_countdown <= 0) {
          _qrTimestamp = DateTime.now().millisecondsSinceEpoch;
          _countdown = 30;
        }
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  String _getFullscreenQrData() {
    if (widget.isIc) {
      return 'did:my:${widget.idData?['id_number'] ?? ''}:$_qrTimestamp:verify';
    } else {
      return 'passport:my:${widget.passportData['passport_number']}:$_qrTimestamp:verify';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Main Content
          Column(
            children: [
              Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text(widget.isIc ? 'MyKad' : 'Passport', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    widget.isIc ? 'assets/images/IC.jpg' : 'assets/images/passport.png',
                    width: double.infinity, height: 180, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 180, color: Colors.grey[200], child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey))),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 48),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Verification QR', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text('${_countdown}s', style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  QrImageView(data: _getFullscreenQrData(), version: QrVersions.auto, size: 160),
                ]),
              ),
            ],
          ),
          // Full Page Watermark Pattern
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _WatermarkPainter(text: 'JOURNEY', dateTime: _currentTime),
              ),
            ),
          ),
          // Bottom Bar
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withOpacity(0), Colors.white])),
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.verified_user, size: 16, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(_currentTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                    const SizedBox(width: 8),
                    Text('• ${widget.getDeviceInfo()}', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Full Page Watermark
class _WatermarkPainter extends CustomPainter {
  final String text;
  final String dateTime;

  _WatermarkPainter({required this.text, required this.dateTime});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final paint = Paint()..color = Colors.grey.withOpacity(0.06);
    
    canvas.save();
    canvas.rotate(-0.3);
    
    for (double y = -200; y < size.height + 400; y += 120) {
      for (double x = -200; x < size.width + 200; x += 280) {
        textPainter.text = TextSpan(
          text: text,
          style: TextStyle(color: Colors.grey.withOpacity(0.08), fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 6),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
        
        textPainter.text = TextSpan(
          text: dateTime,
          style: TextStyle(color: Colors.grey.withOpacity(0.05), fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y + 32));
      }
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WatermarkPainter oldDelegate) => oldDelegate.dateTime != dateTime;
}
