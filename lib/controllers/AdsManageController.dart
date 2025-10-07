import 'dart:convert';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';
import '../core/data/model/AdResponse.dart';
import '../core/data/model/AdvertiserProfile.dart';
import '../core/data/model/Area.dart' as area;
import '../core/data/model/AttributeEdits.dart';
import '../core/data/model/City.dart';
import '../core/data/model/category.dart';
import '../core/data/model/subcategory_level_one.dart';
import '../core/data/model/subcategory_level_two.dart';
import '../core/localization/changelanguage.dart';
import 'LoadingController.dart';
import 'areaController.dart';

class ManageAdController extends GetxController {

    var viewMode = 'vertical_simple'.obs;
  void changeViewMode(String mode) => viewMode.value = mode;
var currentAttributes = <Map<String, dynamic>>[].obs;
  String _baseUrl = "https://stayinme.arabiagroup.net/lar_stayInMe/public/api";
  RxInt currentImageIndex = 0.obs;
  // Main categories
  var categoriesList = <Category>[].obs;
  var isLoadingCategories = false.obs;
  var selectedMainCategory = Rxn<Category>();
  
  // Subcategories level one
  var subCategories = <SubcategoryLevelOne>[].obs;
  var isLoadingSubcategoryLevelOne = false.obs;
  var selectedSubcategoryLevelOne = Rxn<SubcategoryLevelOne>();
  
  // Subcategories level two
  var subCategoriesLevelTwo = <SubcategoryLevelTwo>[].obs;
  var isLoadingSubcategoryLevelTwo = false.obs;
  var selectedSubcategoryLevelTwo = Rxn<SubcategoryLevelTwo>();
  
  // Attributes
  var attributes = <AttributeEdit>[].obs;
  var isLoadingAttributes = false.obs;
  
  // المدن والمناطق
  var citiesList = <TheCity>[].obs;
  var isLoadingCities = false.obs;
  var selectedCity = Rxn<TheCity>();
  var selectedArea = Rxn<area.Area>();
  
  // بيانات الإعلان
  var titleArController = TextEditingController();
  var titleEnController = TextEditingController();
  var descriptionArController = TextEditingController();
  var descriptionEnController = TextEditingController();
  var priceController = TextEditingController();
  
  // الصور
  var loadingImages = false.obs;
  var uploadedImageUrls = "".obs;
  var images = <Uint8List>[].obs;
  
  // الموقع الجغرافي
  Rxn<double> latitude = Rxn<double>();
  Rxn<double> longitude = Rxn<double>();
  RxBool isLoadingLocation = false.obs;
  
  // حالة الإرسال
  var isSubmitting = false.obs;
  
  // قيم الخصائص الديناميكية
  var attributeValues = <int, dynamic>{}.obs;
  
  // تحكم المناطق
  final areaController = Get.put(AreaController());
  
  // المترجم
  final translator = GoogleTranslator();
  final translationCache = <String, String>{};
  
  // حالة الترجمة
  var isTranslating = false.obs;
  var translationProgress = 0.0.obs;
  var totalItemsToTranslate = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchCategories(Get.find<ChangeLanguageController>().currentLocale.value.languageCode);
    fetchCities('SY', Get.find<ChangeLanguageController>().currentLocale.value.languageCode);
  }

  // جلب التصنيفات الرئيسية
  Future<void> fetchCategories(String language) async {
    isLoadingCategories.value = true;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories/$language'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var fetchedCategories = (data['data'] as List)
            .map((category) => Category.fromJson(category))
            .toList();
        categoriesList.value = fetchedCategories;
      }
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      isLoadingCategories.value = false;
    }
  }
  
  void selectMainCategory(Category category) {
    selectedMainCategory.value = category;
    selectedSubcategoryLevelOne.value = null;
    selectedSubcategoryLevelTwo.value = null;
    subCategoriesLevelTwo.clear();
    fetchSubcategories(category.id, 'ar');
    fetchAttributes(category.id, 'ar');
  }
  
  // جلب التصنيفات الفرعية
Future<void> fetchSubcategories(int Theid, String language) async {
  subCategories.clear();
  isLoadingSubcategoryLevelOne.value = true;
  try {
    final response = await http.get(Uri.parse(
      '$_baseUrl/subcategories?category_id=$Theid&language=${Get.find<ChangeLanguageController>().currentLocale.value.languageCode}',
    ));

    if (response.statusCode == 200) {
      // 1) نحول الرد إلى خريطة
      final Map<String, dynamic> jsonMap = json.decode(response.body);

      // 2) نتأكد إنه success
      if (jsonMap['success'] == true) {
        // 3) نأخذ قائمة البيانات من المفتاح 'data'
        final List<dynamic> list = jsonMap['data'] as List<dynamic>;

        // 4) نحول كل عنصر في القائمة إلى موديل
        final fetchedSubCategories = list
            .map((e) => SubcategoryLevelOne.fromJson(e as Map<String, dynamic>))
            .toList();

        subCategories.value = fetchedSubCategories;
      } else {
        subCategories.clear();
      }
    } else {
      print('Error ${response.statusCode}');
    }
  } catch (e) {
    print('Exception fetchSubcategories: $e');
  } finally {
    isLoadingSubcategoryLevelOne.value = false;
  }
}
  
  void selectSubcategoryLevelOne(SubcategoryLevelOne subcategory) {
    selectedSubcategoryLevelOne.value = subcategory;
    selectedSubcategoryLevelTwo.value = null;
    fetchSubcategoriesLevelTwo(subcategory.id, Get.find<ChangeLanguageController>().currentLocale.value.languageCode);
  }
  
  // جلب التصنيفات الثانوية
 Future<void> fetchSubcategoriesLevelTwo(int Theid, String language) async {
  subCategoriesLevelTwo.clear();
  isLoadingSubcategoryLevelTwo.value = true;
  try {
    final response = await http.get(Uri.parse(
      '$_baseUrl/subcategories-level-two?sub_category_level_one_id=$Theid&language=${Get.find<ChangeLanguageController>().currentLocale.value.languageCode}',
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);

      if (jsonMap['success'] == true) {
        final List<dynamic> list = jsonMap['data'] as List<dynamic>;
        
        final fetchedSubCategories = list
            .map((e) => SubcategoryLevelTwo.fromJson(e as Map<String, dynamic>))
            .toList();

        subCategoriesLevelTwo.value = fetchedSubCategories;
      } else {
        subCategoriesLevelTwo.clear();
      }
    } else {
      print('Error ${response.statusCode}');
    }
  } catch (e) {
    print('Exception fetchSubcategoriesLevelTwo: $e');
  } finally {
    isLoadingSubcategoryLevelTwo.value = false;
  }
}

  
  void selectSubcategoryLevelTwo(SubcategoryLevelTwo subcategory) {
    selectedSubcategoryLevelTwo.value = subcategory;
  }
  
  // جلب الخصائص
  Future<void> fetchAttributes(int categoryId, String language) async {
    attributes.clear();
    isLoadingAttributes.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/categories/$categoryId/attributes?lang=$language');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map<String, dynamic> && data['success'] == true) {
          final List<dynamic> list = data['attributes'];
          final fetched = list
              .map((json) => AttributeEdit.fromJson(json as Map<String, dynamic>))
              .toList();
          attributes.value = fetched;
        }
      }
    } catch (e) {
      print("Error fetching attributes: $e");
    } finally {
      isLoadingAttributes.value = false;
    }
  }
  
  // اختيار الصور
 Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes(); // قراءة البيانات كـ bytes
        images.add(bytes);
      }
    }
  }
  
  void removeImage(int index) {
    images.removeAt(index);
  }
  
  Future<void> updateImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      images[index] = bytes;
    }
  }
  // 4. تعديل دالة رفع الصور - التعديل هنا فقط
  Future<void> uploadImagesToServer() async {
    try {
      loadingImages.value = true;
      List<String> uploadedUrls = [];

      if (images.isEmpty) {
        loadingImages.value = false;
        Get.snackbar("Error", "No images selected.");
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/upload"));

      for (var imageBytes in images) {
        request.files.add(http.MultipartFile.fromBytes(
          'images[]',
          imageBytes,
          filename: 'post_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        uploadedUrls = List<String>.from(jsonData['image_urls']);
        uploadedImageUrls.value = uploadedUrls.join(',');
      } else {
        Get.snackbar("Error", "Failed to upload images: ${response.statusCode}");
      }
    } catch (e) {
      print("Upload error: $e");
      loadingImages.value = false;
      Get.snackbar("Error", "Failed to upload images: ${e.toString()}");
    } finally {
      loadingImages.value = false;
    }
  }
  
  
  // إدارة الموقع الجغرافي
  Future<void> ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && 
          permission != LocationPermission.always) {
        Get.snackbar("خطأ", "يرجى منح إذن الوصول إلى الموقع الجغرافي");
      }
    }
  }
  
  Future<void> fetchCurrentLocation() async {
    try {
      isLoadingLocation.value = true;
      await ensureLocationPermission();
      
      if (!await Geolocator.isLocationServiceEnabled()) {
        Get.snackbar("خطأ", "يرجى تفعيل خدمة الموقع الجغرافي");
        return;
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(Duration(seconds: 10), onTimeout: () async {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium
        );
      });
      
      latitude.value = position.latitude;
      longitude.value = position.longitude;
    } catch (e) {
      Get.snackbar("خطأ", "تعذر الحصول على الموقع الجغرافي: $e");
    } finally {
      isLoadingLocation.value = false;
    }
  }
  
  void clearLocation() {
    latitude.value = null;
    longitude.value = null;
  }
  
  // جلب المدن
Future<void> fetchCities(String countryCode, String language) async {
  isLoadingCities.value = true;
  try {
    final url = '$_baseUrl/cities/$countryCode/$language';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);
      
      // الحالة 1: إذا كانت الاستجابة مباشرة قائمة من المدن
      if (decodedData is List) {
        final fetched = decodedData
          .map((jsonCity) {
            try {
              return TheCity.fromJson(jsonCity as Map<String, dynamic>);
            } catch (e) {
              print("Error parsing city: $e");
              return null;
            }
          })
          .where((city) => city != null)
          .cast<TheCity>()
          .toList();
          
        citiesList.value = fetched;
      }
      // الحالة 2: إذا كانت الاستجابة تحتوي على كائن به مفتاح "data"
      else if (decodedData is Map && decodedData.containsKey('data')) {
        final List<dynamic> listJson = decodedData['data'];
        
        final fetched = listJson
          .map((jsonCity) {
            try {
              return TheCity.fromJson(jsonCity as Map<String, dynamic>);
            } catch (e) {
              print("Error parsing city: $e");
              return null;
            }
          })
          .where((city) => city != null)
          .cast<TheCity>()
          .toList();
          
        citiesList.value = fetched;
      } else {
        print("Unknown response format: $decodedData");
      }
    } else {
      print("HTTP error ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    print("Error fetching cities: $e");
  } finally {
    isLoadingCities.value = false;
  }
}
  
  void selectCity(TheCity city) {
    selectedCity.value = city;
    selectedArea.value = null;
  }
  
  void selectArea(area.Area area) {
    selectedArea.value = area;
  }
  
  // التحقق مما إذا كان النص بالإنجليزية
  bool _isEnglish(String text) {
    if (text.isEmpty) return false;
    final englishRegex = RegExp(r'[a-zA-Z]');
    return englishRegex.hasMatch(text[0]);
  }
  
  // الترجمة التلقائية مع التخزين المؤقت وإعادة المحاولة
  Future<String> autoTranslate(String text, {int retries = 2}) async {
    try {
      // إذا كان النص فارغًا
      if (text.trim().isEmpty) return "";
      
      // التحقق من التخزين المؤقت
      if (translationCache.containsKey(text)) {
        return translationCache[text]!;
      }
      
      // إذا كان النص إنجليزيًا بالفعل
      if (_isEnglish(text)) {
        translationCache[text] = text;
        return text;
      }
      
      // إجراء الترجمة
      final translation = await translator.translate(text, from: 'ar', to: 'en');
      final translatedText = translation.text;
      
      // تخزين في ذاكرة التخزين المؤقت
      translationCache[text] = translatedText;
      
      return translatedText;
    } catch (e) {
      print("Translation error: $e");
      
      // إعادة المحاولة إذا كانت متاحة
      if (retries > 0) {
        await Future.delayed(Duration(seconds: 1));
        return autoTranslate(text, retries: retries - 1);
      }
      
      // في حالة فشل الترجمة، نرجع النص الأصلي
      return text;
    }
  }
  //

  
  ////
  // إعادة تعيين النموذج
  void resetForm() {
    titleArController.clear();
    titleEnController.clear();
    descriptionArController.clear();
    descriptionEnController.clear();
    priceController.clear();
    selectedMainCategory.value = null;
    selectedSubcategoryLevelOne.value = null;
    selectedSubcategoryLevelTwo.value = null;
    selectedCity.value = null;
    selectedArea.value = null;
    latitude.value = null;
    longitude.value = null;
    images.clear();
    uploadedImageUrls.value = "";
    attributeValues.clear();
    attributes.clear();
    subCategories.clear();
    subCategoriesLevelTwo.clear();
    translationCache.clear();
  }

  ////////....بيانات المعلن........../////
  var isProfilesLoading = false.obs;
  var advertiserProfiles = <AdvertiserProfile>[].obs;
  var selectedProfile = Rxn<AdvertiserProfile>();
RxInt idOfadvertiserProfiles = 0.obs;
  Future<void> fetchAdvertiserProfiles(int userId) async {
    isProfilesLoading(true);
    try {
      final res = await http.get(Uri.parse('https://stayinme.arabiagroup.net/lar_stayInMe/public/api/advertiser-profiles/$userId'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        advertiserProfiles.value = data.map((e) => AdvertiserProfile.fromJson(e)).toList();
      } else {
        Get.snackbar('خطأ', 'فشل جلب بيانات المعلن');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'تأكد من اتصال الانترنت');
    } finally {
      isProfilesLoading(false);
    }
  }

///////
  final LoadingController loadingC = Get.find<LoadingController>();


/////////تعديل..//
 /// تحديث إعلان موجود
Future<void> updateAd(int adId) async {
  try {
    isSubmitting.value = true;

    // 1) رفع الصور إذا تم تعديلها
    if (images.isNotEmpty) {
      await uploadImagesToServer();
      if (uploadedImageUrls.value.isEmpty) {
        throw Exception("فشل في رفع الصور");
      }
    }

    // 2) تجميع بيانات الخصائص كما في submitAd()
    List<Map<String, dynamic>> attributesData = [];
    for (var attribute in attributes) {
      if (attributeValues.containsKey(attribute.attributeId)) {
        final value = attributeValues[attribute.attributeId];
        if (attribute.type == 'options') {
          attributesData.add({
            "attribute_id": attribute.attributeId,
            "attribute_type": attribute.type,
            "attribute_option_id": value,
          });
        } else if (attribute.type == 'boolean') {
          final bool b = value as bool;
          attributesData.add({
            "attribute_id": attribute.attributeId,
            "attribute_type": attribute.type,
            "value_ar": b ? "نعم" : "لا",
            "value_en": b ? "Yes" : "No",
          });
        } else {
          attributesData.add({
            "attribute_id": attribute.attributeId,
            "attribute_type": attribute.type,
            "value_ar": value.toString(),
            "value_en": value.toString(),
          });
        }
      }
    }

    // 3) بناء جسم الطلب مع إرسال price كنص
    final adData = <String, dynamic>{
      "advertiser_profile_id": selectedProfile.value?.id,
      "category_id": selectedMainCategory.value?.id,
      "sub_category_level_one_id": selectedSubcategoryLevelOne.value?.id,
      "sub_category_level_two_id": selectedSubcategoryLevelTwo.value?.id,
      "city_id": selectedCity.value?.id,
      "area_id": selectedArea.value?.id,
      "title_ar": titleArController.text,
      "title_en": titleEnController.text,
      "description_ar": descriptionArController.text,
      "description_en": descriptionEnController.text,
      // ← هنا السعر كنص وليس رقم
      "price": priceController.text.trim().isNotEmpty
          ? priceController.text.trim()
          : null,
      "latitude": latitude.value,
      "longitude": longitude.value,
      if (uploadedImageUrls.value.isNotEmpty)
        "images": uploadedImageUrls.value.split(','),
      if (attributesData.isNotEmpty) "attributes": attributesData,
    };

    // 4) طباعة payload للـ debug
    debugPrint("➡️ updateAd payload (adId=$adId): ${json.encode(adData)}");

    // 5) الإرسال
    final uri = Uri.parse('$_baseUrl/ads/$adId');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(adData),
    );

    // 6) طباعة الاستجابة للـ debug
    debugPrint("⬅️ updateAd status: ${response.statusCode}");
    debugPrint("⬅️ updateAd body: ${response.body}");

    if (response.statusCode == 200) {
      Get.snackbar("نجاح", "تم تحديث الإعلان بنجاح");
    } else {
      final err = json.decode(response.body) as Map<String, dynamic>;
      String msg = err['message'] ?? "فشل في تحديث الإعلان";
      if (err['errors'] != null && err['errors'] is Map) {
        (err['errors'] as Map).forEach((k, v) {
          if (v is List) msg += "\n• ${v.join(', ')}";
        });
      }
      throw Exception(msg);
    }
  } catch (e) {
    Get.snackbar("خطأ", e.toString());
  } finally {
    isSubmitting.value = false;
  }
}


  ///
  // قائمة إعلانات المستخدم
var userAdsList = <Ad>[].obs;
RxBool isLoadingUserAds = false.obs;

/// جلب إعلانات المستخدم الخاصة به
Future<void> fetchUserAds({
  required int userId,
  String lang =    'ar',
  String status = 'published',
  int page = 1,
  int perPage = 15,
}) async {
  isLoadingUserAds.value = true;
  try {
    final queryParameters = {
      'user_id': userId.toString(),
      'lang':Get.find<ChangeLanguageController>().currentLocale.value.languageCode,
      'status': status,
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    final uri = Uri.parse('$_baseUrl/ads/user')
        .replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;

      // نفترض أن AdResponse.fromJson يتعامل مع حقل "data" ويحوله لقائمة Ad
      final adResponse = AdResponse.fromJson(jsonData);

      userAdsList.value = adResponse.data;
    } else {
      print('Error fetching user ads: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception fetching user ads: $e');
  } finally {
    isLoadingUserAds.value = false;
  }
}
//////

RxBool isDeletingAd = false.obs;
/// حذف إعلان حسب معرّف
Future<void> deleteAd(int adId) async {
  isDeletingAd.value = true;
  try {
    final uri = Uri.parse('$_baseUrl/ads/$adId');
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      Get.snackbar("نجاح", "تم حذف الإعلان بنجاح");
      // تحديث القائمة محليًا بإزالة الإعلان المحذوف
      userAdsList.removeWhere((ad) => ad.id == adId);
      userAdsList.removeWhere((ad) => ad.id == adId);
    } else {
      final err = json.decode(response.body);
      String msg = err['message'] ?? "فشل في حذف الإعلان";
      throw Exception(msg);
    }
  } catch (e) {
    Get.snackbar("خطأ", e.toString());
  } finally {
    isDeletingAd.value = false;
  }
}
// داخل ManageAdController
 Rx<Ad?> currentAd = Rx<Ad?>(null);
  RxBool isLoadingAd = false.obs;

  Future<void> fetchAdDetails(int adId) async {
  isLoadingAd.value = true;
  try {
    final response = await http.get(Uri.parse('$_baseUrl/ads/$adId'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['data'] != null) {
        currentAd.value = Ad.fromJson(jsonData['data']);
        await _populateFormFields();
      }
    }
  } finally {
    isLoadingAd.value = false;
  }
}
// في ManageAdController
Future<void> _populateFormFields() async {
  final ad = currentAd.value;
  if (ad == null) return;

  titleArController.text    = ad.title;
  descriptionArController.text = ad.description;
  priceController.text      = ad.price?.toString() ?? '';

  // تعبئة التصنيفات باستخدام الـ ID
  selectedMainCategory.value = 
      categoriesList.firstWhereOrNull((cat) => cat.id == ad.category.id);

  if (selectedMainCategory.value != null) {
    await fetchSubcategories(selectedMainCategory.value!.id, Get.find<ChangeLanguageController>().currentLocale.value.languageCode);

    selectedSubcategoryLevelOne.value = subCategories
        .firstWhereOrNull((sub) => sub.id == ad.subCategoryLevelOne.id);

    if (selectedSubcategoryLevelOne.value != null) {
      await fetchSubcategoriesLevelTwo(
        selectedSubcategoryLevelOne.value!.id,
        Get.find<ChangeLanguageController>().currentLocale.value.languageCode,
      );

      if (ad.subCategoryLevelTwo != null) {
        selectedSubcategoryLevelTwo.value = subCategoriesLevelTwo
            .firstWhereOrNull((sub) => sub.id == ad.subCategoryLevelTwo!.id);
      }
    }
  }

  // تعبئة المدن والمناطق
  selectedCity.value = 
      citiesList.firstWhereOrNull((city) => city.id == ad.city?.id);

  if (selectedCity.value != null) {
    await areaController.fetchAreasEdit(selectedCity.value!.id);
    selectedArea.value = areaController.areas
        .firstWhereOrNull((area) => area.id == ad.areaId);
  }

  // تعبئة الخصائص مع تحويل الأنواع
  for (var attr in ad.attributes) {
    final attribute = attributes
        .firstWhereOrNull((a) => a.label == attr.name);
    if (attribute == null) continue;

    dynamic value;
    switch (attribute.type) {
      case 'boolean':
        value = (attr.value == 'نعم' || attr.value == 'Yes');
        break;
      case 'number':
        value = double.tryParse(
          attr.value.replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        break;
      default:
        value = attr.value;
    }

    attributeValues[attribute.attributeId] = value;
  }
}

  // تعبئة الموقع الجغرافي
 

///

}