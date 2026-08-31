import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/dashboard/bloc/dashboard_bloc.dart';
import 'package:local_markerplace/dashboard/presentation/components/card_summary.dart';
import 'package:local_markerplace/dashboard/presentation/components/service_card.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    snap: false,
                    pinned: true,
                    floating: false,
                    elevation: 0,
                    expandedHeight: 240,
                    backgroundColor: AppColor.indicativeBlueColor50,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        color: AppColor.indicativeBlueColor700,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),

                    // This is what drives the fade-in: FlexibleSpaceBar's `title`
                    // automatically animates from 0 -> 1 opacity as the space
                    // collapses toward the pinned toolbar height. No manual
                    // scroll-offset tracking needed for this part.
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.all(16),
                      centerTitle: true,
                      background: SvgPicture.asset(
                        "assets/images/services.svg",
                      ),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Services',
                            style: TextStyle(
                              color: AppColor.indicativeBlueColor700,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      //background: _HeroBanner(),
                    ),
                  ),

                  // Stack(
                  //   children: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ServiceCard(
                          serviceDetails: state.serviceDetails[index],
                          index: index,
                          onTap: () {
                            context.read<DashboardBloc>().add(
                              OnToggleServiceSelection(index),
                            );
                          },
                          isLoading: state.servicesLoading,
                        ),
                        childCount: state.serviceDetails.length,
                      ),
                    ),
                  ),
                ],
              ),
              if (state.selectedServicesCount > 0)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: CartSummaryBar(state: state),
                ),
            ],
          );
        },
      ),
    );
  }
}
