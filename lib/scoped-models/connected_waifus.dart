import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:first_app/models/user.dart';
import 'package:first_app/models/waifu.dart';
import '../models/auth.dart';

import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';

mixin ConnectedWaifusModel on Model {
  List<Waifu> _waifus = [];
  String _selWaifuID;
  User _authenticatedUser;
  bool _isloading = false;
}

mixin WaifuModel on ConnectedWaifusModel {
  bool _showFavorate = false;

  List<Waifu> get allWaifus {
    return List.from(_waifus);
  }

  List<Waifu> get displayedWaifus {
    if (_showFavorate) {
      return _waifus.where((Waifu waifu) => waifu.isFavorated).toList();
    }
    return List.from(_waifus);
  }

  bool get displayFavorates {
    return _showFavorate;
  }

  String get selectedWaifuID {
    return _selWaifuID;
  }

  Waifu get selectedWaifu {
    if (selectedWaifuID == null) {
      return null;
    }
    return _waifus.firstWhere((Waifu waifu) {
      return waifu.id == selectedWaifuID;
    });
  }

  int get selectedWaifuIndex {
    return _waifus.indexWhere((Waifu waifu) {
      return waifu.id == _selWaifuID;
    });
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-waifu-collection.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong');
        print(json.decode(response.body));
        return null;
      }

      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addProduct(String name, String series, double rating,
      String description, File image) async {
    _isloading = true;
    notifyListeners();
    final uploadData = await uploadImage(image);
    if (uploadData == null) {
      print('Upload Failed');
      return false;
    }
    final Map<String, dynamic> waifuData = {
      'name': name,
      'series': series,
      'rating': rating,
      'description': description,
      'userEmail': _authenticatedUser.email,
      'userID': _authenticatedUser.id,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
    };
    try {
      final http.Response response = await http.post(
          'https://waifu-collection.firebaseio.com/waifus.json?auth=${_authenticatedUser.token}',
          body: json.encode(waifuData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isloading = false;
        notifyListeners();
        return false;
      }
      Map<String, dynamic> responseData = json.decode(response.body);
      Waifu waifu = new Waifu(
          name: name,
          series: series,
          image: uploadData['imageUrl'],
          imagePath: uploadData['imagePath'],
          description: description,
          rating: rating,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id,
          id: responseData['name']);
      _waifus.add(waifu);
      _isloading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isloading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct() {
    _isloading = true;
    final deletedWaifuID = selectedWaifu.id;
    _waifus.removeAt(selectedWaifuIndex);
    _selWaifuID = null;
    notifyListeners();
    return http
        .delete(
            'https://waifu-collection.firebaseio.com/waifus/$deletedWaifuID.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isloading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isloading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchWaifus({onlyForUser = false, clearExisting = false}) {
    _isloading = true;
    if (clearExisting) {
      _waifus = [];
    }
    notifyListeners();
    return http
        .get(
            'https://waifu-collection.firebaseio.com/waifus.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Waifu> fetchedWaifuList = [];
      final Map<String, dynamic> waifuListData = json.decode(response.body);
      if (waifuListData == null) {
        _isloading = false;
        notifyListeners();
        return;
      }
      waifuListData.forEach((String waifuID, dynamic waifuData) {
        final Waifu newWaifu = Waifu(
          id: waifuID,
          name: waifuData['name'],
          series: waifuData['series'],
          description: waifuData['description'],
          rating: waifuData['rating'],
          image: waifuData['imageUrl'],
          imagePath: waifuData['imagePath'],
          userEmail: waifuData['userEmail'],
          userId: waifuData['userID'],
          isFavorated: waifuData['wishlistUsers'] == null
              ? false
              : (waifuData['wishlistUsers'] as Map<String, dynamic>)
                  .containsKey(_authenticatedUser.id),
        );
        fetchedWaifuList.add(newWaifu);
      });
      _waifus = onlyForUser
          ? fetchedWaifuList.where((Waifu waifu) {
              return waifu.userId == _authenticatedUser.id;
            }).toList()
          : fetchedWaifuList;

      _isloading = false;
      notifyListeners();
      _selWaifuID = null;
    }).catchError((error) {
      _isloading = false;
      notifyListeners();
      return;
    });
  }

  Future<bool> updateProduct(String name, String series, double rating,
      String description, File image) async {
    _isloading = true;
    notifyListeners();
    String imageUrl = selectedWaifu.image;
    String imagePath = selectedWaifu.imagePath;
    if (image != null) {
      final uploadData = await uploadImage(image);
      if (uploadData == null) {
        print('Upload Failed');
        return false;
      }
      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }

    final Map<String, dynamic> updateData = {
      'name': name,
      'series': series,
      'rating': rating,
      'description': description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'userEmail': selectedWaifu.userEmail,
      'userID': selectedWaifu.userId,
    };
    try {
      await http.put(
          'https://waifu-collection.firebaseio.com/waifus/${selectedWaifu.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updateData));

      Waifu updatedWaifu = new Waifu(
          id: selectedWaifu.id,
          name: name,
          series: series,
          image: imageUrl,
          imagePath: imagePath,
          description: description,
          rating: rating,
          userEmail: selectedWaifu.userEmail,
          userId: selectedWaifu.userId);
      _waifus[selectedWaifuIndex] = updatedWaifu;
      _isloading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isloading = false;
      notifyListeners();
      return false;
    }
  }

  void toggleWaifuFavoriteStatus(bool toggle) {
    if (toggle) _selWaifuID = null;
  }

  void toggleWaifuFavorate() async {
    final bool isCurrentlyFavorate = selectedWaifu.isFavorated;
    final bool newFavorateStatus = !isCurrentlyFavorate;

    final Waifu updatedWaifu = Waifu(
      id: selectedWaifu.id,
      name: selectedWaifu.name,
      series: selectedWaifu.series,
      description: selectedWaifu.description,
      rating: selectedWaifu.rating,
      image: selectedWaifu.image,
      imagePath: selectedWaifu.imagePath,
      isFavorated: newFavorateStatus,
      userEmail: selectedWaifu.userEmail,
      userId: selectedWaifu.userId,
    );
    _waifus[selectedWaifuIndex] = updatedWaifu;
    notifyListeners();
    http.Response response;
    if (newFavorateStatus) {
      response = await http.put(
          'https://waifu-collection.firebaseio.com/waifus/${selectedWaifu.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: jsonEncode(true));
    } else {
      response = await http.delete(
          'https://waifu-collection.firebaseio.com/waifus/${selectedWaifu.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Waifu updatedWaifu = Waifu(
        id: selectedWaifu.id,
        name: selectedWaifu.name,
        series: selectedWaifu.series,
        description: selectedWaifu.description,
        rating: selectedWaifu.rating,
        image: selectedWaifu.image,
        imagePath: selectedWaifu.imagePath,
        isFavorated: !newFavorateStatus,
        userEmail: selectedWaifu.userEmail,
        userId: selectedWaifu.userId,
      );
      _waifus[selectedWaifuIndex] = updatedWaifu;
      notifyListeners();
    }
  }

  void selectWaifu(String waifuID) {
    _selWaifuID = waifuID;
    notifyListeners();
  }

  void toggleFavorate() {
    _showFavorate = !_showFavorate;
    notifyListeners();
  }
}

mixin UserModel on ConnectedWaifusModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isloading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyBG57z2HUjElNd0NZZ3q3_UXGzOgE7iHWE',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyBG57z2HUjElNd0NZZ3q3_UXGzOgE7iHWE',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = User(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userID', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND' ||
        responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'This Email or Password is invalid';
    } else if (responseData['error']['message'] == 'USER_DISABLED') {
      message = 'Account Banned';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists';
    }

    _isloading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String token = pref.getString('token');
    final String expiryTimeString = pref.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }

      final String userEmail = pref.getString('userEmail');
      final String userID = pref.getString('userID');
      final int tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userID, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);
      notifyListeners();
    }
  }

  void logout() async {
    print('logout');
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    _selWaifuID = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userID');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), () {
      logout();
      _userSubject.add(false);
    });
  }
}

mixin UtilityModel on ConnectedWaifusModel {
  bool get isloading {
    return _isloading;
  }
}
