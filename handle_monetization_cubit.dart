import 'dart:async';
import 'package:app_pubblicita_monetizazione/datasource/in_app_purchase_controller.dart';
import 'package:app_pubblicita_monetizazione/enum/request_purchase_status.dart';
import 'package:app_pubblicita_monetizazione/enum/user_level_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';


part 'handle_monetization_state.dart';

/*
1. Google Play Console: Devi creare un prodotto di tipo "Non consumabile" con l'ID premium_upgrade. Se non lo fai, queryProductDetails restituirà una lista vuota.

2. Restore: Ricorda di aggiungere un tasto "Ripristina" nel tuo BottomSheet che chiama InAppPurchase.instance.restorePurchases().
*/

class HandleMonetizationCubit extends Cubit<HandleMonetizationState> {
  ///
  ///
  final InAppPurchaseController _inAppPurchaseController;

  HandleMonetizationCubit(InAppPurchaseController inAppPurchaseController)
    : _inAppPurchaseController = inAppPurchaseController,
      super(
        HandleMonetizationState(
          userLevel: UserLevelEnum.gratis,
          requestPurchaseStatus: RequestPurchaseStatus.initial,
        ),
      ) {
    loadUserLevel();
    _getProductDetails();
    _listenToPurchase();
  }
  //
  static const _keyStorageLevel = 'user_level';
  static const _storage = FlutterSecureStorage();
  //
  StreamSubscription<List<PurchaseDetails>>? _streamSubscription;
  //
  static List<ProductDetails?> _productDetails =
      []; //--- cargamos todos los detalles del producto al abrir el app
  List<ProductDetails?> get productDetails => _productDetails;

  /// Al chiamare lo strem de Google avremo i dati aggionati per sapere se l'utente e premium o no
  void _listenToPurchase() async {
    _streamSubscription = _inAppPurchaseController.purchaseStream.listen(
      (purchaseDetailsList) async {
        //
        // 1. Verifica se l'utente possiede ancora un abbonamento valido
        final ancoraPremium = purchaseDetailsList.any((product) {
          final previousProductId =
              product.productID == _inAppPurchaseController.idProductPro ||
              product.productID == _inAppPurchaseController.idProductBaseDate ||
              product.productID == _inAppPurchaseController.idProductBaseOrari;

          return (previousProductId) &&
              (product.status == PurchaseStatus.restored ||
                  product.status == PurchaseStatus.purchased);
        });

        // Se l'utente era abbonato ma ora non ha più prodotti attivi, è stato rimborsato
        if (state.userLevel != UserLevelEnum.gratis && !ancoraPremium) {
          await _saveUserLevel(UserLevelEnum.gratis);
          return;
        }

        //--------------------------  2. Gestione dei nuovi acquisti o dei ripristini
        for (var purchaseDetails in purchaseDetailsList) {
          //
          final purchaseStatus = purchaseDetails.status;

          //--- acquistato o completato il pagamento
          if (purchaseStatus == PurchaseStatus.purchased ||
              purchaseStatus == PurchaseStatus.restored) {
            // Se l'acquisto è confermato, sblocchiamo l'app!

            UserLevelEnum levelToSet = UserLevelEnum.gratis;

            // Assegnazione diretta basata sull'ID del prodotto acquistato
            if (purchaseDetails.productID ==
                _inAppPurchaseController.idProductPro) {
              levelToSet = UserLevelEnum.pro;
            } else if (purchaseDetails.productID ==
                _inAppPurchaseController.idProductBaseDate) {
              levelToSet = UserLevelEnum.baseDate;
            } else if (purchaseDetails.productID ==
                _inAppPurchaseController.idProductBaseOrari) {
              levelToSet = UserLevelEnum.baseOrari;
            }

            if (levelToSet != UserLevelEnum.gratis) {
              await _saveUserLevel(levelToSet);
            }
          }
          // google sta processando il pagamento... mostriamo il caricamento!
          if (purchaseStatus == PurchaseStatus.pending) {
            emit(
              state.copyWith(
                requestPurchaseStatus: RequestPurchaseStatus.loading,
              ),
            );
          }

          ///Errore: Se purchaseStatus == PurchaseStatus.error.
          /// Annullamento: Se l'utente chiude il popup di Google senza comprare (PurchaseStatus.canceled).
          if (purchaseStatus == PurchaseStatus.canceled ||
              purchaseStatus == PurchaseStatus.error) {
            emit(
              state.copyWith(
                userLevel: UserLevelEnum.gratis,
                requestPurchaseStatus: RequestPurchaseStatus.error,
              ),
            );
          }

          //-- è importante
          // --- Completamento obbligatorio della transazione
          if (purchaseDetails.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchaseDetails);

            emit(
              state.copyWith(
                requestPurchaseStatus: RequestPurchaseStatus.successful,
              ),
            );
          }
        }
      },
      // --- 3. Gestione degli errori a livello di Stream
      onError: (error) {
        print("Errore nello stream degli acquisti: $error");
        emit(
          state.copyWith(requestPurchaseStatus: RequestPurchaseStatus.error),
        );
      },
      onDone: () {
        _streamSubscription?.cancel();
      },
    );
  }

  ///-- per avere i detagli del produtto pronto che l'utente apra il ShowModalBottomSheet
  Future<List<ProductDetails?>> _getProductDetails() async {
    _productDetails = await _inAppPurchaseController.getProductsDetails();

    return _productDetails;
  }

  /// carichiamo da Flutter Secure Storage il livello del utente
  Future<void> loadUserLevel() async {
    String? savedLevel = await _storage.read(key: _keyStorageLevel);
    if (savedLevel != null) {
      // Convertiamo la stringa salvata di nuovo in Enum
      final level = UserLevelEnum.values.firstWhere(
        (e) => e.toString() == savedLevel,
        orElse: () => UserLevelEnum.gratis,
      );
      //
      emit(
        HandleMonetizationState(
          userLevel: level,
          requestPurchaseStatus: RequestPurchaseStatus.initial,
        ),
      );
    }
    return;
  }

  Future<void> buyProduct({required ProductDetails productDetails}) async {
    // 1. Attiviamo il caricamento appena l'utente clicca
    emit(state.copyWith(requestPurchaseStatus: RequestPurchaseStatus.loading));
    try {
      await _inAppPurchaseController.buyPremium(productDetails);
      //
    } catch (e) {
      emit(state.copyWith(requestPurchaseStatus: RequestPurchaseStatus.error));
    }
  }

  //TODO:ELIMINAR ESTA FUNCION ES SOLO PARA TEST
  Future<void> buyProductTest({required ProductDetails productDetails}) async {
    // 1. Attiviamo il caricamento appena l'utente clicca
    emit(state.copyWith(requestPurchaseStatus: RequestPurchaseStatus.loading));
    try {
      await Future.delayed(Duration(seconds: 5));

      emit(
        state.copyWith(
          requestPurchaseStatus: RequestPurchaseStatus.successful,
          userLevel: UserLevelEnum.baseDate,
        ),
      );
    } catch (e) {
      emit(state.copyWith(requestPurchaseStatus: RequestPurchaseStatus.error));
    }
  }

  // Chiamato dopo l'acquisto di un prodotto specifico o per aggionare l'stato del acquisto
  Future<void> _saveUserLevel(UserLevelEnum newLevel) async {
    await _storage.write(key: _keyStorageLevel, value: newLevel.toString());
    emit(
      HandleMonetizationState(
        userLevel: newLevel,
        requestPurchaseStatus: RequestPurchaseStatus.initial,
      ),
    );
  }

  ///-- Se l'utente limpia la cache del app Flutter Secure storage viene pullito(cancellato)
  /// Al aprire l'app l'utente sarà gratis dovrà aggionare lo status
  Future<void> restoreUserPurchases() async {
    emit(state.copyWith(requestPurchaseStatus: RequestPurchaseStatus.loading));
    try {
      // Questo forzerà Google a inviare i dati nello stream
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      emit(state.copyWith(requestPurchaseStatus: RequestPurchaseStatus.error));
      // Qui potresti gestire l'errore (es. nessuna connessione)
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}

