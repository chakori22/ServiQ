import 'package:flutter/material.dart';
import 'package:local_markerplace/app_color.dart';

class ServiceOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ServiceOptionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        //height: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.neutralGreyColor200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Title
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.neutralGreyColor700,
                ),
              ),
            ),

            // Icon
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                icon,
                size: 34,
                color: AppColor.indicativeBlueColor500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
