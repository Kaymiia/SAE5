import 'package:flutter/material.dart';
import 'package:jardin_de_cocagne/screens/map/map_screen.dart';
import 'package:jardin_de_cocagne/screens/shop/shop_screen.dart';
import 'package:jardin_de_cocagne/screens/subscription/subscription_screen.dart';
import 'package:jardin_de_cocagne/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentPage = 0;
  AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  String _userName = '';
  String _userPhoto = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1002,
      viewportFraction: 0.9,
    );
    
    // Pas de réinitialisation de _authService ici pour éviter l'erreur
    _checkLoginStatus();

    Future.delayed(const Duration(seconds: 1), () {
      _autoScroll();
    });
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final userInfo = await _authService.getUserInfo();
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _userName = userInfo['name'] ?? '';
            _userPhoto = userInfo['photo'] ?? '';
          });
        }
      }
    } catch (e) {
      print("Erreur lors de la vérification du statut: $e");
    }
  }

  void _autoScroll() {
    Future.delayed(const Duration(seconds: 10), () {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _autoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C3829),
        elevation: 0,
        title: const Text(
          'COCAGNE & CO',
          style: TextStyle(
            fontFamily: 'LilitaOne',
            color: Color.fromARGB(255, 255, 255, 240),
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isLoggedIn 
              ? _buildUserProfileButton()
              : TextButton.icon(
                  onPressed: () {
                    
                  },
                  icon: const Icon(Icons.person, color: Color.fromARGB(255, 255, 255, 240)),
                  label: const Text(
                    'Connexion',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 240),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 240),
        child: RefreshIndicator(
          onRefresh: () async {
            await _checkLoginStatus();
          },
          color: Colors.green[800],
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: SizedBox(
              height: 2000,
              child: Column(
                children: [
                  Container(
                    height: 55,
                    color: const Color(0xFF1C3829),
                  ),
                  
                  Transform.translate(
                    offset: const Offset(0, -50),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dépôt Montpellier Centre',
                                      style: TextStyle(
                                        fontFamily: 'LilitaOne',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1C3829),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 10,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF00FF00),
                                            shape: BoxShape.circle,
                                          ),
                                          margin: const EdgeInsets.only(right: 8),
                                        ),
                                        const Text(
                                          'Livré • 14h30-16h30',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF1C3829),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF1C3829), width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Suivre',
                                  style: TextStyle(
                                    fontFamily: 'LilitaOne',
                                    color: Color(0xFF1C3829),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Modifier',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Nos nouveaux paniers :',
                              style: TextStyle(
                                fontFamily: 'LilitaOne',
                                fontSize: 20,
                                color: Color(0xFF1C3829),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 400,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (int page) {
                                setState(() {
                                  _currentPage = page;
                                });
                              },
                              itemBuilder: (context, index) {
                                final actualIndex = index % 3;
                                final List<String> images = [
                                  'assets/images/Le_Petit.png',
                                  'assets/images/Le_Moyen.png',
                                  'assets/images/Le_Grand.png',
                                ];
                                
                                return Container(
                                  margin: const EdgeInsets.only(right: 24),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ShopScreen()),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        images[actualIndex],
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 75,
              left: 0,
              right: 0,
              child: Container(
                clipBehavior: Clip.none,
                height: 90,
                color: const Color.fromARGB(0, 0, 0, 0),
                child: Image.asset(
                  'assets/images/grass.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Container(
              height: 85,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.green[800],
                unselectedItemColor: Colors.grey[600],
                currentIndex: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_basket),
                    label: 'Paniers',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_basket, color: Colors.transparent),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map),
                    label: 'Trajets',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today),
                    label: 'Calendrier',
                  ),
                ],
                onTap: (index) {
                  if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DeliveryMapScreen()),
                    );
                  }
                  else if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                    );
                  }
                  else if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                },
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 85,
                  width: 85,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      height: 68,
                      width: 68,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ShopScreen()),
                          );
                        },
                        icon: const Icon(
                          Icons.shopping_basket,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileButton() {
    return InkWell(
      onTap: _showProfileMenu,
      child: Row(
        children: [
          if (_userPhoto.isNotEmpty)
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(_userPhoto),
            )
          else
            const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 20,
                color: Color(0xFF1C3829),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            _userName.isNotEmpty ? _userName.split(' ')[0] : 'Profil',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _userPhoto.isNotEmpty
                    ? NetworkImage(_userPhoto)
                    : null,
                child: _userPhoto.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
                backgroundColor: const Color(0xFF1C3829),
              ),
              const SizedBox(height: 16),
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.shopping_basket_outlined),
                title: const Text('Mes abonnements'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Paramètres'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigation vers les paramètres
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await _authService.signOut();
                  Navigator.pop(context);
                  setState(() {
                    _isLoggedIn = false;
                    _userName = '';
                    _userPhoto = '';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}