import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';





class PurchaseProvider extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _available = true;
  bool isProUser = false;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  String? _purchaseError;
  set purchaseError(String? origin) {
    _purchaseError = origin;
  }

  String? get purchaseError => _purchaseError;

  PurchaseProvider() {
  

    initStoreInfo();
    _subscription = _inAppPurchase.purchaseStream.listen(_onPurchaseUpdates);
  }

  bool get isAvailable => _available;
  List<ProductDetails> get products => _products;

  final List<String> _consumableIds = [
    'com.sportstakearena.pro'

  ];
  final Set<String> _productIds = {
    'com.sportstakearena.pro'
    // 
  };
  Future<bool> restoreItem() async {
    await _inAppPurchase.restorePurchases();
    return Future.value(true);
  }
  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      _available = isAvailable;
      return;
    }

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      print('These products were not found: ${response.notFoundIDs}');
    }
    _products = response.productDetails;
    final prefs = await SharedPreferences.getInstance();
    isProUser = prefs.getBool('is_purchased') ?? false;
    await _clearPendingPurchases();
  }

  Future<void> _clearPendingPurchases() async {
    if (Platform.isIOS) {
      try {
        final transactions = await SKPaymentQueueWrapper().transactions();
        for (final transaction in transactions) {
          // print("##### pending transaction found");
          try {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
          } catch (e) {
            debugPrint("Error clearing pending purchases::in::loop");
            debugPrint(e.toString());
        
          }
        }
      } catch (e) {
        debugPrint("Error clearing pending purchases");
        debugPrint(e.toString());
      
      }
    }
  }

  void _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    print("purchase _onPurchaseUpdates ${purchases.length}");
    purchases.forEach((purchase) async {
      print(
          "purchase ${purchase.productID} ${purchase.status} ${purchase.error?.details} ${purchase.error?.source} ${purchase.error?.code}");
      if (purchase.status == PurchaseStatus.pending) {
        print("Purchased item pending");
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
          _purchaseError = null;
          if (_consumableIds.contains(purchase.productID)) {
        
          } else {
            await deliverPurchase();
          }

          notifyListeners();
        }
      } else if (purchase.status == PurchaseStatus.purchased) {
       
        _purchaseError = null;
        if (_consumableIds.contains(purchase.productID)) {
        
        } else {
          await deliverPurchase();
        }
        notifyListeners();
      } else if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
   

        notifyListeners();
      } else if (purchase.status == PurchaseStatus.restored ||
          purchase.status == PurchaseStatus.canceled) {
        _purchaseError = null;
        await deliverPurchase();
        notifyListeners();
      }
    });
  }

  // Future<bool> restoreItem() async {
  //   await _inAppPurchase.restorePurchases();
  //   return Future.value(true);
  // }

  Future<void> deliverPurchase() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_purchased', true);
    isProUser = true;
   
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
   

    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> buyConsumableProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    print(
        "tarun....inappmanager buying state ${purchaseParam.productDetails.id}");

    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  
}