import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:soccer/apputils/appcolor.dart';
import 'package:soccer/provider/inappropriate.dart';

class InAppPurchasePage extends StatefulWidget {
  const InAppPurchasePage({super.key});

  @override
  State<InAppPurchasePage> createState() => _InAppPurchasePageState();
}

class _InAppPurchasePageState extends State<InAppPurchasePage> {
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
    print("didChangeDependencies ${purchaseProvider.purchaseError}");
  }

  void showErrorDialog(BuildContext context, String? message) {
    if (message != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Purchase Error', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Failed to buy pro version.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = false;
                  });
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseProvider>(
      builder: (context, purchaseProvider, _) {
        if (purchaseProvider.purchaseError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showErrorDialog(context, purchaseProvider.purchaseError);
            purchaseProvider.purchaseError = null;
          });
        }

        if (purchaseProvider.isProUser) {
          if (isLoading) {
            isLoading = false;
          }
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Premium", style: TextStyle(color: color5)),
              ),
              body: const Center(
                child: Text(
                  "You are already a premium user",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
  backgroundColor: color6,
  body: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios_new, color: Color.fromRGBO(243, 43, 79, 1))),
            ),
            const SizedBox(width: 20, height: 100),
            const Text(
              "Remove ads",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 30),
        
        // Wrap Stack in a SizedBox with constraints
       
        
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            color: const Color.fromARGB(255, 106, 94, 94),
            ),
            
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Image.asset("assets/premium-service (1) 1.png"),
                   Text(
                    "Remove Ads",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 10,),
                  Text(
                  "    Enjoy an ad-free\n experience for only ",
                  style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20,),
                Text(
                  "\$0.99",
                  style: TextStyle(color: const Color.fromARGB(255, 228, 210, 49), fontSize: 26, fontWeight: FontWeight.w800),
                ),
                ],
              ),
            
          ),
        ),
        
        
          
            
               SizedBox(width: 20,),
               Text(r"$ 0.9",style: TextStyle(color: color5, fontSize: 16, fontWeight: FontWeight.bold),),

             Row(
               children: [
                SizedBox(width: 30,),
                 ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   minimumSize: const Size(356, 42),
                   backgroundColor: const Color.fromRGBO(243, 43, 79, 1) ,
                   padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(30),
                   ),
                 ),
                 onPressed: () async {
                   setState(() {
                     isLoading = true;
                   });
                   if (purchaseProvider.products.isNotEmpty) {
                     await purchaseProvider.buyProduct(purchaseProvider.products[0]);
                   }
                   setState(() {
                     isLoading = false;
                   });
                 },
                 child: isLoading
                     ? const CircularProgressIndicator(color: Colors.white)
                     : const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18)),
                            ),
               ],
             ),
         
         const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(width: 60,),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No thanks", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),

         Row(
           children: [
            SizedBox(width: 60) ,            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(20)
              ),
              width: 300,
               child: TextButton(
                 onPressed: () async {
                   await purchaseProvider.restoreItem();
                 },

                   child: Center(child: Text("Restore purchase", style: TextStyle(color: Color.fromARGB(255, 153, 39, 39), fontSize: 16))),
                 ),
               ),
             
           ],
         ),
        const SizedBox(height: 20),
       
      ]     
      
    ),
  )
  );
        }
      }
    );
  }
}