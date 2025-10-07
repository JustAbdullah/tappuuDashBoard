import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tappuu_dashboard/core/data/model/AdvertiserProfile.dart';
import 'package:tappuu_dashboard/core/localization/changelanguage.dart';
import '../core/data/model/AdResponse.dart';import '../core/data/model/AttributeEdits.dart';
import '../core/data/model/City.dart';
import '../core/data/model/UserModel.dart' as UserModel;
import '../core/data/model/category.dart';
import '../core/data/model/subcategory_level_one.dart';
import '../core/data/model/subcategory_level_two.dart';
import '../core/data/model/Area.dart' as area;

class AdminAdsController extends GetxController {
  final String _baseUrl = 'https://stayinme.arabiagroup.net/lar_stayInMe/public/api';

  // ======== [متغيّرات الحالة] ========
  RxList<Ad> adminAdsList = <Ad>[].obs;
  RxBool isLoadingAdminAds = false.obs;
  RxList<Category> categoriesList = <Category>[].obs;
  RxBool isLoadingCategories = false.obs;
  RxList<SubcategoryLevelTwo> subCategoriesLevelTwoList = <SubcategoryLevelTwo>[].obs;
  RxList<SubcategoryLevelOne> parentSubCategoriesList = <SubcategoryLevelOne>[].obs;
  RxBool isLoadingSubCategoriesLevelTwo = false.obs;
  RxBool isLoadingParentSubCategories = false.obs;
  var selectedArea = Rxn<area.Area>();   

  // ======== [متغيّرات التعديل] ========
  RxBool isUpdatingAd = false.obs;
  Rx<Ad?> currentAdForEdit = Rx<Ad?>(null);
  RxList<Uint8List> editImages = <Uint8List>[].obs;
  RxList<String> editImageUrls = <String>[].obs;
  var citiesList = <TheCity>[].obs;
  var isLoadingCities = false.obs;

  // ======== [متغيّرات جديدة مأخوذة من ManageAdController] ========
  var isProfilesLoading = false.obs;
  var advertiserProfiles = <AdvertiserProfile>[].obs;
  var selectedProfile = Rxn<AdvertiserProfile>();
  var attributes = <AttributeEdit>[].obs;
  var isLoadingAttributes = false.obs;
  var attributeValues = <int, dynamic>{}.obs;
  var selectedMainCategory = Rxn<Category>();
  var selectedSubcategoryLevelOne = Rxn<SubcategoryLevelOne>();
  var selectedSubcategoryLevelTwo = Rxn<SubcategoryLevelTwo>();
  var selectedCity = Rxn<TheCity>();
  
  // متحكمات النصوص
  var titleArController = TextEditingController();
  var titleEnController = TextEditingController();
  var descriptionArController = TextEditingController();
  var descriptionEnController = TextEditingController();
  var priceController = TextEditingController();
  
  // الموقع الجغرافي
  Rxn<double> latitude = Rxn<double>();
  Rxn<double> longitude = Rxn<double>();
  RxBool isLoadingLocation = false.obs;

  RxList<UserModel.UserModel> users = <UserModel.UserModel>[].obs;
  RxBool isLoadingUsers = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories(Get.find<ChangeLanguageController>().currentLocale.value.languageCode);
    fetchCities('SY', Get.find<ChangeLanguageController>().currentLocale.value.languageCode);
  }

  // ======== [الدوال الحالية] ========
  Future<void> fetchUsersWithCounts() async {
    isLoadingUsers.value = true;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users-with-counts'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body['status'] == 'success') {
          final list = body['users'] as List<dynamic>;
          users.value = list.map((e) => UserModel.UserModel.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          print('API error: ${body['status']}');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetchUsersWithCounts: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> fetchCategories(String language) async {
    categoriesList.clear();
    isLoadingCategories.value = true;

    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories/$language'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          categoriesList.value = data
              .map((category) => Category.fromJson(category as Map<String, dynamic>))
              .toList();
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل جلب التصنيفات', true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب التصنيفات: $e', true);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchSubCategories({int? categoryId, required String language}) async {
    parentSubCategoriesList.clear();
    isLoadingParentSubCategories.value = true;

    final queryParams = <String, String>{
      'language': language,
      if (categoryId != null) 'category_id': categoryId.toString(),
    };

    final uri = Uri.parse('$_baseUrl/subcategories').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'] as List<dynamic>;
          parentSubCategoriesList.value = data
              .map((e) => SubcategoryLevelOne.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل جلب التصنيفات الفرعية', true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب التصنيفات الفرعية: $e', true);
    } finally {
      isLoadingParentSubCategories.value = false;
    }
  }

  Future<void> fetchSubCategoriesLevelTwo({int? parent1Id, required String language}) async {
    subCategoriesLevelTwoList.clear();
    isLoadingSubCategoriesLevelTwo.value = true;

    final queryParams = <String, String>{
      'language': language,
      if (parent1Id != null) 'sub_category_level_one_id': parent1Id.toString(),
    };

    final uri = Uri.parse('$_baseUrl/subcategories-level-two').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'] as List<dynamic>;
          subCategoriesLevelTwoList.value = data
              .map((e) => SubcategoryLevelTwo.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل جلب التصنيفات الفرعية الثانية', true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب التصنيفات الفرعية الثانية: $e', true);
    } finally {
      isLoadingSubCategoriesLevelTwo.value = false;
    }
  }

  Future<void> fetchAdminAds({
    required String lang,
    required String status,
    int page = 1,
    int perPage = 15,
    int? categoryId,
    int? subCategoryLevelOneId,
    int? subCategoryLevelTwoId,
    int? userId,
    String? searchCategory,
    String? searchTitle,
  }) async {
    adminAdsList.clear();
    isLoadingAdminAds.value = true;

    try {
      final queryParams = <String, String>{
        'lang': lang,
        'status': status,
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (subCategoryLevelOneId != null) 'sub_category_level_one_id': subCategoryLevelOneId.toString(),
        if (subCategoryLevelTwoId != null) 'sub_category_level_two_id': subCategoryLevelTwoId.toString(),
        if (userId != null) 'user_id': userId.toString(),
        if (searchCategory?.isNotEmpty ?? false) 'search_category': searchCategory!,
        if (searchTitle?.isNotEmpty ?? false) 'search_title': searchTitle!,
      };

      final uri = Uri.parse('$_baseUrl/ads/admin-list').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
          adminAdsList.value = data
              .map((item) => Ad.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل جلب الإعلانات', true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ в الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء جلب الإعلانات: $e', true);
    } finally {
      isLoadingAdminAds.value = false;
    }
  }

  Future<void> deleteAdminAd(int adId) async {
    isLoadingAdminAds.value = true;
    try {
      final uri = Uri.parse('$_baseUrl/ads/$adId');
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          fetchAdminAds(lang: "ar", status: 'published');
          _showSnackbar('نجاح', jsonResponse['message'] ?? 'تم حذف الإعلان بنجاح', false);
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل حذف الإعلان', true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء حذف الإعلان: $e', true);
    } finally {
      isLoadingAdminAds.value = false;
    }
  }

  void _showSnackbar(String title, String message, bool isError) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      colorText: Colors.white,
      borderRadius: 10,
      margin: EdgeInsets.all(15),
      duration: Duration(seconds: isError ? 4 : 3),
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
final RxBool _optimisticShowTime = false.obs;
  Future<void> togglePublish(int adId, String currentStatus,String massage) async {
    try {
      final uri = Uri.parse('$_baseUrl/ads/$adId/toggle-publish');
      final response = await http.patch(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('togglePublish status: ${response.statusCode}');
      debugPrint('togglePublish body: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>?; 
        final data = body?['data'] as Map<String, dynamic>?;

        if (data != null && data.containsKey('status')) {
          fetchAdminAds(
            lang: Get.find<ChangeLanguageController>().currentLocale.value.languageCode,
            status: currentStatus,
          );
          Get.snackbar('نجاح', 'تم تبديل حالة النشر إلى "$massage"');
        } else {
          Get.snackbar('خطأ', 'لم نستلم بيانات صالحة من السيرفر.');
        }
      } else {
        Get.snackbar('خطأ', 'فشل تبديل حالة النشر (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('togglePublish error: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء تبديل حالة النشر.');
    }
  }

  Future<void> togglePremium(int adId, String currentStatus) async {
    try {
      final uri = Uri.parse('$_baseUrl/ads/$adId/toggle-premium');
      final response = await http.patch(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('togglePremium status: ${response.statusCode}');
      debugPrint('togglePremium body: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>?; 
        final data = body?['data'] as Map<String, dynamic>?;

        if (data != null && data.containsKey('is_premium')) {
          final isPremium = data['is_premium'] as bool;
          fetchAdminAds(
            lang: Get.find<ChangeLanguageController>().currentLocale.value.languageCode,
            status: currentStatus,
          );
          Get.snackbar('نجاح', 'تم تبديل حالة البريميوم إلى ${isPremium ? "مفعل" : "غير مفعل"}');
        } else {
          Get.snackbar('خطأ', 'لم نستلم بيانات صالحة من السيرفر.');
        }
      } else {
        Get.snackbar('خطأ', 'فشل تبديل حالة البريميوم (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('togglePremium error: $e');
      Get.snackbar('خطأ', 'حدث خطأ أثناء تبديل حالة البريميوم.');
    }
  }

  // ======== [دوال جديدة مأخوذة من ManageAdController] ========
  Future<void> fetchAdvertiserProfiles(int userId) async {
    isProfilesLoading.value = true;
    try {
      final res = await http.get(Uri.parse('$_baseUrl/advertiser-profiles/$userId'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        advertiserProfiles.value = data.map((e) => AdvertiserProfile.fromJson(e)).toList();
      } else {
        Get.snackbar('خطأ', 'فشل جلب بيانات المعلن');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'تأكد من اتصال الانترنت');
    } finally {
      isProfilesLoading.value = false;
    }
  }

  Future<void> fetchAttributes(int categoryId, String language) async {
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

  void selectMainCategory(Category category) {
    selectedMainCategory.value = category;
    selectedSubcategoryLevelOne.value = null;
    selectedSubcategoryLevelTwo.value = null;
    subCategoriesLevelTwoList.clear();
    fetchSubCategories(categoryId: category.id, language: 'ar');
    fetchAttributes(category.id, 'ar');
  }

  void selectSubcategoryLevelOne(SubcategoryLevelOne subcategory) {
    selectedSubcategoryLevelOne.value = subcategory;
    selectedSubcategoryLevelTwo.value = null;
    fetchSubCategoriesLevelTwo(parent1Id: subcategory.id, language: 'ar');
  }

  void selectSubcategoryLevelTwo(SubcategoryLevelTwo subcategory) {
    selectedSubcategoryLevelTwo.value = subcategory;
  }

  void selectCity(TheCity city) {
    selectedCity.value = city;
    selectedArea.value = null;
  }

  void selectArea(area.Area? area) {
    selectedArea.value = area;
  }

  Future<void> pickEditImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes();
        editImages.add(bytes);
      }
    }
  }

  void removeEditImage(int index, bool isNewImage) {
    if (isNewImage) {
      editImages.removeAt(index);
    } else {
      editImageUrls.removeAt(index);
    }
  }

  Future<List<String>> uploadEditImages() async {
    if (editImages.isEmpty) return [];
    
    List<String> uploadedUrls = [];
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/upload"));
      
      for (var imageBytes in editImages) {
        request.files.add(http.MultipartFile.fromBytes(
          'images[]',
          imageBytes,
          filename: 'edit_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }
      
      var response = await request.send();
      if (response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        uploadedUrls = List<String>.from(jsonData['image_urls']);
      }
    } catch (e) {
      print("Upload error: $e");
    }
    
    return uploadedUrls;
  }

  // ======== [دوال التعديل المحدثة] ========
  Future<void> fetchAdDetailsForEdit(int adId) async {
    try {
      isLoadingAdminAds.value = true;
      final response = await http.get(Uri.parse('$_baseUrl/ads/$adId'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success') {
          if (jsonResponse.containsKey('data') && 
              jsonResponse['data'] != null && 
              jsonResponse['data'] is Map<String, dynamic>) {
            try {
              currentAdForEdit.value = Ad.fromJson(jsonResponse['data']);
              await _populateEditFormFields();
            } catch (e) {
              print('Error parsing ad data: $e');
              _showSnackbar('خطأ', 'فشل في تحليل بيانات الإعلان', true);
            }
          } else {
            _showSnackbar('خطأ', 'بيانات الإعلان غير صحيحة أو فارغة', true);
            print('Invalid data format: ${jsonResponse['data']}');
          }
        } else {
          final errorMessage = jsonResponse['message'] ?? 'فشل جلب تفاصيل الإعلان';
          _showSnackbar('خطأ', errorMessage, true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      print('Exception in fetchAdDetailsForEdit: $e');
      _showSnackbar('خطأ', 'حدث خطأ غير متوقع', true);
    } finally {
      isLoadingAdminAds.value = false;
    }
  }

  Future<void> _populateEditFormFields() async {
    final ad = currentAdForEdit.value;
    if (ad == null) return;

    // تعبئة الحقول النصية
    titleArController.text = ad.title;
    descriptionArController.text = ad.description;
    priceController.text = ad.price?.toString() ?? '';

    // حفظ روابط الصور
    editImageUrls.value = List<String>.from(ad.images);
    
    // جلب التصنيفات والمدن إذا لم تكن محملة
    if (categoriesList.isEmpty) {
      await fetchCategories(Get.find<ChangeLanguageController>().currentLocale.value.languageCode);
    }
    if (citiesList.isEmpty) {
      await fetchCities('SY', Get.find<ChangeLanguageController>().currentLocale.value.languageCode);
    }

    // جلب بيانات المعلن
    await fetchAdvertiserProfiles(ad.userId);

    // تحديد التصنيفات بناءً على بيانات الإعلان
    selectedMainCategory.value = categoriesList.firstWhereOrNull((cat) => cat.id == ad.category.id);
    
    if (selectedMainCategory.value != null) {
      await fetchSubCategories(categoryId: selectedMainCategory.value!.id, language: 'ar');
      selectedSubcategoryLevelOne.value = parentSubCategoriesList.firstWhereOrNull((sub) => sub.id == ad.subCategoryLevelOne.id);
      
      if (selectedSubcategoryLevelOne.value != null) {
        await fetchSubCategoriesLevelTwo(parent1Id: selectedSubcategoryLevelOne.value!.id, language: 'ar');
        selectedSubcategoryLevelTwo.value = subCategoriesLevelTwoList.firstWhereOrNull((sub) => sub.id == ad.subCategoryLevelTwo?.id);
      }
    }

    // تحديد المدينة والمنطقة
    selectedCity.value = citiesList.firstWhereOrNull((city) => city.id == ad.city?.id);
    if (selectedCity.value != null) {
      // جلب المناطق الخاصة بهذه المدينة
      // Note: ستحتاج إلى تنفيذ دالة fetchAreas في AreaController
    }

    // جلب الخصائص وتعيين قيمها
    if (selectedMainCategory.value != null) {
      await fetchAttributes(selectedMainCategory.value!.id, 'ar');
      
      // تعيين قيم الخصائص من بيانات الإعلان
for (var attr in ad.attributes) {
  final attribute = attributes.firstWhereOrNull((a) => a.attributeId == attr);
  if (attribute != null) {
    attributeValues[attribute.attributeId] = attr.value;
  }
}

      
    }
  }

  Future<void> fetchCities(String countryCode, String language) async {
    isLoadingCities.value = true;
    try {
      final url = '$_baseUrl/cities/$countryCode/$language';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        
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

  Future<void> updateAdminAd(int adId, Map<String, dynamic> updateData) async {
    isUpdatingAd.value = true;
    try {
      // رفع الصور الجديدة إذا وجدت
      final newImageUrls = await uploadEditImages();
      if (newImageUrls.isNotEmpty) {
        // دمج الصور القديمة والجديدة
        final allImageUrls = [...editImageUrls, ...newImageUrls];
        updateData['images'] = allImageUrls;
      }
      
      // إضافة البيانات الجديدة إلى updateData
      updateData.addAll({
        'advertiser_profile_id': selectedProfile.value?.id,
        'category_id': selectedMainCategory.value?.id,
        'sub_category_level_one_id': selectedSubcategoryLevelOne.value?.id,
        'sub_category_level_two_id': selectedSubcategoryLevelTwo.value?.id,
        'city_id': selectedCity.value?.id,
        'area_id': selectedArea.value?.id,
        'title_ar': titleArController.text,
        'description_ar': descriptionArController.text,
        'price': priceController.text.isNotEmpty ? priceController.text : null,
        'attributes': _prepareAttributesData(),
      });
      
      // إرسال طلب التعديل
      final uri = Uri.parse('$_baseUrl/ads/$adId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success') {
          _showSnackbar('نجاح', 'تم تحديث الإعلان بنجاح', false);
          
          // تحديث القائمة بعد التعديل
          final currentLang = Get.find<ChangeLanguageController>().currentLocale.value.languageCode;
          fetchAdminAds(lang: currentLang, status: 'published');
          
          // تنظيف البيانات
          resetEditForm();
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل تحديث الإعلان', true);
        }
      } else {
        _showSnackbar('خطأ', 'خطأ في الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء تحديث الإعلان: $e', true);
    } finally {
      isUpdatingAd.value = false;
    }
  }

  List<Map<String, dynamic>> _prepareAttributesData() {
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
          final boolValue = value as bool;
          attributesData.add({
            "attribute_id": attribute.attributeId,
            "attribute_type": attribute.type,
            "value_ar": boolValue ? "نعم" : "لا",
            "value_en": boolValue ? "Yes" : "No",
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
    return attributesData;
  }

  void resetEditForm() {
    currentAdForEdit.value = null;
    editImages.clear();
    editImageUrls.clear();
    selectedMainCategory.value = null;
    selectedSubcategoryLevelOne.value = null;
    selectedSubcategoryLevelTwo.value = null;
    selectedCity.value = null;
    selectedArea.value = null;
    selectedProfile.value = null;
    attributeValues.clear();
    attributes.clear();
    advertiserProfiles.clear();
    titleArController.clear();
    titleEnController.clear();
    descriptionArController.clear();
    descriptionEnController.clear();
    priceController.clear();
  }

  // دوال مساعدة للتحكم في الخصائص
  void setAttributeValue(int attributeId, dynamic value) {
    attributeValues[attributeId] = value;
  }

  dynamic getAttributeValue(int attributeId) {
    return attributeValues[attributeId];
  }

  /// تحديث حقول SEO (slug, meta_title, meta_description) لإعلان (Admin)
  Future<void> updateAdSeo(int adId, {String? slug, String? metaTitle, String? metaDescription}) async {
    isUpdatingAd.value = true;
    try {
      final Map<String, dynamic> body = {};
      if (slug != null) body['slug'] = slug;
      if (metaTitle != null) body['meta_title'] = metaTitle;
      if (metaDescription != null) body['meta_description'] = metaDescription;

      if (body.isEmpty) {
        _showSnackbar('خطأ', 'لم ترسل أي حقل للتحديث.', true);
        return;
      }

      final uri = Uri.parse('$_baseUrl/ads/$adId/seo');
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint('updateAdSeo status: ${response.statusCode}');
      debugPrint('updateAdSeo body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          _showSnackbar('نجاح', jsonResponse['message'] ?? 'تم تحديث SEO', false);

          // إعادة جلب تفاصيل الإعلان المحدثة لملء النموذج محليًا
          await fetchAdDetailsForEdit(adId);
        } else {
          _showSnackbar('خطأ', jsonResponse['message'] ?? 'فشل تحديث SEO', true);
        }
      } else {
        _showSnackbar('خطأ', 'فشل الاتصال بالسيرفر (${response.statusCode})', true);
      }
    } catch (e) {
      debugPrint('updateAdSeo error: $e');
      _showSnackbar('خطأ', 'حدث خطأ أثناء تحديث SEO: $e', true);
    } finally {
      isUpdatingAd.value = false;
    }
  }

  // ======== [دالة تبديل show_time العالمية] ========
RxBool isTogglingShowTime = false.obs;

Future<void> toggleShowTimeGlobal() async {
  isTogglingShowTime.value = true;
  try {
    final uri = Uri.parse('$_baseUrl/ads/toggle-show-time');
    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('toggleShowTimeGlobal status: ${response.statusCode}');
    debugPrint('toggleShowTimeGlobal body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (jsonResponse.containsKey('message')) {
        _showSnackbar('نجاح', jsonResponse['message'], false);
        
        // تحديث جميع الإعلانات إذا لزم الأمر
        final currentLang = Get.find<ChangeLanguageController>().currentLocale.value.languageCode;
        fetchAdminAds(lang: currentLang, status: 'published');
      } else {
        _showSnackbar('خطأ', 'استجابة غير متوقعة من السيرفر', true);
      }
    } else {
      _showSnackbar('خطأ', 'فشل تبديل حالة العرض الزمني (${response.statusCode})', true);
    }
  } catch (e) {
    debugPrint('toggleShowTimeGlobal error: $e');
    _showSnackbar('خطأ', 'حدث خطأ أثناء تبديل حالة العرض الزمني: $e', true);
  } finally {
    isTogglingShowTime.value = false;
  }
}



}



