import 'package:injectable/injectable.dart';
import 'package:mobileid/application/firebase_service.dart';

abstract class IOnboardingService {
  Future<bool> checkPermissions();
}

@Injectable(as: IOnboardingService)
class OnboardingService implements IOnboardingService {
  final FirebaseService _firebase;

  OnboardingService(this._firebase);

  @override
  Future<bool> checkPermissions() async {
    return await _firebase.checkPermissions();
  }
}
