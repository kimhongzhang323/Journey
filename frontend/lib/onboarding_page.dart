import 'dart:async';
import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;
  
  const OnboardingPage({super.key, required this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentStep = 0;
  bool _isProcessing = false;
  
  // IC Data (editable)
  Map<String, String> _icData = {};
  bool _icValidated = false;
  
  // Passport Data
  Map<String, String> _passportData = {};
  bool _passportSkipped = false;
  bool _passportScanned = false;
  bool _hasMismatch = false;
  List<String> _mismatchFields = [];
  
  // Biometric
  bool _fingerprintDone = false;
  bool _faceIdDone = false;

  // Text Controllers for editing
  final _nameController = TextEditingController();
  final _icNumberController = TextEditingController();
  final _addressController = TextEditingController();

  void _simulateIcScan() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Mock IC data retrieved from scan
    setState(() {
      _icData = {
        'name': 'TAN AH KOW',
        'ic_number': '900101-14-1234',
        'address': '123, Jalan Example, 50000 Kuala Lumpur',
        'dob': '01-01-1990',
        'gender': 'Male',
      };
      _nameController.text = _icData['name']!;
      _icNumberController.text = _icData['ic_number']!;
      _addressController.text = _icData['address']!;
      _isProcessing = false;
      _currentStep = 1; // Go to validation step
    });
  }

  void _validateIcData() {
    // Update IC data with edited values
    _icData['name'] = _nameController.text.trim();
    _icData['ic_number'] = _icNumberController.text.trim();
    _icData['address'] = _addressController.text.trim();
    
    setState(() {
      _icValidated = true;
      _currentStep = 2; // Go to passport step
    });
  }

  void _simulatePassportScan() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Mock passport data (intentionally slightly different for demo)
    _passportData = {
      'name': 'TAN AH KOW',  // Same
      'passport_number': 'A12345678',
      'nationality': 'MALAYSIA',
      'dob': '01-01-1990',  // Same
    };
    
    // Check for mismatches with IC data
    _mismatchFields = [];
    if (_passportData['name'] != _icData['name']) {
      _mismatchFields.add('Name');
    }
    if (_passportData['dob'] != _icData['dob']) {
      _mismatchFields.add('Date of Birth');
    }
    
    setState(() {
      _isProcessing = false;
      _passportScanned = true;
      _hasMismatch = _mismatchFields.isNotEmpty;
      if (!_hasMismatch) {
        _currentStep = 3; // Proceed to biometric
      }
      // If mismatch, stay on passport step to show warning
    });
  }

  void _skipPassport() {
    setState(() {
      _passportSkipped = true;
      _currentStep = 3; // Go to biometric
    });
  }

  void _proceedDespiteMismatch() {
    // User acknowledges mismatch, proceed without updating IC data
    setState(() {
      _currentStep = 3;
    });
  }

  void _goBackToEditIc() {
    // Go back to IC validation to fix the mismatch
    setState(() {
      _hasMismatch = false;
      _passportScanned = false;
      _currentStep = 1; // Back to IC validation
    });
  }

  void _simulateBiometric(String type) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _isProcessing = false;
      if (type == 'fingerprint') {
        _fingerprintDone = true;
      } else if (type == 'face') {
        _faceIdDone = true;
      }
      if (_fingerprintDone && _faceIdDone) {
        _currentStep = 4; // Complete
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildProgressBar(),
              const SizedBox(height: 40),
              Expanded(child: _buildCurrentStep()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(5, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent ? Colors.black : Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildIcScanStep();
      case 1: return _buildIcValidationStep();
      case 2: return _buildPassportStep();
      case 3: return _buildBiometricStep();
      case 4: return _buildCompleteStep();
      default: return _buildIcScanStep();
    }
  }

  Widget _buildIcScanStep() {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(90),
            border: Border.all(color: Colors.grey[200]!, width: 2),
          ),
          child: _isProcessing
              ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : Icon(Icons.credit_card, size: 70, color: Colors.grey[400]),
        ),
        const SizedBox(height: 40),
        const Text('Scan Your IC', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Place your MyKad on a flat surface', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        const Spacer(),
        _buildPrimaryButton(_isProcessing ? 'Scanning...' : 'Start Scanning', _isProcessing ? null : _simulateIcScan),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildIcValidationStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Verify Your Details', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Please verify and edit if needed', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          const SizedBox(height: 32),
          
          _buildEditableField('Full Name', _nameController, Icons.person),
          _buildEditableField('IC Number', _icNumberController, Icons.badge),
          _buildEditableField('Address', _addressController, Icons.home, maxLines: 2),
          
          // Non-editable fields
          _buildReadOnlyField('Date of Birth', _icData['dob'] ?? '', Icons.calendar_today),
          _buildReadOnlyField('Gender', _icData['gender'] ?? '', Icons.wc),
          
          const SizedBox(height: 32),
          _buildPrimaryButton('Confirm Details', _validateIcData),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                icon: Icon(icon, color: Colors.grey[400], size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[400], size: 20),
                const SizedBox(width: 12),
                Text(value, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const Spacer(),
                Icon(Icons.lock, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassportStep() {
    // If mismatch detected, show warning
    if (_hasMismatch && _passportScanned) {
      return Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text('Data Mismatch Detected', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  'The following fields differ between your IC and Passport:',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ...(_mismatchFields.map((field) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Text(field, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ))),
                const SizedBox(height: 16),
                Text(
                  'Passport data will not update your IC details. Please update your IC first if needed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildPrimaryButton('Continue Anyway', _proceedDespiteMismatch),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _goBackToEditIc,
            child: const Text('Go Back to Edit IC', style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Column(
      children: [
        const Spacer(),
        Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(90),
            border: Border.all(color: Colors.grey[200]!, width: 2),
          ),
          child: _isProcessing
              ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : Icon(Icons.menu_book, size: 70, color: Colors.grey[400]),
        ),
        const SizedBox(height: 40),
        const Text('Scan Passport', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Optional: Add passport for international travel', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('IC data is locked after validation', style: TextStyle(fontSize: 12, color: Colors.blue[700])),
        ),
        const Spacer(),
        _buildPrimaryButton(_isProcessing ? 'Scanning...' : 'Scan Passport', _isProcessing ? null : _simulatePassportScan),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _skipPassport,
          child: Text('Skip for now', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBiometricStep() {
    return Column(
      children: [
        const Spacer(),
        const Text('Biometric Verification', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Complete both to secure your Digital ID', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        const SizedBox(height: 40),
        _buildBiometricCard(Icons.fingerprint, 'Fingerprint', _fingerprintDone, () => _simulateBiometric('fingerprint')),
        const SizedBox(height: 16),
        _buildBiometricCard(Icons.face, 'Face ID', _faceIdDone, () => _simulateBiometric('face')),
        const Spacer(),
        if (_fingerprintDone && _faceIdDone)
          _buildPrimaryButton('Continue', () => setState(() => _currentStep = 4)),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildBiometricCard(IconData icon, String title, bool isDone, VoidCallback onTap) {
    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDone ? Colors.black : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDone ? Colors.black : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isDone ? Colors.white.withOpacity(0.2) : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(isDone ? Icons.check : icon, color: isDone ? Colors.white : Colors.black, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: isDone ? Colors.white : Colors.black)),
            ),
            if (!isDone) Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteStep() {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(50)),
          child: const Icon(Icons.check, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 40),
        const Text('All Set!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Your Digital ID is ready', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        const Spacer(),
        _buildPrimaryButton('Get Started', widget.onComplete),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
