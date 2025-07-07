import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/data/models/competition_model.dart';
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
              height: 48,
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
            _buildCompetitionsList(),
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
          height: 280,
          viewportFraction: 0.85,
          enableInfiniteScroll: competitions.length > 1,
          enlargeCenterPage: true,
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
                child: _buildImagePlaceholder(competition),
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
                    style: const TextStyle(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: competition.competitionStatusColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      competition.competitionStatus,
                      style: const TextStyle(
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                    message: competition.name,
                    child: Text(
                      competition.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    competition.location ?? 'Unknown location',
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
            padding: const EdgeInsets.all(12),
            child: OutlinedButton(
              onPressed: () =>
                  controller.navigateToCompetitionDetails(competition),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0275FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(100, 36),
              ),
              child: Text(
                'see'.tr,
                style: const TextStyle(
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

  Widget _buildImagePlaceholder(CompetitionModel competition) {
    if (competition.organizerClub.hasLogo) {
      return Container(
        width: double.infinity,
        height: 60,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            competition.organizerClub.logoUrl!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon if image fails to load
              return Container(
                height: 100,
                color: const Color(0xFFE1E8F0),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 100,
                color: const Color(0xFFE1E8F0),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // Display default icon when logoUrl is null or empty
      return Container(
        height: 100,
        color: const Color(0xFFE1E8F0),
        child: const Center(
          child: Icon(
            Icons.image,
            color: Colors.white,
            size: 40,
          ),
        ),
      );
    }

    // return Container(
    //   height: 100,
    //   color: const Color(0xFFE1E8F0),
    //   child: const Center(
    //     child: Icon(
    //       Icons.image,
    //       color: Colors.white,
    //       size: 40,
    //     ),
    //   ),
    // );
  }

  Widget _buildCompetitionsList() {
    return Obx(() {
      final displayedCompetitions = controller.displayedListCompetitions;
      final allListCompetitions = controller.listCompetitions;

      if (allListCompetitions.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(
            child: Text('no_other_competitions'.tr),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'other_competitions'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...displayedCompetitions
              .map((competition) => _buildCompetitionListItem(competition)),
          if (controller.hasMoreToLoad)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: OutlinedButton(
                  onPressed: controller.loadMore,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0275FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size(140, 40),
                  ),
                  child: Text(
                    'see_more'.tr,
                    style: const TextStyle(
                      color: Color(0xFF0275FF),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildCompetitionListItem(CompetitionModel competition) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.navigateToCompetitionDetails(competition),
        borderRadius: BorderRadius.circular(5),
        child: Row(
          children: [
            // Date container
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    competition.formattedBeginDateMonth,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    competition.formattedDayBeginDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Competition details
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      competition.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      competition.location ?? 'no_location'.tr,
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
            // Status and chevron
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: competition.entryStatusColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      competition.entryStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
