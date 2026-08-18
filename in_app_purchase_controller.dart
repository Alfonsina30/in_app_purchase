import 'package:in_app_purchase/in_app_purchase.dart';

//---Questo si occupa di ascoltare Google Play e verificare se l'utente ha pagato.
class InAppPurchaseController {
  /*
Oggi Google esige che l'ID sia creato nella tua Console perché deve essere collegato al tuo account venditore.
  */

  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  //TODO: CAMBIAR ESTA LISTA DE PRODUCTOS
  String get idProductBaseDate => 'ProductBaseDate';
  String get idProductBaseOrari => 'ProductBaseOrari';
  String get idProductPro => 'ProductPro';

  //-- stream che il cubit ascolterà
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;

  // Carica i dettagli del prezzo (es. "€4.99")
  //-- serve a preparare l'interfaccia (per mostrare il prezzo corretto)
  Future<List<ProductDetails?>> getProductsDetails() async {
    //
    final paymentIsAvalible = await _inAppPurchase.isAvailable();

    if (!paymentIsAvalible) return [];

    //--queryProductDetails è un set dove possiamos inserire più id produtti
    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails({
          idProductBaseDate,
          idProductBaseOrari,
          idProductPro,
        });

    final List<ProductDetails> productDetails = response.productDetails;

    return productDetails.isNotEmpty ? productDetails : [];
  }

  // Avvia l'acquisto
  // serve a eseguire l'azione quando l'utente clicca.
  Future<bool> buyPremium(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    //---buyNonConsumable è utilizzato per suscription or accedere ai contenuti nell'app
    ///-- per sapere lo stato della compra si saprà tramite lo Stream [purchaseStream]
    return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }
}
