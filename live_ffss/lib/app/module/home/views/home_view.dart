import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/competition_model.dart';
import 'package:live_ffss/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../../../widgets/user_avatar.dart';
import '../../../widgets/language_selector.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/images/logo_ffss.png', // Make sure to add this asset
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image isn't available
                return const Icon(
                  Icons.app_shortcut,
                  size: 32,
                  color: Colors.white,
                );
              },
            ),
            const SizedBox(width: 8),
            // App title now uses translation
            Obx(
              () => Text(
                controller.appTitle.value,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Language selector
          const LanguageSelector(),
          const SizedBox(width: 8),
          // User avatar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: UserAvatar(
              size: 36,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : controller.hasError.value
              ? _buildErrorView()
              : _buildContentView()),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'error_occurred'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.loadCompetitions,
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterTabs(),
            const SizedBox(height: 16),
            _buildWeekendHeader(),
            const SizedBox(height: 8),
            _buildCarousel(),
            const SizedBox(height: 24),
            // _buildCompetitionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterTab('all'.tr),
          const SizedBox(width: 10),
          _buildFilterTab('swimming'.tr),
          const SizedBox(width: 10),
          _buildFilterTab('beach'.tr),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    return Obx(() {
      final isActive = controller.selectedFilter.value == label;
      return GestureDetector(
        onTap: () => controller.setFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0275FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:
                isActive ? null : Border.all(color: const Color(0xFF0275FF)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF0275FF),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWeekendHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'this_week_end'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'see_more'.tr,
              style: const TextStyle(
                color: Color(0xFF0275FF),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Obx(() {
      final competitions = controller.carouselCompetitions;
      return CarouselSlider(
        options: CarouselOptions(
          height: 200,
          viewportFraction: 0.85,
          enableInfiniteScroll: competitions.length > 1,
          enlargeCenterPage: true,
          autoPlay: competitions.length > 1,
          autoPlayInterval: const Duration(seconds: 5),
        ),
        items: competitions.map((competition) {
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () =>
                    controller.navigateToCompetitionDetails(competition),
                child: _buildCarouselItem(competition),
              );
            },
          );
        }).toList(),
      );
    });
  }

  Widget _buildCarouselItem(CompetitionModel competition) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image section
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: _buildImagePlaceholder(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0275FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    competition.formattedBeginDate,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (competition.competitionStatus == 'EN COURS')
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: competition.competitionStatusColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      competition.competitionStatus,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Text section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    competition.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // Button
          Padding(
            padding: EdgeInsets.all(12),
            child: OutlinedButton(
              onPressed: () =>
                  controller.navigateToCompetitionDetails(competition),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF0275FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(100, 36),
              ),
              child: Text(
                'Voir',
                style: TextStyle(
                  color: Color(0xFF0275FF),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       automaticallyImplyLeading: false,
  //       title: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           // App logo
  //           Image.asset(
  //             'assets/images/logo_ffss.png', // Make sure to add this asset
  //             height: 32,
  //             errorBuilder: (context, error, stackTrace) {
  //               // Fallback if image isn't available
  //               return const Icon(
  //                 Icons.app_shortcut,
  //                 size: 32,
  //                 color: Colors.white,
  //               );
  //             },
  //           ),
  //           const SizedBox(width: 8),
  //           // App title now uses translation
  //           Obx(
  //             () => Text(
  //               controller.appTitle.value,
  //               style: Theme.of(context).textTheme.headlineLarge,
  //             ),
  //           ),
  //         ],
  //       ),
  //       centerTitle: true,
  //       actions: [
  //         // Language selector
  //         const LanguageSelector(),
  //         const SizedBox(width: 8),
  //         // User avatar
  //         Padding(
  //           padding: const EdgeInsets.only(right: 16.0),
  //           child: UserAvatar(
  //             size: 36,
  //             backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
  //           ),
  //         ),
  //       ],
  //     ),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             'welcome_message'.tr,
  //             style: Theme.of(context).textTheme.headlineMedium,
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'content_placeholder'.tr,
  //             style: Theme.of(context).textTheme.bodyLarge,
  //           ),
  //           const SizedBox(height: 32),
  //           Obx(() => controller.isLoggedIn.value
  //               ? Text('logged_in_message'.tr)
  //               : ElevatedButton(
  //                   onPressed: () => Get.toNamed(Routes.login),
  //                   child: Text('go_to_login'.tr),
  //                 )),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
