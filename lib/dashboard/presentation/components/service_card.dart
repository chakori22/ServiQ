import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_markerplace/app_color.dart';
import 'package:local_markerplace/dashboard/bloc/dashboard_bloc.dart';
import 'package:local_markerplace/dashboard/model/services.dart';

class ServiceCard extends StatelessWidget {
  final ServiceDetails serviceDetails;
  final int index;
  const ServiceCard({
    super.key,
    required this.serviceDetails,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Replace with your service image
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.neutralGreyColor50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  height: 120,

                  child: Center(
                    child: SvgPicture.asset(
                      serviceDetails.imageUrl,
                      width: 88,
                      height: 88,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: serviceDetails.isSelected
                      ? GestureDetector(
                          onTap: () {
                            context.read<DashboardBloc>().add(
                              OnToggleServiceSelection(index),
                            );
                          },
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 24,
                            color: AppColor.indicativeBlueColor300,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            context.read<DashboardBloc>().add(
                              OnToggleServiceSelection(index),
                            );
                          },
                          child: Icon(
                            Icons.add_circle_outline_sharp,
                            size: 24,
                            color: AppColor.indicativeBlueColor300,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Replace with your service title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceDetails.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColor.neutralGreyColor500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Replace with your service price
                        Text(
                          '₹${serviceDetails.price}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColor.neutralGreyColor700,
                          ),
                        ),
                      ],
                    ),
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
