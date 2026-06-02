/// Clinic model.
class Clinic {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? url;
  final Map<String, dynamic>? map;
  final List<dynamic>? images;
  final List<dynamic>? medias;
  final bool isActive;

  Clinic({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.url,
    this.map,
    this.images,
    this.medias,
    this.isActive = true,
  });

  factory Clinic.fromMap(Map<String, dynamic> m) => Clinic(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        phone: m['phone'] as String?,
        address: m['address'] as String?,
        url: m['url'] as String?,
        map: m['map'] as Map<String, dynamic>?,
        images: m['images'] as List<dynamic>?,
        medias: m['medias'] as List<dynamic>?,
        isActive: m['is_active'] as bool? ?? true,
      );
}

/// Banner model.
class BannerItem {
  final String id;
  final String? title;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;

  BannerItem({
    required this.id,
    this.title,
    required this.imageUrl,
    this.linkUrl,
    this.isActive = true,
  });

  factory BannerItem.fromMap(Map<String, dynamic> m) => BannerItem(
        id: m['id'] as String,
        title: m['title'] as String?,
        imageUrl: m['image_url'] as String? ?? '',
        linkUrl: m['link_url'] as String?,
        isActive: m['is_active'] as bool? ?? true,
      );
}

/// Notification model.
class NotificationItem {
  final String id;
  final String title;
  final String? body;
  final String? type;
  final String priority;
  final bool isRead;
  final String? createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    this.body,
    this.type,
    this.priority = 'normal',
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> m) => NotificationItem(
        id: m['id'] as String,
        title: m['title'] as String? ?? '',
        body: m['body'] as String?,
        type: m['type'] as String?,
        priority: m['priority'] as String? ?? 'normal',
        isRead: m['is_read'] as bool? ?? false,
        createdAt: m['created_at'] as String?,
      );
}

/// Location model.
class LocationItem {
  final String id;
  final String? country;
  final String? city;
  final String? region;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<dynamic>? images;

  LocationItem({
    required this.id,
    this.country,
    this.city,
    this.region,
    this.address,
    this.latitude,
    this.longitude,
    this.images,
  });

  factory LocationItem.fromMap(Map<String, dynamic> m) => LocationItem(
        id: m['id'] as String,
        country: m['country'] as String?,
        city: m['city'] as String?,
        region: m['region'] as String?,
        address: m['address'] as String?,
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        images: m['images'] as List<dynamic>?,
      );

  String get displayAddress {
    final parts = [address, city, region, country].where((e) => e != null && e.isNotEmpty);
    return parts.join(', ');
  }
}

/// Work / treatment model.
class WorkItem {
  final String id;
  final String title;
  final String? workType;
  final String? note;
  final String? startDate;
  final String? deliveryDate;

  WorkItem({
    required this.id,
    required this.title,
    this.workType,
    this.note,
    this.startDate,
    this.deliveryDate,
  });

  factory WorkItem.fromMap(Map<String, dynamic> m) => WorkItem(
        id: m['id'] as String,
        title: m['title'] as String? ?? '',
        workType: m['work_type'] as String?,
        note: m['note'] as String?,
        startDate: m['start_date'] as String?,
        deliveryDate: m['delivery_date'] as String?,
      );
}

/// Clinic settings model.
class ClinicSettings {
  final String? clinicName;
  final String? logoUrl;
  final String? phone1;
  final String? phone2;
  final String? address;
  final String currency;
  final String language;
  final String theme;

  ClinicSettings({
    this.clinicName,
    this.logoUrl,
    this.phone1,
    this.phone2,
    this.address,
    this.currency = 'USD',
    this.language = 'en',
    this.theme = 'light',
  });

  factory ClinicSettings.fromMap(Map<String, dynamic> m) => ClinicSettings(
        clinicName: m['clinic_name'] as String?,
        logoUrl: m['logo_url'] as String?,
        phone1: m['phone_1'] as String?,
        phone2: m['phone_2'] as String?,
        address: m['address'] as String?,
        currency: m['currency'] as String? ?? 'USD',
        language: m['language'] as String? ?? 'en',
        theme: m['theme'] as String? ?? 'light',
      );
}