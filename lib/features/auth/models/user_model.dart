class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phone;
  final String accountId;
  final List<AccountModel> accounts;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phone,
    required this.accountId,
    required this.accounts,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {List<AccountModel>? accountsList}) {
    final accs = accountsList ??
        (json['accounts'] as List<dynamic>?)
            ?.map((item) => AccountModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final rawAccId = json['account_id']?.toString();
    final defaultAccId = (rawAccId != null && rawAccId.isNotEmpty)
        ? rawAccId
        : (accs.isNotEmpty ? accs.first.id : '');

    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ??
          '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      accountId: defaultAccId,
      accounts: accs,
    );
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phone,
    String? accountId,
    List<AccountModel>? accounts,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      accountId: accountId ?? this.accountId,
      accounts: accounts ?? this.accounts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'account_id': accountId,
      'accounts': accounts.map((a) => a.toJson()).toList(),
    };
  }
}

class AccountModel {
  final String id;
  final String name;
  final String? companyName;
  final String? logo;
  final String? eftCode;
  final String? accountCode;

  AccountModel({
    required this.id,
    required this.name,
    this.companyName,
    this.logo,
    this.eftCode,
    this.accountCode,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? json['name']?.toString(),
      logo: json['logo']?.toString(),
      eftCode: json['eft_code']?.toString(),
      accountCode: json['account_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'logo': logo,
      'eft_code': eftCode,
      'account_code': accountCode,
    };
  }
}
