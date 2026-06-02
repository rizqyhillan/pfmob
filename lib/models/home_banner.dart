import 'model_utils.dart';

class HomeBanner {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? linkUrl;
  final int sortOrder;

  const HomeBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.linkUrl,
    required this.sortOrder,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    final image = json['image_url'] ?? json['image'];

    return HomeBanner(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: resolveStorageUrl(image),
      linkUrl: json['link_url']?.toString(),
      sortOrder: int.tryParse((json['sort_order'] ?? 0).toString()) ?? 0,
    );
  }
}
