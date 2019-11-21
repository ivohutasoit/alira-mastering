///
//  Generated code. Do not modify.
//  source: chat.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Chat extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Chat', package: const $pb.PackageName('domain'))
    ..aOS(1, 'message')
    ..hasRequiredFields = false
  ;

  Chat._() : super();
  factory Chat() => create();
  factory Chat.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Chat.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Chat clone() => Chat()..mergeFromMessage(this);
  Chat copyWith(void Function(Chat) updates) => super.copyWith((message) => updates(message as Chat));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Chat create() => Chat._();
  Chat createEmptyInstance() => create();
  static $pb.PbList<Chat> createRepeated() => $pb.PbList<Chat>();
  @$core.pragma('dart2js:noInline')
  static Chat getDefault() => _defaultInstance ??= create()..freeze();
  static Chat _defaultInstance;
  static void $checkItem(Chat v) {
    if (v is! Chat) $pb.checkItemFailed(v, _i.qualifiedMessageName);
  }

  $core.String get message => $_getS(0, '');
  set message($core.String v) { $_setString(0, v); }
  $core.bool hasMessage() => $_has(0);
  void clearMessage() => clearField(1);
}

