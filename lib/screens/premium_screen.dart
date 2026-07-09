import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/app_notifiers.dart';
import '../state/app_strings.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  static const String _lifetimeId = 'premium_lifetime';
  static const String _monthlyId = 'premium_monthly';

  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _storeAvailable = true;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _initializeStore();
    _iap.purchaseStream.listen(_handlePurchaseUpdates);
  }

  Future<void> _initializeStore() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      setState(() {
        _storeAvailable = false;
        _isLoading = false;
      });
      return;
    }
    final response = await _iap.queryProductDetails({_lifetimeId, _monthlyId});
    setState(() {
      _products = response.productDetails;
      _isLoading = false;
    });
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    final lang = localeNotifier.value;
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        isPremiumNotifier.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isPremium', true);
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppStrings.get('pr_success', lang)),
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppStrings.get('pr_error_prefix', lang) + purchase.error.toString()),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    }
  }

  Future<void> _restorePurchases() async {
    final lang = localeNotifier.value;
    setState(() => _isRestoring = true);
    await _iap.restorePurchases();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isRestoring = false);
      if (!isPremiumNotifier.value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.get('pr_restore_empty', lang)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _buyProduct(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium High-end Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF1A1A1A),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          bottom: -30,
                          child: Icon(Icons.workspace_premium_rounded, size: 200, color: Colors.white.withOpacity(0.05)),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.premiumGold.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.premiumGold.withOpacity(0.3), width: 2),
                                ),
                                child: const Icon(Icons.star_rounded, color: AppColors.premiumGold, size: 40),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.get('pr_title', lang),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Benefits Card
                      _buildBenefitsCard(lang, isDark),

                      const SizedBox(height: 32),

                      // Plans Section
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (!_storeAvailable)
                        _buildErrorMessage(AppStrings.get('pr_store_missing', lang))
                      else if (_products.isEmpty)
                        _buildErrorMessage(AppStrings.get('pr_load_error', lang))
                      else
                        ..._products.map((product) => _buildProductCard(product, lang, isDark)),

                      const SizedBox(height: 24),

                      // Restore Actions
                      Center(
                        child: TextButton.icon(
                          onPressed: _isRestoring ? null : _restorePurchases,
                          icon: _isRestoring
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.settings_backup_restore_rounded, size: 18),
                          label: Text(
                            _isRestoring ? AppStrings.get('pr_restoring', lang) : AppStrings.get('pr_restore_button', lang),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitsCard(String lang, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.get('pr_features_title', lang),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 20),
          _buildBenefitRow(Icons.block_rounded, AppStrings.get('pr_feature_ads', lang)),
          const SizedBox(height: 16),
          _buildBenefitRow(Icons.all_inclusive_rounded, AppStrings.get('pr_feature_repeat', lang)),
          const SizedBox(height: 16),
          _buildBenefitRow(Icons.support_agent_rounded, 'Priority Customer Support'),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    );
  }

  Widget _buildProductCard(ProductDetails product, String lang, bool isDark) {
    final isLifetime = product.id == _lifetimeId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLifetime ? AppColors.premiumGold : (isDark ? Colors.transparent : Colors.grey.shade200),
          width: 2,
        ),
        color: isDark ? AppColors.darkSurface : Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isLifetime ? AppColors.premiumGold : AppColors.primary).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLifetime ? Icons.auto_awesome_rounded : Icons.calendar_month_rounded,
            color: isLifetime ? AppColors.premiumGold : AppColors.primary,
          ),
        ),
        title: Text(
          isLifetime ? AppStrings.get('pr_lifetime', lang) : AppStrings.get('pr_monthly', lang),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(product.description),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isLifetime ? AppColors.premiumGold : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product.price,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () => _buyProduct(product),
      ),
    );
  }

  Widget _buildErrorMessage(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
