// این فایل جایگزین flutter_bootstrap.js تولیدشده است تا کنترل دقیق روی
// راه‌اندازی موتور وب داشته باشیم:
//  ۱) CanvasKit از سرور خودمان بارگذاری می‌شود (بدون وابستگی به CDN گوگل که
//     در شبکه‌های محدود در دسترس نیست و باعث «صفحه بارگذاری بی‌پایان» می‌شد).
//  ۲) اسپلش فقط زمانی حذف می‌شود که runApp واقعاً اجرا شده باشد.
//  ۳) هر خطای راه‌اندازی به پیام فارسی + دکمه تلاش دوباره تبدیل می‌شود؛
//     بنابراین هیچ‌گاه اسپینر بی‌پایان باقی نمی‌ماند.
{{flutter_js}}
{{flutter_build_config}}

(function () {
  var boot = window.ontimeBoot || {};
  var finished = false;

  function hideSplash() {
    if (finished) return;
    finished = true;
    var el = document.getElementById('loading');
    if (!el) return;
    el.style.opacity = '0';
    el.style.pointerEvents = 'none';
    // حذف از DOM پس از پایان انیمیشن محو شدن
    el.addEventListener('transitionend', function () {
      if (el.parentNode) el.parentNode.removeChild(el);
    });
    if (window.ontimeSplashFallbackTimer) {
      clearTimeout(window.ontimeSplashFallbackTimer);
    }
  }

  function showBootError(message) {
    var box = document.getElementById('boot-error');
    var detail = document.getElementById('boot-error-detail');
    var splash = document.getElementById('loading');
    if (splash) splash.style.display = 'none';
    if (detail && message) detail.textContent = String(message).slice(0, 400);
    if (box) box.style.display = 'flex';
    window.__ontimeBootFailed = true;
  }

  boot.hideSplash = hideSplash;
  boot.showBootError = showBootError;
  window.ontimeBoot = boot;

  // اگر موتور خطایی بدهد ولی از مسیر عادی گزارش نکند.
  window.addEventListener('error', function (event) {
    if (!finished && event && event.message) {
      showBootError(event.message);
    }
  });
  window.addEventListener('unhandledrejection', function (event) {
    if (!finished) {
      var reason = event && event.reason ? event.reason : 'خطای نامشخص';
      showBootError(reason && reason.message ? reason.message : reason);
    }
  });

  _flutter.loader
    .load({
      config: {
        // منابع موتور از همین دامنه سرو می‌شوند (build/web/canvaskit).
        canvasKitBaseUrl: 'canvaskit/',
      },
      onEntrypointLoaded: async function (engineInitializer) {
        try {
          var appRunner = await engineInitializer.initializeEngine();
          await appRunner.runApp();
          // اولین فریم پس از runApp آماده است؛ اسپلش حذف می‌شود.
          hideSplash();
        } catch (error) {
          console.error('[ONTIME] boot failed', error);
          showBootError(error && error.message ? error.message : error);
        }
      },
    })
    .catch(function (error) {
      console.error('[ONTIME] loader failed', error);
      showBootError(error && error.message ? error.message : error);
    });

  // پشتیبان: رویداد رسمی اولین فریم (در صورت تفاوت نسخه موتور).
  window.addEventListener('flutter-first-frame', hideSplash);
})();
