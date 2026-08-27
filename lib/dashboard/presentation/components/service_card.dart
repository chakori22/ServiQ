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
                  serviceDetails.isSelected
                      ? _CountStepper(
                          serviceDetails: serviceDetails,
                          index: index,
                        )
                      : IconButton(
                          onPressed: () {
                            context.read<DashboardBloc>().add(
                              OnToggleServiceSelection(index),
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle_outline_sharp,
                            size: 32,
                            color: AppColor.indicativeBlueColor400,
                          ),
                        ),
                ],
              ),
            ),
            // const SizedBox(height: 4),
            // // Replace with your service price
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 12),
            //   child: Text(
            //     '₹${serviceDetails.price}',
            //     style: const TextStyle(
            //       fontSize: 12,
            //       fontWeight: FontWeight.w800,
            //       color: AppColor.neutralGreyColor700,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CountStepper extends StatelessWidget {
  final ServiceDetails serviceDetails;
  final int index;

  const _CountStepper({required this.serviceDetails, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.neutralGreyColor300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperIconButton(
            icon: Icons.remove,
            onTap: () {
              context.read<DashboardBloc>().add(
                OnChangeServiceCount(
                  index,
                  serviceDetails.count - ServiceDetails.countStep,
                ),
              );
            },
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${serviceDetails.count}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColor.neutralGreyColor700,
              ),
            ),
          ),
          _StepperIconButton(
            icon: Icons.add,
            onTap: () {
              context.read<DashboardBloc>().add(
                OnChangeServiceCount(
                  index,
                  serviceDetails.count + ServiceDetails.countStep,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: Colors.green),
      ),
    );
  }
}
