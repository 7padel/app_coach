class CoachProfileModel {
  final String coachId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? gender;
  final String? dateOfBirth;
  final int? experienceYears;
  final String? specializationLevel;
  final String? bio;
  final String approvalStatus;
  final String registrationStatus;
  final bool isActive;
  final double? averageRating;
  final int totalReviews;
  final String? profilePictureId;

  CoachProfileModel({
    required this.coachId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.experienceYears,
    this.specializationLevel,
    this.bio,
    required this.approvalStatus,
    required this.registrationStatus,
    required this.isActive,
    this.averageRating,
    required this.totalReviews,
    this.profilePictureId,
  });

  factory CoachProfileModel.fromJson(Map<String, dynamic> json) =>
      CoachProfileModel(
        coachId: json['coach_id'] ?? '',
        fullName: json['full_name'] ?? '',
        phoneNumber: json['phone_number'] ?? '',
        email: json['email'],
        gender: json['gender'],
        dateOfBirth: json['date_of_birth'],
        experienceYears: json['experience_years'],
        specializationLevel: json['specialization_level'],
        bio: json['bio'],
        approvalStatus: json['approval_status'] ?? 'pending',
        registrationStatus: json['registration_status'] ?? 'pending',
        isActive: json['is_active'] ?? false,
        averageRating: json['average_rating'] != null
            ? double.tryParse(json['average_rating'].toString())
            : null,
        totalReviews: json['total_reviews'] ?? 0,
        profilePictureId: json['profile_picture_id'],
      );
}
