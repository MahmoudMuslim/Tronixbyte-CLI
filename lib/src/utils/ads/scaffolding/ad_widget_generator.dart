import 'package:tools/tools.dart';

Future<void> generateAdWidgets(
  String projectName,
  List<String> enabledTypes,
) async {
  await loadingSpinner('Generating interactive Ad Widgets', () async {
    final widgetDir = Directory('lib/shared/widgets/ad_widgets');
    if (!widgetDir.existsSync()) widgetDir.createSync(recursive: true);

    if (enabledTypes.contains('adaptive_banner') ||
        enabledTypes.contains('fixed_banner')) {
      final bannerFile = File(
        'lib/shared/widgets/ad_widgets/app_banner_ad.dart',
      );
      bannerFile.writeAsStringSync("""
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
""");
    }

    // Update Barrel
    final barrelFile = File('lib/shared/widgets/ad_widgets/z_ad_widgets.dart');
    final exports = widgetDir
        .listSync()
        .whereType<File>()
        .map((f) => "export '${f.path.split(Platform.pathSeparator).last}';")
        .join('\n');
    barrelFile.writeAsStringSync('$exports\n');

    final sharedBarrel = File('lib/shared/widgets/z_widgets.dart');
    if (sharedBarrel.existsSync()) {
      String content = sharedBarrel.readAsStringSync();
      if (!content.contains('ad_widgets/z_ad_widgets.dart')) {
        sharedBarrel.writeAsStringSync(
          "$content\nexport 'ad_widgets/z_ad_widgets.dart';\n",
        );
      }
    }
  });
}
