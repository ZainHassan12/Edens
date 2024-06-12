import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../string.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late FirebaseFirestore firestore;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(fontFamily: semibold, color: Colors.white,),
        ),
        toolbarHeight: screenHeight * 0.06,
        backgroundColor: golden,
        leading: Container(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // BED Section
            _buildSection(
              context,
              screenWidth,
              screenHeight,
              firestore.collection('beds'),
              'BED',
            ),
            _buildSection(
              context,
              screenWidth,
              screenHeight,
              firestore.collection('sofa'),
              'SOFA',
            ),
            _buildSection(
              context,
              screenWidth,
              screenHeight,
              firestore.collection('mattress'),
              'MATTRESS',
            ),
            _buildSection(
              context,
              screenWidth,
              screenHeight,
              firestore.collection('dinning_table'),
              'TABLE',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, double screenWidth, double screenHeight, CollectionReference collection, String title) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: screenHeight * 0.03, left: screenWidth * 0.02),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: bold,
              fontSize: screenWidth * 0.06,
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: collection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final documents = snapshot.data!.docs;
            return Container(
              width: screenWidth,
              margin: const EdgeInsets.only(top: 2),
              padding: EdgeInsets.only(left: screenWidth * 0.02, bottom: screenHeight * 0.01, top: screenHeight * 0.01),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: goldenLight,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
                color: Colors.white70,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: documents.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final image = data['category_img'] ?? '';
                    final name = data['category_name'] ?? '';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Stack(
                        children: [
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.45),
                              BlendMode.srcOver,
                            ),
                            child: Image.network(
                              image,
                              width: 150,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: screenHeight * 0.04,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                color: Colors.transparent,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontFamily: bold,
                                    fontSize: 18,
                                    color: Colors.white, // Text color
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
