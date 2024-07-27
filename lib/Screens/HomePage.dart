import 'package:eshop_pingolearn/Models/prductModel.dart';
import 'package:flutter/material.dart';
import '../API/fetch_product.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  ProductPageState createState() => ProductPageState();
}

class ProductPageState extends State<ProductPage> {
  late Future<List<Product>> futureProducts;
  late FirebaseRemoteConfig remoteConfig;
  bool showDiscountedPrice = true;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts() as Future<List<Product>>;
    _initializeRemoteConfig();
    // Setting showDiscountedPrice to true manually for debugging
    setState(() {
      showDiscountedPrice = true;
    });
  }

  Future<void> _initializeRemoteConfig() async {
    remoteConfig = FirebaseRemoteConfig.instance;
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.setDefaults(<String, dynamic>{
        'show_discounted_price': true,
      });
      await remoteConfig.fetchAndActivate();
      bool remoteValue = remoteConfig.getBool('show_discounted_price');
      print('Remote Config - show_discounted_price: $remoteValue'); // Log the value
      setState(() {
        showDiscountedPrice = remoteValue;
      });
    } catch (e) {
      print('Error fetching remote config: $e');
      setState(() {
        showDiscountedPrice = true; // Default value if fetch fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff0c54be),
        title: const Text(
          'e-Shop',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          } else {
            final products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.45,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  showDiscountedPrice: showDiscountedPrice,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final bool showDiscountedPrice;

  const ProductCard({
    super.key,
    required this.product,
    required this.showDiscountedPrice,
  });

  @override
  Widget build(BuildContext context) {
    double discountedPrice = product.price - (product.price * product.discountPercentage / 100);

    // Debug print statements
    print('Product: ${product.title}');
    print('Price: ${product.price}');
    print('Discount Percentage: ${product.discountPercentage}');
    print('Discounted Price: $discountedPrice');
    print('Show Discounted Price: $showDiscountedPrice');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showDiscountedPrice) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        '\$${discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Flexible(
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                Flexible(
                  child: Text(
                    '${product.discountPercentage}% off',
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
