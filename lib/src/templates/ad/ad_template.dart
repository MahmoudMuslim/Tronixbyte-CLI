String getADMetaDataAndroidTemplate(String appId) {
  return """
      <meta-data
          android:name="com.google.android.gms.ads.APPLICATION_ID"
          android:value="$appId"/>""";
}

String getADIOSConfigTemplate(String appId) {
  return """
	<key>GADApplicationIdentifier</key>
	<string>$appId</string>
	<key>SKAdNetworkItems</key>
	<array>
		<dict>
			<key>SKAdNetworkIdentifier</key>
			<string>cstr6suwn9.skadnetwork</string>
		</dict>
	</array>""";
}

String getLoadRewardedAdTemplate() {
  return """
static void loadRewardedAd({
  required void Function(RewardedAd ad) onAdLoaded,
  void Function(LoadAdError error)? onAdFailedToLoad,
}) {
  RewardedAd.load(
    adUnitId: rewardedAdUnitId,
    request: const AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad ?? (error) => debugPrint('RewardedAd failed to load: \$error'),
    ));
}""";
}

String getLoadInterstitialAdTemplate() {
  return """
static void loadInterstitialAd({
  required void Function(InterstitialAd ad) onAdLoaded,
  void Function(LoadAdError error)? onAdFailedToLoad,
}) {
  InterstitialAd.load(
    adUnitId: interstitialAdUnitId,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: onAdLoaded,
      onAdFailedToLoad: onAdFailedToLoad ?? (error) => debugPrint('InterstitialAd failed to load: \$error'),
    ));
}""";
}

String getAppBannerAdTemplate(String projectName) {
  return """
import 'package:$projectName/$projectName.dart';

class AppBannerAd extends StatefulWidget {
final bool isAdaptive;
const AppBannerAd({super.key, this.isAdaptive = true});

@override
State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
BannerAd? _bannerAd;
bool _isLoaded = false;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (_bannerAd == null) _loadAd();
}

void _loadAd() async {
  if (kIsWeb) return;

  final AdSize size = widget.isAdaptive 
    ? await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        context.width.toInt(),
      ) ?? AdSize.banner
    : AdSize.banner;

  _bannerAd = BannerAd(
    adUnitId: widget.isAdaptive ? AdService.adaptiveBannerAdUnitId : AdService.fixedBannerAdUnitId,
    request: const AdRequest(),
    size: size,
    listener: BannerAdListener(
      onAdLoaded: (ad) => setState(() => _isLoaded = true),
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        debugPrint('BannerAd failed to load: \$error');
      },
    ),
  )..load();
}

@override
Widget build(BuildContext context) {
  if (!_isLoaded || _bannerAd == null) return const SizedBox();
  return SizedBox(
    width: _bannerAd!.size.width.toDouble(),
    height: _bannerAd!.size.height.toDouble(),
    child: AdWidget(ad: _bannerAd!));
}

@override
void dispose() {
  _bannerAd?.dispose();
  super.dispose();
}
}
""";
}
