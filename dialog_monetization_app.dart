import 'package:app_pubblicita_monetizazione/cubit/handle_monetization_cubit.dart';
import 'package:app_pubblicita_monetizazione/enum/request_purchase_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class DialogMonetizationApp {
  DialogMonetizationApp._();
  //
  static Future<void> showDialog(BuildContext context) async {
    //
    final products = context.read<HandleMonetizationCubit>().productDetails;

    final listProductsDetails = (products.isNotEmpty)
        ? products
        : [
            ProductDetails(
              id: '1',
              title: 'Base',
              description: 'Base Product',
              price: '2.99',
              rawPrice: 2.99,
              //-- codigo de la moneda
              currencyCode: '£',
            ),
            //
            ProductDetails(
              id: '2',
              title: 'Premium',
              description: 'Premium Product',
              price: '2.99',
              rawPrice: 2.99,
              currencyCode: '£',
            ),
          ];

    //
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) {
        return Stack(
          children: [
            //
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.70,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body:
                    BlocListener<
                      HandleMonetizationCubit,
                      HandleMonetizationState
                    >(
                      listener: (context, state) {
                        if (state.requestPurchaseStatus ==
                                RequestPurchaseStatus.successful ||
                            state.requestPurchaseStatus ==
                                RequestPurchaseStatus.error) {
                          //
                          final message =
                              state.requestPurchaseStatus ==
                                  RequestPurchaseStatus.successful
                              ? 'Purchase completed successfully'
                              : "An error occurred during the purchase";

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.indigo.shade300,
                              behavior: SnackBarBehavior.fixed,
                            ),
                          );

                          Navigator.pop(context);

                          return;
                        }
                      },
                      child: ProductsList(
                        listProductsDetails: listProductsDetails,
                      ),
                    ),
              ),
            ),

            Positioned(
              child:
                  BlocSelector<
                    HandleMonetizationCubit,
                    HandleMonetizationState,
                    bool
                  >(
                    selector: (state) =>
                        state.requestPurchaseStatus ==
                        RequestPurchaseStatus.loading,
                    builder: (context, isLoading) {
                      if (isLoading) {
                        return Container(
                          color: Colors.white54,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: Colors.deepOrange,
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
            ),
          ],
        );
      },
    );
  }
}

class ProductsList extends StatelessWidget {
  const ProductsList({super.key, required this.listProductsDetails});

  final List<ProductDetails?> listProductsDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),

        Text(
          'Product List',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: listProductsDetails.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final product = listProductsDetails[index];
              return Container(
                width: 200,
                height: 20,
                margin: EdgeInsets.symmetric(horizontal: 15),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 15,
                  children: [
                    Text(
                      product!.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      product.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    FilledButton(
                      onPressed: () async {
                        //TODO: DESCOMENTAR ESTA FUNCION
                        /*
                        await context
                            .read<HandlePremiumAppCubit>()
                            .buyProduct(productDetails: product);
    */
                        await context
                            .read<HandleMonetizationCubit>()
                            .buyProductTest(productDetails: product);
                      },
                      style: ButtonStyle(
                        elevation: WidgetStatePropertyAll(20),
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xFF2C9BFF),
                        ),
                      ),
                      child: Text(
                        'Buy for ${product.currencyCode}${product.price}',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        //!--------------------------------------- BUTTONS --------------------------
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.black),
          ),
          child: Text('No, Thanks'),
        ),

        TextButton(
          onPressed: () async {
            await context
                .read<HandleMonetizationCubit>()
                .restoreUserPurchases();
          },
          child: Text(
            "Already purchased? Restore here",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
