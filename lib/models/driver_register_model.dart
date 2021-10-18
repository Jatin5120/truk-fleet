import 'package:cloud_firestore/cloud_firestore.dart';

class DriverRegisterModel {
  String id;
  String agent;
  String mobile;
  String adhaar;
  String pan;
  String dl;
  String name;
  bool cstatus;
  String licenseExpiryDate;
  bool isAvailable;
  DriverRegisterModel({
    this.agent,
    this.mobile,
    this.adhaar,
    this.pan,
    this.dl,
    this.name,
    this.licenseExpiryDate,
    this.id,
    this.cstatus,
  this.isAvailable,
  });

  DriverRegisterModel copyWith({
    String agent,
    String mobile,
    String adhaar,
    String pan,
    String dl,
    String name,
    String licenseExpiryDate,
    bool cstatus,
    bool isAvailable
  }) {
    return DriverRegisterModel(
      agent: agent ?? this.agent,
      mobile: mobile ?? this.mobile,
      adhaar: adhaar ?? this.adhaar,
      pan: pan ?? this.pan,
      dl: dl ?? this.dl,
      name: name ?? this.name,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      cstatus: cstatus ?? this.cstatus,
        isAvailable : isAvailable ?? this.isAvailable
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 'id',
      'agent': agent,
      'mobile': mobile,
      'adhaar': adhaar,
      'pan': pan,
      'dl': dl,
      'name': name,
      'licenseExpiryDate': licenseExpiryDate,
      'cstatus': cstatus,
      'isAvailable':isAvailable
    };
  }

  factory DriverRegisterModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return DriverRegisterModel(
      id: map['id'],
      agent: map['agent'],
      mobile: map['mobile'],
      adhaar: map['adhaar'],
      pan: map['pan'],
      dl: map['dl'],
      name: map['name'],
      licenseExpiryDate: map['licenseExpiryDate'],
      cstatus: map['cstatus'],
        isAvailable: map['isAvailable']
    );
  }

  factory DriverRegisterModel.fromSnapshot(QueryDocumentSnapshot map) {
    if (map == null) return null;

    return DriverRegisterModel(
      id: map.id,
      agent: map.get('agent'),
      mobile: map.get('mobile'),
      adhaar: map.get('adhaar'),
      pan: map.get('pan'),
      dl: map.get('dl'),
      name: map.get('name'),
      licenseExpiryDate: map.get('licenseExpiryDate'),
      cstatus: map.get('cstatus'),
        isAvailable:map.get('isAvailable')
    );
  }
}
