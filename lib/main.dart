import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering and Queuing App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: RestaurantList(),
    );
  }
}

class RestaurantList extends StatefulWidget {
  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  List<Restaurant> _restaurants = [];
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _getRestaurants();
  }

  Future<void> _getRestaurants() async {
    String data = await rootBundle.loadString('assets/data/restaurants.json');
    List<dynamic> restaurants = jsonDecode(data);
    List<Restaurant> restaurantList = [];

    for (var restaurantData in restaurants) {
      List<MenuItem> menuItems = [];
      for (var menuItemData in restaurantData['menu']) {
        menuItems.add(
          MenuItem(
            id: menuItemData['id'],
            name: menuItemData['name'],
            description: menuItemData['description'],
            price: menuItemData['price'],
            image: AssetImage(menuItemData['image']),
            imagemenu: AssetImage(menuItemData['imagemenu']),
          ),
        );
      }

      restaurantList.add(
        Restaurant(
          id: restaurantData['id'],
          name: restaurantData['name'],
          description: restaurantData['description'],
          image: AssetImage(restaurantData['image']),
          imagemenu: AssetImage(restaurantData['imagemenu']),
          menu: menuItems,
        ),
      );
    }

    setState(() {
      _restaurants = restaurantList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              height: 50, 
            ),
            const SizedBox(height: 8),
            const Text('Restaurants'),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(cartItems: _cartItems),
                ),
              );
            },
            icon: Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _restaurants.length,
        itemBuilder: (BuildContext context, int index) {
          var restaurant = _restaurants[index];
          return ListTile(
            title: Container(
              color: Colors.orange,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        restaurant.name,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            subtitle: GestureDetector(
              child: Image(
                image: restaurant.image,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetails(
                      restaurant: restaurant,
                      addToCart: () {
                        setState(() {
                          _cartItems.add(CartItem(menuItem: restaurant.menu[0], quantity: 1));
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class RestaurantDetails extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback addToCart;

  const RestaurantDetails({required this.restaurant, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    restaurant.description,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Location:',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Phone:',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Website:',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: addToCart,
                    child: Text('Add to Cart'),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Image(
                image: restaurant.imagemenu,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<CartItem> cartItems;

  const CartPage({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (BuildContext context, int index) {
          var cartItem = cartItems[index];
          return ListTile(
            title: Text(cartItem.menuItem.name),
            subtitle: Text('Quantity: ${cartItem.quantity}'),
            trailing: Text('Price: \$${cartItem.menuItem.price * cartItem.quantity}'),
          );
        },
      ),
    );
  }
}

class Restaurant {
  final int id;
  final String name;
  final String description;
  final AssetImage image;
  final AssetImage imagemenu;
  final List<MenuItem> menu;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.imagemenu,
    required this.menu,
  });
}

class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final AssetImage image;
  final AssetImage imagemenu;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.imagemenu,
  });
}

class CartItem {
  final MenuItem menuItem;
  final int quantity;

  const CartItem({required this.menuItem, required this.quantity});
}
