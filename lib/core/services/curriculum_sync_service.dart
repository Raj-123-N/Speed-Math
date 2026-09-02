import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speed_math_content/curriculum.dart';

class CurriculumSyncService {
  CurriculumSyncService._();
  static final instance=CurriculumSyncService._();
  static const _cache='published_curriculum_v1';
  static const _url='https://firestore.googleapis.com/v1/projects/speed-math-app-1/databases/(default)/documents/publishedContent/current';

  Future<List<LessonTopic>> load({bool refresh=true}) async {
    final prefs=await SharedPreferences.getInstance();
    if(refresh){try{final response=await http.get(Uri.parse(_url)).timeout(const Duration(seconds:8));if(response.statusCode==200){final topics=_parse(jsonDecode(response.body));if(topics.isNotEmpty){await prefs.setString(_cache,jsonEncode(topics.map((e)=>e.toMap()).toList()));return topics;}}}catch(_){}}
    final cached=prefs.getString(_cache);if(cached!=null){try{final list=jsonDecode(cached) as List;return list.map((e)=>LessonTopic.fromMap(Map<String,dynamic>.from(e as Map))).toList();}catch(_){}}
    return CurriculumCatalog.topics;
  }

  List<LessonTopic> _parse(Map<String,dynamic> root){final values=((root['fields'] as Map?)?['topics'] as Map?)?['arrayValue']?['values'];if(values is! List)return const[];return values.map<LessonTopic?>((raw){final fields=((raw as Map)['mapValue'] as Map?)?['fields'];if(fields is! Map)return null;return LessonTopic.fromMap(_fields(Map<String,dynamic>.from(fields)));}).whereType<LessonTopic>().where((e)=>e.id.isNotEmpty).toList();}
  Map<String,dynamic> _fields(Map<String,dynamic> fields){dynamic value(String key){final f=fields[key];if(f is! Map)return null;if(f['stringValue']!=null)return f['stringValue'];final arr=f['arrayValue']?['values'];if(arr is List)return arr.map((x){final m=x as Map;return m['stringValue']??'';}).toList();return null;}return {'id':value('id'),'title':value('title'),'section':value('section'),'level':value('level'),'summary':value('summary'),'concepts':value('concepts'),'methods':value('methods'),'examples':value('examples'),'traps':value('traps'),'practice':value('practice')};}
}
