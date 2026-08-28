import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_markerplace/app_color.dart';
import 'package:local_markerplace/dashboard/bloc/dashboard_bloc.dart';

class CartSummaryBar extends StatelessWidget {
  final DashboardState state;

  const CartSummaryBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final firstSelected = state.selectedServices.first;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        height: 60,
        decoration: BoxDecoration(
          color: AppColor.indicativeBlueColor100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 40,
                height: 40,
                color: AppColor.white,
                child: Center(
                  child: SvgPicture.asset(
                    firstSelected.imageUrl,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${state.selectedServicesCount} ${state.selectedServicesCount > 1 ? 'services' : 'service'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColor.neutralGreyColor700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    state.selectedServicesSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.neutralGreyColor500,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              // TODO: navigate to the cart page once it exists.
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.indicativeBlueColor400,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Go to cart',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
