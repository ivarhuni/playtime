import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

abstract class IHiveCache {
  Future<void> initialize();
  Future<void> put<T>(String key, T value);
  T? get<T>(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

@LazySingleton(as: IHiveCache)
class HiveCache implements IHiveCache {
  late Box _box;

  @override
  Future<void> initialize() async {
    _box = await Hive.openBox('app_cache');
  }

  @override
  Future<void> put<T>(String key, T value) async {
    await _box.put(key, value);
  }

  @override
  T? get<T>(String key) {
    return _box.get(key) as T?;
  }

  @override
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
} 