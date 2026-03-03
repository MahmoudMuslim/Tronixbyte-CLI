String getFirebaseNotificationAndroidMetaDataTemplate() {
  return """
      <meta-data
          android:name="com.google.firebase.messaging.default_notification_channel_id"
          android:value="high_importance_channel" />
      <meta-data
          android:name="com.google.firebase.messaging.default_notification_icon"
          android:resource="@mipmap/ic_launcher" />""";
}

String getFirebaseNotificationIOSMetaDataTemplate() {
  return """
	<key>FirebaseAppDelegateProxyEnabled</key>
	<false/>
	<key>UIBackgroundModes</key>
	<array>
		<string>fetch</string>
		<string>remote-notification</string>
	</array>
""";
}
