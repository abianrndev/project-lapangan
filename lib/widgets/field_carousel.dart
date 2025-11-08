import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/field.dart';

class FieldCarousel extends StatefulWidget {
  final List<Field> fields;
  final Function(Field) onFieldSelected;

  const FieldCarousel({
    Key? key,
    required this.fields,
    required this.onFieldSelected,
  }) : super(key: key);

  @override
  State<FieldCarousel> createState() => _FieldCarouselState();
}

class _FieldCarouselState extends State<FieldCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
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
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.fields.length,
            itemBuilder: (context, index) {
              final field = widget.fields[index];
              return GestureDetector(
                onTap: () => widget.onFieldSelected(field),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(field.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.name,
                            style: AppTextStyles.headerMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Rp ${field.price.toStringAsFixed(0)}/jam',
                            style: AppTextStyles.bodyText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.fields.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(
                  _currentPage == entry.key ? 0.9 : 0.4,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
