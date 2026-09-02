import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_update_info.dart';

class AppUpdateService {
  AppUpdateService({http.Client? httpClient,this.owner='Raj-123-N',this.repo='Speed-Math'}):_client=httpClient??http.Client();
  final http.Client _client;final String owner,repo;
  static const _keyAutoCheck='settings_auto_check_updates',_keyLastCheck='settings_last_update_check',_keySkippedVersion='settings_skipped_update_version';
  static const Duration _autoCheckInterval=Duration(hours:6);
  Future<String> getCurrentVersion() async {try{final p=await PackageInfo.fromPlatform();return p.version.isNotEmpty?p.version:'0.2.0';}catch(_){return '0.2.0';}}
  Future<bool> isAutoCheckEnabled()async{final p=await SharedPreferences.getInstance();return p.getBool(_keyAutoCheck)??true;}
  Future<void> setAutoCheckEnabled(bool enabled)async{final p=await SharedPreferences.getInstance();await p.setBool(_keyAutoCheck,enabled);}
  Future<DateTime?> getLastCheckTime()async{final p=await SharedPreferences.getInstance();final ms=p.getInt(_keyLastCheck);return ms==null?null:DateTime.fromMillisecondsSinceEpoch(ms);}
  Future<void> skipVersion(String version)async{final p=await SharedPreferences.getInstance();await p.setString(_keySkippedVersion,version);}
  Future<bool> shouldRunAutoCheck()async{if(!await isAutoCheckEnabled())return false;final last=await getLastCheckTime();return last==null||DateTime.now().difference(last)>=_autoCheckInterval;}
  Future<AppUpdateInfo?> checkForUpdate({bool force=false})async{final current=await getCurrentVersion();if(!force&&!await shouldRunAutoCheck())return null;try{final response=await _client.get(Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest'),headers:{'Accept':'application/vnd.github.v3+json','User-Agent':'Speed-Math-App'}).timeout(const Duration(seconds:10));final p=await SharedPreferences.getInstance();await p.setInt(_keyLastCheck,DateTime.now().millisecondsSinceEpoch);if(response.statusCode==200){final data=jsonDecode(response.body) as Map<String,dynamic>;final tag=data['tag_name'] as String???'';final latest=tag.replaceFirst(RegExp(r'^v',caseSensitive:false),'');final newer=isVersionNewer(current,latest);if(!force&&newer){final skipped=p.getString(_keySkippedVersion);if(skipped==latest||skipped==tag)return null;}return AppUpdateInfo.fromJson(json:data,currentVersion:current,hasUpdate:newer);}if(response.statusCode==404)return AppUpdateInfo.upToDate(current);if(kDebugMode)print('Failed to check update: HTTP ${response.statusCode}');return force?AppUpdateInfo.upToDate(current):null;}catch(e){if(kDebugMode)print('Error checking for updates: $e');return force?AppUpdateInfo.upToDate(current):null;}}
  static bool isVersionNewer(String current,String latest){final a=_parseVersion(current),b=_parseVersion(latest),n=max(a.length,b.length);for(var i=0;i<n;i++){final x=i<a.length?a[i]:0,y=i<b.length?b[i]:0;if(y>x)return true;if(y<x)return false;}return false;}
  static List<int> _parseVersion(String v){var s=v.trim().replaceFirst(RegExp(r'^[vV]'),'');if(s.contains('+'))s=s.split('+').first;if(s.contains('-'))s=s.split('-').first;return s.split('.').map((x)=>int.tryParse(x)??0).toList();}
  Future<bool> launchUpdate(AppUpdateInfo info)async{final target=info.apkDownloadUrl??info.releaseHtmlUrl;if(target.isEmpty)return false;final uri=Uri.parse(target);if(await canLaunchUrl(uri))return launchUrl(uri,mode:LaunchMode.externalApplication);return false;}
}
