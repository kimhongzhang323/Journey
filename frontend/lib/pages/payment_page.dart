import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> paymentDetails;
  final Function(bool) onPaymentComplete;

  const PaymentPage({
    super.key,
    required this.paymentDetails,
    required this.onPaymentComplete,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;
  String _selectedMethod = 'card'; // card, fpx, ewallet
  
  // FPX State
  String? _selectedBank;
  final List<Map<String, String>> _banks = [
    {'id': 'maybank', 'name': 'Maybank2u', 'color': '#FFC800'},
    {'id': 'cimb', 'name': 'CIMB Clicks', 'color': '#ED1C24'},
    {'id': 'pbb', 'name': 'Public Bank', 'color': '#CD1316'},
    {'id': 'rhb', 'name': 'RHB Now', 'color': '#0067AC'},
    {'id': 'hongleong', 'name': 'Hong Leong', 'color': '#004892'},
    {'id': 'ambank', 'name': 'AmBank', 'color': '#ED1C24'},
    {'id': 'islam', 'name': 'Bank Islam', 'color': '#A6192E'},
    {'id': 'uob', 'name': 'UOB', 'color': '#003366'},
  ];

  // E-Wallet State
  String? _selectedWallet;
  final List<Map<String, String>> _wallets = [
    {'id': 'tng', 'name': 'TnG eWallet', 'color': '#015ABF'},
    {'id': 'grab', 'name': 'GrabPay', 'color': '#00B14F'},
    {'id': 'boost', 'name': 'Boost', 'color': '#EE3124'},
    {'id': 'shopee', 'name': 'ShopeePay', 'color': '#EE4D2D'},
    {'id': 'mae', 'name': 'MAE', 'color': '#FFC800'},
  ];

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final amount = widget.paymentDetails['amount'] ?? 'RM 0.00';
    final taskName = widget.paymentDetails['task'] ?? 'Service Payment';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Malaysia Payment Channel',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Amount Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    'Pay to $taskName',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Credit Card Section
                  _buildPaymentSection(
                    id: 'card',
                    title: 'Credit / Debit Card',
                    icon: Icons.credit_card,
                    child: _buildCardForm(),
                    logos: [
                      _buildLogo('VISA'),
                      _buildLogo('Master'),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Online Banking Section
                  _buildPaymentSection(
                    id: 'fpx',
                    title: 'Online Banking (FPX)',
                    icon: Icons.account_balance,
                    child: _buildGridSelection(
                      items: _banks, 
                      selectedId: _selectedBank, 
                      onSelect: (id) => setState(() => _selectedBank = id)
                    ),
                    logos: [
                      const Text('FPX', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // E-Wallet Section
                  _buildPaymentSection(
                    id: 'ewallet',
                    title: 'E-Wallet',
                    icon: Icons.account_balance_wallet,
                    child: _buildGridSelection(
                      items: _wallets, 
                      selectedId: _selectedWallet, 
                      onSelect: (id) => setState(() => _selectedWallet = id)
                    ),
                    logos: [
                      _buildLogo('TnG'),
                      _buildLogo('Grab'),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _getButtonLabel(amount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Secured by PayNet & Stripe',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(text, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildPaymentSection({
    required String id,
    required String title,
    required IconData icon,
    required Widget child,
    List<Widget>? logos,
  }) {
    final isSelected = _selectedMethod == id;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF635BFF) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: isSelected ? const Color(0xFF635BFF) : Colors.grey[600], size: 22),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.black87 : Colors.grey[700],
                    ),
                  ),
                  if (logos != null) ...[
                    const Spacer(),
                    ...logos,
                  ],
                ],
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: child,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[100]),
          const SizedBox(height: 16),
          
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Card number',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Icon(Icons.credit_card, size: 20, color: Colors.grey),
            ),
            keyboardType: TextInputType.number,
            validator: (val) => val != null && val.length < 12 ? 'Enter valid card number' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'MM / YY',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'CVC',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Cardholder Name',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSelection({
    required List<Map<String, String>> items,
    required String? selectedId,
    required Function(String) onSelect,
  }) {
    return Column(
      children: [
        Divider(color: Colors.grey[100]),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = selectedId == item['id'];
            
            return GestureDetector(
              onTap: () => onSelect(item['id']!),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE8EAF6) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                     color: isSelected ? const Color(0xFF3F51B5) : Colors.grey[300]!,
                     width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  item['name']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF3F51B5) : Colors.grey[800],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getButtonColor() {
    if (_selectedMethod == 'card') return const Color(0xFF635BFF);
    if (_selectedMethod == 'fpx') return Colors.orange[800]!;
    if (_selectedMethod == 'ewallet') return Colors.blue[700]!;
    return Colors.grey;
  }

  String _getButtonLabel(String amount) {
     if (_selectedMethod == 'fpx') {
        if (_selectedBank == null) return 'Select a Bank';
        final bankName = _banks.firstWhere((b) => b['id'] == _selectedBank)['name'];
        return 'Pay $amount via $bankName';
     }
     if (_selectedMethod == 'ewallet') {
        if (_selectedWallet == null) return 'Select a Wallet';
        final walletName = _wallets.firstWhere((w) => w['id'] == _selectedWallet)['name'];
        return 'Pay $amount via $walletName';
     }
     return 'Pay $amount';
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == 'fpx' && _selectedBank == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a bank')));
        return;
    }
    if (_selectedMethod == 'ewallet' && _selectedWallet == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an e-wallet')));
        return;
    }
    if (_selectedMethod == 'card' && !_formKey.currentState!.validate()) {
        return;
    }

    setState(() => _isProcessing = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isProcessing = false);
      widget.onPaymentComplete(true);
      Navigator.of(context).pop();
    }
  }
}
