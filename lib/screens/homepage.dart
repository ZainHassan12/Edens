import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../string.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currPage = 0;
  int totalPages = 0;
  List<Map<String, dynamic>> bestSellingItems = [];
  List<Map<String, dynamic>> newArrivals = [];
  List<Widget> sliderItems = [];

  @override
  void initState() {
    super.initState();
    fetchOffers();
    fetchBestSellingItems();
    fetchNewArrivals();
  }

  Future<void> fetchOffers() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('Offer').get();

    final List<Widget> offers = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> document) {
      final String imageUrl = document.data()['img'];
      return Image.network(imageUrl);
    }).toList();

    setState(() {
      sliderItems = offers;
      totalPages = sliderItems.length;
    });
  }

  Future<void> fetchBestSellingItems() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('products').orderBy('itemSold', descending: true).limit(2).get();

    final List<Map<String, dynamic>> items = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> document) => document.data())
        .toList();

    setState(() {
      bestSellingItems = items;
    });
  }

  Future<void> fetchNewArrivals() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('products').orderBy('createdOn', descending: true).limit(2).get();

    final List<Map<String, dynamic>> items = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> document) => document.data())
        .toList();

    setState(() {
      newArrivals = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(
            fontFamily: semibold,
            color: Colors.white,
          ),
        ),
        toolbarHeight: screenHeight * 0.06,
        backgroundColor: golden,
        leading: Container(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Center(
              child: Image.asset(
                logo,
                width: screenWidth * 0.35,
              ),
            ),
            Text(
              slogan,
              style: TextStyle(
                color: golden,
                fontFamily: bold,
                fontSize: screenHeight * 0.008,
              ),
            ),
            SizedBox(
              height: screenHeight * 0.01,
            ),
            // Slider Section
            SizedBox(
              height: screenHeight * 0.3,
              child: CarouselSlider(
                items: sliderItems,
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  onPageChanged: (int index, CarouselPageChangedReason reason) {
                    setState(() {
                      currPage = index;
                    });
                  },
                ),
              ),
            ),
            Text(
              '${currPage + 1}/$totalPages',
              style: const TextStyle(
                color: golden,
              ),
            ),

            // Best Selling Section
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.02, left: screenWidth * 0.025),
              alignment: Alignment.centerLeft,
              child: Text(
                "Best Selling",
                style: TextStyle(
                  color: greyDark,
                  fontFamily: bold,
                  fontSize: screenWidth * 0.07,
                ),
              ),
            ),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bestSellingItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: 180,
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 8),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: golden,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "-${bestSellingItems[index]['discount'] ?? '0'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: golden,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.favorite_border,
                              color: greyDark,
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.all(7),
                            height: 100,
                            width: 100,
                            child: Image.network(bestSellingItems[index]['product_img'] ?? ''),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 9, top: 2, left: 3),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            bestSellingItems[index]['product_title'] ?? '',
                            style: const TextStyle(
                              fontFamily: semibold,
                              fontSize: 15,
                              color: greyDark,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "\$${bestSellingItems[index]['price'] ?? '0'}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: bold,
                                  color: golden,
                                ),
                              ),
                              const Icon(
                                Icons.shopping_cart_checkout,
                                color: greyDark,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            // New Arrivals Section
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: screenHeight * 0.02, left: screenWidth * 0.025),
              child: Text(
                "New Arrivals",
                style: TextStyle(
                  color: greyDark,
                  fontFamily: bold,
                  fontSize: screenWidth * 0.07,
                ),
              ),
            ),
            GridView.count(
              childAspectRatio: 0.68,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: newArrivals.map((newArrival) {
                return Container(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: golden,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "-${newArrival['discount'] ?? '0'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: golden,
                                  fontFamily: bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.favorite_border,
                              color: greyDark,
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 120,
                            width: 120,
                            child: Image.network(newArrival['product_img'] ?? ''),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            newArrival['product_title'] ?? '',
                            style: const TextStyle(
                              fontFamily: semibold,
                              fontSize: 15,
                              color: greyDark,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "\$${newArrival['price'] ?? '0'}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: bold,
                                  color: golden,
                                ),
                              ),
                              const Icon(
                                Icons.shopping_cart_checkout,
                                color: greyDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
