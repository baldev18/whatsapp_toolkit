import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/app_notifiers.dart';

// ============================================================
// PREMIUM SCREEN - Lifetime/Monthly plan khareedva mate
// ============================================================
// IMPORTANT: Aa product IDs ('premium_lifetime', 'premium_monthly')
// Google Play Console ma EXACT aaj naam thi banavvi padse
// (Play Console > Monetize > Products > In-app products/Subscriptions)
// Signed app + real Play Console listing vagar aa test nahi thai shake.
// ============================================================
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // In-app purchase plugin instance
  final InAppPurchase _iap = InAppPurchase.instance;

  // Play Console ma banaveli product IDs (exact match hovu joiye)
  static const String _lifetimeId = 'premium_lifetime';
  static const String _monthlyId = 'premium_monthly';

  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _storeAvailable = true;
  // Jyare "Restore Purchases" chalu hoy tyare button par
  // spinner batavva mate
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _initializeStore();

    // Purchase complete/fail thay tyare "sambhadva" mate listener
    _iap.purchaseStream.listen(_handlePurchaseUpdates);
  }

  Future<void> _initializeStore() async {
    // Check karo ke phone ma Play Store available chhe ke nahi
    final bool available = await _iap.isAvailable();
    if (!available) {
      setState(() {
        _storeAvailable = false;
        _isLoading = false;
      });
      return;
    }

    // Play Console mathi product details (naam, price) mangaviye
    final response =
    await _iap.queryProductDetails({_lifetimeId, _monthlyId});

    setState(() {
      _products = response.productDetails;
      _isLoading = false;
    });
  }

  // Jyare purchase thay (successful/failed/pending) tyare aa chale chhe
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Purchase successful - premium ON karo ane save karo
        isPremiumNotifier.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);

        // Play Store ne "confirm" karvu jaruri chhe
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Premium activate thai gayu! 🎉')),
          );
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purchase fail thayu: ${purchase.error}')),
          );
        }
      }
    }
  }

  // Pehla thi khareedelu premium pachu "restore" (activate) karva mate
  // Google Play policy mate aa button hovu ferjiyat chhe
  Future<void> _restorePurchases() async {
    setState(() => _isRestoring = true);

    // Aa call Google Play ne puchhe chhe: "aa user e pehla su
    // khareedyu hatu?" - jo koi purchase male to purchaseStream
    // ma automatically _handlePurchaseUpdates() chalse
    await _iap.restorePurchases();

    // Thodi second rahi ne spinner band karo (restore async chhe,
    // result purchaseStream mathi j aavse)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isRestoring = false);

      // Jo restore pachi pan premium na thayu hoy, to user ne
      // khabar aapvi ke koi juni purchase nathi malyu
      if (!isPremiumNotifier.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koi juni purchase nathi malyu'),
          ),
        );
      }
    }
  }

  // Khareedvani process shuru karva mate
  void _buyProduct(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    if (product.id == _monthlyId) {
      // Monthly = subscription
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      // Lifetime = one-time purchase (non-consumable, kem ke ek j vaar
      // khareedvanu, vaparta j rahevanu chhe)
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_storeAvailable
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Play Store available nathi. Real device par test karo.',
            textAlign: TextAlign.center,
          ),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Features list - premium sathe su malshe
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Premium ma malshe:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text('No Ads - koi ads nahi dekhay'),
                ]),
                SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text('Unlimited Repeat - 500 ni jagya e 5000 sudhi'),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Jo products load na thaya hoy (Play Console setup
          // baki hoy) to message batavo
          if (_products.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Products load nathi thaya. Play Console ma '
                    '"premium_lifetime" ane "premium_monthly" product '
                    'IDs banavva jaruri chhe (signed app sathe).',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),

          // Dareke product nu card
          ..._products.map((product) {
            final isLifetime = product.id == _lifetimeId;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(
                  isLifetime ? Icons.all_inclusive : Icons.repeat,
                  color: Colors.green,
                  size: 32,
                ),
                title: Text(
                  isLifetime ? 'Lifetime' : 'Monthly',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(product.description),
                trailing: ElevatedButton(
                  onPressed: () => _buyProduct(product),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(product.price),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Restore Purchases button - Google Play policy mate jaruri
          // chhe: jo user e phone badlyu hoy, app re-install karyu
          // hoy, ke data clear thai gayo hoy, to aa button thi
          // pehla thi khareedelu premium pachu activate thai jay
          Center(
            child: TextButton.icon(
              onPressed: _isRestoring ? null : _restorePurchases,
              icon: _isRestoring
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.restore, size: 18),
              label: Text(
                _isRestoring ? 'Restore thai rahyu chhe...' : 'Restore Purchases',
              ),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
