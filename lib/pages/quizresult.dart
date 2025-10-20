import 'package:flutter/material.dart';
import '../models/questions.dart';
import '../models/product.dart';

class QuizRecommendations extends StatelessWidget{
  final Map<int, String> userLogs;
  final List<Questions> questions;

  QuizRecommendations({
    required this.userLogs,
    required this.questions,
  });

  List<Product> getRecommendations(){
    List<Product> products = [];

    String skinType = userLogs[0]!;
    String skinConcern = userLogs[1]!;
    String climate = userLogs[4]!;

    if(skinType == 'Oily'){
      products.add(Product(
        name: 'CeraVe Foaming Facial Cleanser',
        description: 'Oil control cleanser for daily use',
        step: 'Step 1: Cleanser',
        image: 'assets/images/foaming.png',
      ));
    }
    else if(skinType == 'Dry' || skinType == 'Sensitive' || skinType == 'Combination'){
      products.add(Product(
        name: 'CeraVe Hydrating Cleanser',
        description: 'Gentle hydrating cleanser for daily use',
        step: 'Step 1: Cleanser',
        image: 'assets/images/hydrating.png',
      ));
    }
    else if(skinType == 'Normal'){
      products.add(Product(
        name: 'Neutrogena Gentle Cleanser',
        description: 'Gentle hydrating cleanser for daily use',
        step: 'Step 1: Cleanser',
        image: 'assets/images/daily.png',
      ));
    }

    if(skinConcern == 'Acne'){
      products.add(Product(
        name: 'Madagascar Centella Asiatica Ampoule',
        description: 'For soothing sensitive and acne-prone skin',
        step: 'Step 2: Treatment',
        image: 'assets/images/acneserum.png',
      ));
    }
    else if(skinConcern == 'Pigmentation'){
      products.add(Product(
        name: 'Haruharu Wonder Dark Spot Go Away Serum ',
        description: 'For acne scars and hyperpigmentation',
        step: 'Step 2: Treatment',
        image: 'assets/images/darkspotgoaway.png',
      ));
    }
    else if(skinConcern == 'Aging'){
      products.add(Product(
        name: 'CeraVe Retinol Serum',
        description: 'For wrinkles, pores and aging',
        step: 'Step 2: Treatment',
        image: 'assets/images/retinolserum.png',
      ));
    }
    else if(skinConcern == 'Dryness' || skinConcern == 'Redness'){
      products.add(Product(
        name: 'Anua Azelaic Acid',
        description: 'For soothing irritated skin',
        step: 'Step 2: Treatment',
        image: 'assets/images/rednessazelaicanua.png',
      ));
    }
    products.add(Product(
      name: 'Cosrx Advanced Snail 92 Cream',
      description: 'For moisturizing skin',
      step: 'Step 3: Moisturize',
      image: 'assets/images/cosrx.png',
    ));
    if(climate == 'Moderate' || climate == 'Cold & Dry'){
      products.add(Product(
        name: 'Haruharu Black Rice Sunscreen',
        description: 'Moisturizing sunscreen for cold and dry weather',
        step: 'Step 4: Sunscreen',
        image: 'assets/images/haruharucoldrysunscreen.png',
      ));
    }
    else if(climate == 'Rainy'){
      products.add(Product(
        name: 'Cosrx Vitamin E Sunscreen',
        description: 'Vitalizing sunscreen for rainy weather',
        step: 'Step 4: Sunscreen',
        image: 'assets/images/cosrxsunscreenrainy.png',
      ));
    }
    else if(climate == 'Hot & Humid' || climate == 'Desert'){
      products.add(Product(
        name: 'Klairs Airy Sunscreen',
        description: 'For hot and humid weather',
        step: 'Step 4: Sunscreen',
        image: 'assets/images/klairsairy.png',
      ));
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final products = getRecommendations();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color:Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Recommendations",
          style: TextStyle(
            color: Colors.black,
          ),),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Color.fromARGB(210, 206, 156, 90),
                ),
                SizedBox(height:16),
                Text(
                  "Your personalized routine",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height:20),
                Text(
                  'Follow these steps daily for best results',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal:24, vertical:20),
                itemCount: products.length,
                itemBuilder: (context, index){
                  final product = products[index];
                  final lastProduct = index == products.length -1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Column(
                        children:[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 185, 144, 90),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white,
                                  width: 3
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 179, 134, 76),
                                  spreadRadius: 2.0,
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${index+1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          if(!lastProduct)
                            Container(
                              width: 3,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromARGB(255, 185, 144, 90),
                                    Color.fromARGB(255, 185, 144, 90).withOpacity(0.3), //warna line nazar nahi aa rahi thi
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(width:16),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: lastProduct ? 0:20 //for spacing b/w the product parts)
                          ),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width:80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: AssetImage(product.image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width:16),//for space between image and text pehle nahi tha

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.step,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        color: Color.fromARGB(255, 185, 144, 106),
                                      ),
                                    ),
                                    SizedBox(height:6),

                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                    ),
                                    SizedBox(height:4),

                                    Text(
                                      product.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                    ),
                                    SizedBox(height:6),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );

                }
            ),
          ),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SafeArea(
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.popUntil(context, (route)=> route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55),
                    backgroundColor: Color.fromARGB(255, 185, 144, 106),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),),
                )
            ),

          ),

        ],
      ),

    );
  }
}
