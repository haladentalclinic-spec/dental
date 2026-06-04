import 'package:intl/intl.dart';

// ═══════════════════════════════════════════════
// Domain models matching the haladentsupabase.sql schema
// ═══════════════════════════════════════════════

/// Clinic model — matches `clinics` table.
class Clinic {
  final String id;
  final String name;
  final String? ownerId;
  final String? phone;
  final String? address;
  final String? url;
  final Map<String, dynamic>? map;
  final List<dynamic>? images;
  final List<dynamic>? medias;
  final bool isActive;
  final DateTime? createdAt;

  Clinic({
    required this.id,
    required this.name,
    this.ownerId,
    this.phone,
    this.address,
    this.url,
    this.map,
    this.images,
    this.medias,
    this.isActive = true,
    this.createdAt,
  });

  factory Clinic.fromMap(Map<String, dynamic> m) => Clinic(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        ownerId: m['owner_id'] as String?,
        phone: m['phone'] as String?,
        address: m['address'] as String?,
        url: m['url'] as String?,
        map: m['map'] as Map<String, dynamic>?,
        images: m['images'] as List<dynamic>?,
        medias: m['medias'] as List<dynamic>?,
        isActive: m['is_active'] as bool? ?? true,
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'] as String) : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'owner_id': ownerId,
        'phone': phone,
        'address': address,
        'url': url,
        'map': map,
        'images': images,
        'medias': medias,
        'is_active': isActive,
      };
}

/// User model — matches `users` table.
class User {
  final String id;
  final String? clinicId;
  final String? ref;
  final String? username;
  final String fullName;
  final String? phone;
  final String? passwordHash;
  final String role;
  final String? image;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? patientCode;
  final String? whatsapp;
  final String? gender;
  final int? age;
  final DateTime? birthDate;
  final String? address;
  final String? disease;
  final String? allergies;
  final String? bloodType;
  final String? note;
  final String? referenceName;
  final String? createdBy;

  User({
    required this.id,
    this.clinicId,
    this.ref,
    this.username,
    required this.fullName,
    this.phone,
    this.passwordHash,
    this.role = 'patient',
    this.image,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.patientCode,
    this.whatsapp,
    this.gender,
    this.age,
    this.birthDate,
    this.address,
    this.disease,
    this.allergies,
    this.bloodType,
    this.note,
    this.referenceName,
    this.createdBy,
  });

  factory User.fromMap(Map<String, dynamic> m) => User(
        id: m['id'] as String,
        clinicId: m['clinic_id'] as String?,
        ref: m['ref'] as String?,
        username: m['username'] as String?,
        fullName: m['full_name'] as String? ?? '',
        phone: m['phone'] as String?,
        passwordHash: m['password_hash'] as String?,
        role: m['role'] as String? ?? 'patient',
        image: m['image'] as String?,
        isActive: m['is_active'] as bool? ?? true,
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'] as String) : null,
        updatedAt: m['updated_at'] != null ? DateTime.tryParse(m['updated_at'] as String) : null,
        patientCode: m['patient_code'] as String?,
        whatsapp: m['whatsapp'] as String?,
        gender: m['gender'] as String?,
        age: m['age'] as int?,
        birthDate: m['birth_date'] != null ? DateTime.tryParse(m['birth_date'] as String) : null,
        address: m['address'] as String?,
        disease: m['disease'] as String?,
        allergies: m['allergies'] as String?,
        bloodType: m['blood_type'] as String?,
        note: m['note'] as String?,
        referenceName: m['reference_name'] as String?,
        createdBy: m['created_by'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'clinic_id': clinicId,
        'ref': ref,
        'username': username,
        'full_name': fullName,
        'phone': phone,
        'password_hash': passwordHash,
        'role': role,
        'image': image,
        'is_active': isActive,
        'patient_code': patientCode,
        'whatsapp': whatsapp,
        'gender': gender,
        'age': age,
        'birth_date': birthDate?.toIso8601String().split('T').first,
        'address': address,
        'disease': disease,
        'allergies': allergies,
        'blood_type': bloodType,
        'note': note,
        'reference_name': referenceName,
        'created_by': createdBy,
      };

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';
  bool get isAdmin => role == 'admin';
  bool get isStaff => role == 'staff';

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get ageOrEmpty => age != null ? '$age yrs' : '';
}

/// Work (dental treatment) model — matches `works` table.
class Work {
  final String id;
  final String? clinicId;
  final String? patientId;
  final String? doctorId;
  final String? labId;
  final String title;
  final String? workType;
  final List<dynamic>? teeth;
  final String? teethColor;
  final String? note;
  final DateTime? startDate;
  final DateTime? deliveryDate;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined fields (populated via Supabase joins)
  final String? doctorName;
  final String? doctorImage;
  final String? patientName;
  final String? patientImage;

  Work({
    required this.id,
    this.clinicId,
    this.patientId,
    this.doctorId,
    this.labId,
    required this.title,
    this.workType,
    this.teeth,
    this.teethColor,
    this.note,
    this.startDate,
    this.deliveryDate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.doctorName,
    this.doctorImage,
    this.patientName,
    this.patientImage,
  });

  factory Work.fromMap(Map<String, dynamic> m) => Work(
        id: m['id'] as String,
        clinicId: m['clinic_id'] as String?,
        patientId: m['patient_id'] as String?,
        doctorId: m['doctor_id'] as String?,
        labId: m['lab_id'] as String?,
        title: m['title'] as String? ?? '',
        workType: m['work_type'] as String?,
        teeth: m['teeth'] as List<dynamic>?,
        teethColor: m['teeth_color'] as String?,
        note: m['note'] as String?,
        startDate: m['start_date'] != null ? DateTime.tryParse(m['start_date'] as String) : null,
        deliveryDate: m['delivery_date'] != null ? DateTime.tryParse(m['delivery_date'] as String) : null,
        createdBy: m['created_by'] as String?,
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'] as String) : null,
        updatedAt: m['updated_at'] != null ? DateTime.tryParse(m['updated_at'] as String) : null,
        doctorName: m['doctor_name'] as String?,
        doctorImage: m['doctor_image'] as String?,
        patientName: m['patient_name'] as String?,
        patientImage: m['patient_image'] as String?,
      );

  String get teethDisplay {
    if (teeth == null || teeth!.isEmpty) return '';
    return (teeth!).map((t) => t.toString()).join(', ');
  }

  String get formattedStartDate =>
      startDate != null ? DateFormat('MMM dd, yyyy').format(startDate!) : '';

  String get formattedDeliveryDate =>
      deliveryDate != null ? DateFormat('MMM dd, yyyy').format(deliveryDate!) : '';
}

/// Notification model — matches `notifications` table.
class NotificationItem {
  final String id;
  final String? clinicId;
  final String? userId;
  final String? userPhone;
  final String title;
  final String? body;
  final String? type;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? scheduledAt;
  final String priority;

  NotificationItem({
    required this.id,
    this.clinicId,
    this.userId,
    this.userPhone,
    required this.title,
    this.body,
    this.type,
    this.isRead = false,
    this.createdAt,
    this.scheduledAt,
    this.priority = 'normal',
  });

  factory NotificationItem.fromMap(Map<String, dynamic> m) => NotificationItem(
        id: m['id'] as String,
        clinicId: m['clinic_id'] as String?,
        userId: m['user_id'] as String?,
        userPhone: m['user_phone'] as String?,
        title: m['title'] as String? ?? '',
        body: m['body'] as String?,
        type: m['type'] as String?,
        isRead: m['is_read'] as bool? ?? false,
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'] as String) : null,
        scheduledAt: m['scheduled_at'] != null ? DateTime.tryParse(m['scheduled_at'] as String) : null,
        priority: m['priority'] as String? ?? 'normal',
      );

  bool get isHigh => priority == 'high' || priority == 'urgent';
  String get formattedDate =>
      createdAt != null ? DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt!) : '';
}

/// Message model — matches `messages` table.
class Message {
  final String id;
  final String? clinicId;
  final String? senderId;
  final String? receiverId;
  final String? senderPhone;
  final String message;
  final String messageType;
  final bool isSeen;
  final DateTime? createdAt;

  // Joined
  final String? senderName;
  final String? senderImage;

  Message({
    required this.id,
    this.clinicId,
    this.senderId,
    this.receiverId,
    this.senderPhone,
    required this.message,
    this.messageType = 'text',
    this.isSeen = false,
    this.createdAt,
    this.senderName,
    this.senderImage,
  });

  factory Message.fromMap(Map<String, dynamic> m) => Message(
        id: m['id'] as String,
        clinicId: m['clinic_id'] as String?,
        senderId: m['sender_id'] as String?,
        receiverId: m['receiver_id'] as String?,
        senderPhone: m['sender_phone'] as String?,
        message: m['message'] as String? ?? '',
        messageType: m['message_type'] as String? ?? 'text',
        isSeen: m['is_seen'] as bool? ?? false,
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'] as String) : null,
        senderName: m['sender_name'] as String?,
        senderImage: m['sender_image'] as String?,
      );

  String get formattedTime =>
      createdAt != null ? DateFormat('hh:mm a').format(createdAt!) : '';
}

/// Banner model — matches `banners` table.
class BannerItem {
  final String id;
  final String? clinicId;
  final String? title;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  BannerItem({
    required this.id,
    this.clinicId,
    this.title,
    required this.imageUrl,
    this.linkUrl,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  factory BannerItem.fromMap(Map<String, dynamic> m) => BannerItem(
        id: m['id'] as String,
        clinicId: m['clinic_id'] as String?,
        title: m['title'] as String?,
        imageUrl: m['image_url'] as String? ?? '',
        linkUrl: m['link_url'] as String?,
        isActive: m['is_active'] as bool? ?? true,
        startDate: m['start_date'] != null ? DateTime.tryParse(m['start_date'] as String) : null,
        endDate: m['end_date'] != null ? DateTime.tryParse(m['end_date'] as String) : null,
      );
}

/// Location model — matches `locations` table.
class LocationItem {
  final String id;
  final String? clinicId;
  final String? country;
  final String? city;
  final String? region;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<dynamic>? medias;
  final List<dynamic>? images;

  LocationItem({
    required this.id,
    this.clinicId,
    this.country,
    this.city,
    this.region,
    this.address,
    this.latitude,
    this.longitude,
    this.medias,
    this.images,
  });

  factory LocationItem.fromMap(Map<String, dynamic> m) => LocationItem(
        id: m['id'] as String,
        clinicId: m['clinic_id'] as String?,
        country: m['country'] as String?,
        city: m['city'] as String?,
        region: m['region'] as String?,
        address: m['address'] as String?,
        latitude: (m['latitude'] as num?)?.toDouble(),
        longitude: (m['longitude'] as num?)?.toDouble(),
        medias: m['medias'] as List<dynamic>?,
        images: m['images'] as List<dynamic>?,
      );

  String get displayAddress {
    final parts = [address, city, region, country].where((e) => e != null && e.isNotEmpty);
    return parts.join(', ');
  }
}

/// Settings model — matches `settings` table.
class ClinicSettings {
  final String? clinicName;
  final String? logoUrl;
  final String? phone1;
  final String? phone2;
  final String? address;
  final String currency;
  final String language;
  final String? timezone;
  final String? siteUrl;
  final Map<String, dynamic>? socialLinks;
  final String theme;
  final bool maintenanceMode;
  final int? maxUsers;

  ClinicSettings({
    this.clinicName,
    this.logoUrl,
    this.phone1,
    this.phone2,
    this.address,
    this.currency = 'USD',
    this.language = 'en',
    this.timezone,
    this.siteUrl,
    this.socialLinks,
    this.theme = 'light',
    this.maintenanceMode = false,
    this.maxUsers,
  });

  factory ClinicSettings.fromMap(Map<String, dynamic> m) => ClinicSettings(
        clinicName: m['clinic_name'] as String?,
        logoUrl: m['logo_url'] as String?,
        phone1: m['phone_1'] as String?,
        phone2: m['phone_2'] as String?,
        address: m['address'] as String?,
        currency: m['currency'] as String? ?? 'USD',
        language: m['language'] as String? ?? 'en',
        timezone: m['timezone'] as String?,
        siteUrl: m['site_url'] as String?,
        socialLinks: m['social_links'] as Map<String, dynamic>?,
        theme: m['theme'] as String? ?? 'light',
        maintenanceMode: m['maintenance_mode'] as bool? ?? false,
        maxUsers: m['max_users'] as int?,
      );
}

/// Reminder model — matches `reminders` table.
class Reminder {
  final String id;
  final String? clinicId;
  final String? patientId;
  final String title;
  final DateTime reminderDate;
  final String status;
  final String? note;
  final DateTime? createdAt;

  Reminder({
    required this.id,
    this.clinicId,
    this.patientId,
    required this.title,
    required this.reminderDate,
    this.status = 'pending',
    this.note,
    this.createdAt,
  });

  factory Reminder.fromMap(Map<String, dynamic> m) => Reminder(
        id: m['id'] as String,
        clinicId: m['clinic_id'] as String?,
        patientId: m['patient_id'] as String?,
        title: m['title'] as String? ?? '',
        reminderDate: DateTime.parse(m['reminder_date'] as String),
        status: m['status'] as String? ?? 'pending',
        note: m['note'] as String?,
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'] as String) : null,
      );

  String get formattedDate => DateFormat('MMM dd, yyyy hh:mm a').format(reminderDate);
  bool get isPending => status == 'pending';
  bool get isDone => status == 'done';
}

/// ActivityLog model — matches `activity_logs` table.
class ActivityLog {
  final String id;
  final String? clinicId;
  final String? userId;
  final String action;
  final String? tableName;
  final String? recordId;
  final String? ipAddress;
  final DateTime? createdAt;

  ActivityLog({
    required this.id,
    this.clinicId,
    this.userId,
    required this.action,
    this.tableName,
    this.recordId,
    this.ipAddress,
    this.createdAt,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> m) => ActivityLog(
        id: m['id'] as String,
        clinicId: m['clinic_id'] as String?,
        userId: m['user_id'] as String?,
        action: m['action'] as String? ?? '',
        tableName: m['table_name'] as String?,
        recordId: m['record_id'] as String?,
        ipAddress: m['ip_address'] as String?,
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'] as String) : null,
      );
}

/// Media model — matches `media` table.
class MediaItem {
  final String id;
  final String? clinicId;
  final String? uploadedBy;
  final String? fileName;
  final String fileUrl;
  final String? fileType;
  final num? fileSize;
  final String? relatedTable;
  final String? relatedId;
  final DateTime? createdAt;

  MediaItem({
    required this.id,
    this.clinicId,
    this.uploadedBy,
    this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSize,
    this.relatedTable,
    this.relatedId,
    this.createdAt,
  });

  factory MediaItem.fromMap(Map<String, dynamic> m) => MediaItem(
        id: m['id'] as String,
        clinicId: m['clinic_id'] as String?,
        uploadedBy: m['uploaded_by'] as String?,
        fileName: m['file_name'] as String?,
        fileUrl: m['file_url'] as String? ?? '',
        fileType: m['file_type'] as String?,
        fileSize: m['file_size'] as num?,
        relatedTable: m['related_table'] as String?,
        relatedId: m['related_id'] as String?,
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'] as String) : null,
      );

  bool get isImage => fileType?.startsWith('image/') ?? false;
}
