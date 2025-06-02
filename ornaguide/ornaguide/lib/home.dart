import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ornaguide/welcome.dart';
import 'package:ornaguide/results.dart';
import 'package:ornaguide/settings.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ornaguide/carousel.dart';
import 'package:ornaguide/functions/getText.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ornaguide/firestore_services.dart';
import 'package:ornaguide/functions/pickImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ornaguide/functions/toggleLanguage.dart';
import 'package:ornaguide/widgets/buildFeatureCard.dart';
import 'package:ornaguide/functions/getUserFullName.dart';
import 'package:ornaguide/functions/parsePlantResponse.dart';
import 'package:ornaguide/widgets/buildHistoryItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.auth});
  final FirebaseAuth auth;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Add FirestoreService instance
  final FirestoreService _firestoreService = FirestoreService();

  // Initialize the search controller
  late TextEditingController _searchController;

  // Initialize the search focus node
  final FocusNode _searchFocusNode = FocusNode();

  // Carousel images list
  final List<String> carouselImages = [
    'assets/plant1.png',
    'assets/plant2.png',
    'assets/plant3.jpg',
  ];

  // docIDs list to store user IDs
  List<String> docIDs = [];

  // plantIDs list to store plant doc IDs
  List<String> plantIDs = [];

  // docId of Plant
  String plantDocId = '';

  // user first and last name
  String firstName = '';
  String lastName = '';

  // get docIDs
  Future getDocId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User not logged in");
        return;
      }

      // Get current user's document
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          docIDs = [user.uid]; // Only store current user's ID
        });
      }
    } on FirebaseException catch (e) {
      print("Firestore error: ${e.message}");
    }
  }

  // get plantIDs
  Future getPlantId() async {
    await FirebaseFirestore.instance.collection('plants').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
        plantIDs.add(document.reference.id);
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (widget.auth.currentUser != null) {
      getDocId();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Search for a plant
  Future<void> searchPlant(String plantName) async {
    if (plantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getText('emptySearch', isArabic: _isArabic))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await getPlantInfo(plantName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getText('searchError', isArabic: _isArabic))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  File? _image;
  Map<String, String> _plantInfo = {
    'name_en': '',
    'name_ar': '',
    'description_en': '',
    'description_ar': '',
    'type_en': '',
    'type_ar': '',
    'fact_en': '',
    'fact_ar': '',
  };
  bool _isLoading = false;
  bool _isArabic = false; // Default language is English

  final String plantIdApiKey = 'iNFUdiZFXYdRs2alZdYntKHDoZ1c4gjuTGqDCj1kbsAMcuhUDc';
  final String openAiApiKey =
      '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';

  Future<void> identifyPlant(File imageFile) async {
    setState(() {
      _isLoading = true;
      _image = imageFile; // Set the image state variable - this is important!
    });

    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('https://api.plant.id/v2/identify'),
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': plantIdApiKey,
        },
        body: jsonEncode({
          "images": [base64Image],
          "organs": ["leaf"],
          "plant_language": "en",
          "plant_details": ["common_names"],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['suggestions'] != null && data['suggestions'].length > 0) {
          String scientificName = data['suggestions'][0]['plant_name'];
          await getPlantInfo(scientificName);
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> getPlantInfo(String plantName) async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          "model": "gpt-4",
          "messages": [
            {
              "role": "system",
              "content":
              "You are a plant expert. Provide information in English with this EXACT structure and do NOT refer to plants by their scientific name such as naming a plant 'Dracaena trifasciata (also known as Snake Plant)', in cases like this you are only to output 'Snake Plant'. As for the temperature, make sure that it is displayed in celsius only ('x celsius', where x represents the temperature). And the dates and numbers provided in the schedule are just placeholders, place all the days of the week which the plant needs to be watered (Create a table with all 7 days of the week and only fill the days which require watering with watering information, days where the plant doesn't need to get watered have a '-' placed in their cells. Also assume the first day of the week is Sunday.), then provide the proper time and time of day for these watering periods:\n\n"
                  "1. Common Name: [Name]\n"
                  "2. Plant Family: [Family]\n"
                  "3. External Description: [Description]\n"
                  "4. Ornamental Type: [Type]\n"
                  "5. Common Diseases/Pests: [Diseases]\n"
                  "6. Basic Care Schedule:\n"
                  "| Care Item      | Details          |\n"
                  "|----------------|------------------|\n"
                  "| Watering       | [Info]           |\n"
                  "| Light          | [Info]           |\n"
                  "| Temperature    | [Info]           |\n"
                  "| Fertilization  | [Info]           |\n"
                  "7. Weekly Watering Schedule:\n"
                  "| Day         | Water Amount | Time          |\n"
                  "|-------------|--------------|---------------|\n"
                  "| Monday      | 500 ml        | Morning       |\n"
                  "| Wednesday   | 300 ml        | Evening       |\n"
                  "| Friday      | 400 ml        | Afternoon     |"
            },
            {
              "role": "user",
              "content": "Provide information for: $plantName"
            }
          ],
          "temperature": 0.3
        }),
      );

      if (response.statusCode == 200) {
        String decodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedResponse);
        final reply = data['choices'][0]['message']['content'].trim();
        Map<String, String> parsedData = parsePlantResponse(reply);

        await _firestoreService.savePlantHistory(parsedData);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage(
                plantInfo: parsedData,
                isArabic: _isArabic,
                docId: plantDocId,  // Use the existing plantDocId variable
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F5451),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .7,
        minChildSize: .4,
        maxChildSize: .9,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                getText('recentlyViewed', isArabic: _isArabic),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _historyList(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyList(ScrollController controller) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getHistoryStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text(
              getText('noHistory', isArabic: _isArabic),
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.separated(
          controller: controller,
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final docId = docs[i].id;

            return buildHistoryItem(
              context: context,
              data: data,
              docId: docId,
              isArabic: _isArabic,
            );
          },
        );
      },
    );
  }

  void signoutuser(BuildContext context) async {
    await widget.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
          (r) => false,
    );
  }

  // Toggle language function
  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });
    // Show a brief message to confirm language change
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isArabic ? 'تم التحويل إلى اللغة العربية' : 'Switched to English'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF0E9B81),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F5451),
        body: SafeArea(
          child: Stack(
            children: [
              // Decorative background elements
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -70,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Main content
              CustomScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverToBoxAdapter(child: _buildHeader()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getText('identifyPlant', isArabic: _isArabic),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureRow(),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getText('featuredPlants', isArabic: _isArabic),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CarouselSlider(
                            images: carouselImages,
                            height: 180.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              // Bottom buttons layout
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Settings button
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SettingsPage(auth: widget.auth),
                          ),
                        ),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.settings, color: Colors.white),
                        ),
                      ),

                      // Logout button
                      GestureDetector(
                        onTap: () => signoutuser(context),
                        child: Container(
                          width: 180,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E9B81),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            getText('signOut', isArabic: _isArabic),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // History button
                      GestureDetector(
                        onTap: _showHistorySheet,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.history, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading indicator
              if (_isLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E9B81)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<String>(
        future: getUserFullName(),
        builder: (context, snapshot) {
          final name = snapshot.data ?? '';
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${getText('welcome', isArabic: _isArabic)}$name!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getText('welcomeBack', isArabic: _isArabic),
                      style: const TextStyle(
                        color: Color(0xFFB5E2E0),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Replace profile picture with language toggle
              GestureDetector(
                onTap: _toggleLanguage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E9B81),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.translate,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isArabic ? 'English' : 'العربية',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (query) => searchPlant(query.trim()),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(.12),
            hintText: getText('searchHint', isArabic: _isArabic),
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () => _searchController.clear(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.white.withOpacity(.25), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Color(0xFF0E9B81), width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow() {
    return Row(
      children: [
        Expanded(
          child: _buildFeatureTile(
            title: getText('capturePlant', isArabic: _isArabic),
            subtitle: getText('captureSub', isArabic: _isArabic),
            icon: Icons.camera_alt,
            onTap: () => pickImage(
              source: ImageSource.camera,
              setState: setState,
              onImagePicked: (image) {
                setState(() => _image = image);
                identifyPlant(image);
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildFeatureTile(
            title: getText('import pic', isArabic: _isArabic),
            subtitle: getText('uploadSub', isArabic: _isArabic),
            icon: Icons.photo_album,
            onTap: () => pickImage(
              source: ImageSource.gallery,
              setState: setState,
              onImagePicked: (image) {
                setState(() => _image = image);
                identifyPlant(image);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F8F7), Color(0xFFC4EAEA)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF28B476).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: const Color(0xFF28B476)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F5451),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: Color(0xFF0F5451),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}