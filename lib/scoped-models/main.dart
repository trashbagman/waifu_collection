
import 'package:first_app/scoped-models/connected_waifus.dart';
import 'package:scoped_model/scoped_model.dart';

class MainModel extends Model with ConnectedWaifusModel, WaifuModel, UserModel, UtilityModel{

}