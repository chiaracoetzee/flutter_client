import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fluxer_app/features/settings/services/plutonium_store_products.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class PlutoniumStoreProduct {
  const PlutoniumStoreProduct({
    required this.id,
    required this.priceLabel,
    required this.rawPrice,
    required this.details,
  });

  final String id;
  final String priceLabel;
  final double rawPrice;
  final ProductDetails details;
}

class PlutoniumStoreProductSet {
  const PlutoniumStoreProductSet({this.monthly, this.yearly});

  final PlutoniumStoreProduct? monthly;
  final PlutoniumStoreProduct? yearly;
}

abstract class PlutoniumStorePurchaseClient {
  bool get supportsPurchases;

  Future<bool> isStoreAvailable();

  Future<PlutoniumStoreProductSet> loadProducts();

  Future<bool> buy(PlutoniumStoreProduct product);

  Stream<List<PurchaseDetails>> get purchaseUpdates;

  Future<void> complete(PurchaseDetails purchase);

  Future<void> restore();
}

class UnavailablePlutoniumStorePurchaseClient
    implements PlutoniumStorePurchaseClient {
  const UnavailablePlutoniumStorePurchaseClient();

  @override
  bool get supportsPurchases => false;

  @override
  Future<bool> isStoreAvailable() async => false;

  @override
  Future<PlutoniumStoreProductSet> loadProducts() async {
    return const PlutoniumStoreProductSet();
  }

  @override
  Future<bool> buy(PlutoniumStoreProduct product) async => false;

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => const Stream.empty();

  @override
  Future<void> complete(PurchaseDetails purchase) async {}

  @override
  Future<void> restore() async {}
}

class AndroidPlutoniumStorePurchaseClient
    implements PlutoniumStorePurchaseClient {
  AndroidPlutoniumStorePurchaseClient(this._billing);

  final InAppPurchase _billing;

  @override
  bool get supportsPurchases => true;

  @override
  Future<bool> isStoreAvailable() => _billing.isAvailable();

  @override
  Future<PlutoniumStoreProductSet> loadProducts() async {
    final ProductDetailsResponse response = await _billing.queryProductDetails(
      kPlutoniumStoreProductIds,
    );
    return PlutoniumStoreProductSet(
      monthly: _pick(response.productDetails, kPlutoniumStoreMonthlyProductId),
      yearly: _pick(response.productDetails, kPlutoniumStoreYearlyProductId),
    );
  }

  @override
  Future<bool> buy(PlutoniumStoreProduct product) {
    final ProductDetails details = product.details;
    final String? offerToken = details is GooglePlayProductDetails
        ? details.offerToken
        : null;
    if (offerToken == null || offerToken.isEmpty) {
      return Future<bool>.value(false);
    }
    return _billing.buyNonConsumable(
      purchaseParam: GooglePlayPurchaseParam(
        productDetails: details,
        offerToken: offerToken,
      ),
    );
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => _billing.purchaseStream;

  @override
  Future<void> complete(PurchaseDetails purchase) {
    return _billing.completePurchase(purchase);
  }

  @override
  Future<void> restore() => _billing.restorePurchases();

  PlutoniumStoreProduct? _pick(List<ProductDetails> products, String id) {
    ProductDetails? best;
    for (final ProductDetails details in products) {
      if (details.id != id) {
        continue;
      }
      if (best == null || details.rawPrice > best.rawPrice) {
        best = details;
      }
    }
    if (best == null) {
      return null;
    }
    return PlutoniumStoreProduct(
      id: best.id,
      priceLabel: best.price,
      rawPrice: best.rawPrice,
      details: best,
    );
  }
}

PlutoniumStorePurchaseClient createPlutoniumStorePurchaseClient() {
  if (!plutoniumStorePurchasesEnabled || kIsWeb || !Platform.isAndroid) {
    return const UnavailablePlutoniumStorePurchaseClient();
  }
  return AndroidPlutoniumStorePurchaseClient(InAppPurchase.instance);
}
