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
  backgroundColor: const Color(0XFF0F1923),
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
        SizedBox(
          width: double.infinity,
          height: 200, // You can adjust the height as needed
          child: Stack(
            clipBehavior: Clip.none,
            children: [
   
                          Positioned(left: 30,
                          
                           child: Image.asset("assets/Frame 4.png")),
              Positioned(left: 95,
              bottom: 90,
               child: Image.asset("assets/image15.png")),
              
              Positioned(left: 218,
              top:-0,
               child: Image.asset("assets/image16.png")),
               Positioned(left: 200,
              top: 80,
               child: Image.asset("assets/image17.png")),
              Positioned(left: 60,
              top: 130,
               child: Image.asset("assets/Frame 7.png")),
               
              Positioned(left: 160,
              bottom: -100,
               child: Image.asset("assets/image18.png")),
            ],
          ),
        ),
        const SizedBox(height: 130,),
        
        const Padding(
          padding: EdgeInsets.only(left: 70),
          child: Text(
            "Get-Premium",
            style: TextStyle(color: Color.fromRGBO(243, 43, 79, 1) , fontSize: 24),
          ),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            "Make the AD-Free access for yourself\nso you don’t get distract from duty",
            style: TextStyle(color: color5, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 50),
        const Row(
          children: [
            SizedBox(width: 70,),
            Text(
                "Unlock Premium Features",
                style: TextStyle(color: color5, fontSize: 16, fontWeight: FontWeight.bold),
              ),
               SizedBox(width: 20,),
               Text(r"$ 0.9",style: TextStyle(color: color5, fontSize: 16, fontWeight: FontWeight.bold),),
               
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Container(height: 1,color: color2,width: 250,),
        ),
        const SizedBox(height: 20,),

        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ElevatedButton(
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
        ),
        const SizedBox(height: 15),
        // TextButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   child: const Text("No thanks", style: TextStyle(color: Colors.white, fontSize: 16)),
        // ),
        TextButton(
          onPressed: () async {
            await purchaseProvider.restoreItem();
          },
          child: const Padding(
            padding: EdgeInsets.only(left:120),
            child: Text("Restore purchase", style: TextStyle(color: Color.fromARGB(255, 153, 39, 39), fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  ),
);
        }
      }
    );
  }
}