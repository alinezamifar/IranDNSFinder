# IranDNSFinder 🚀

A fast and smart tool to benchmark and configure the best Domestic (Iranian) and International DNS servers on Linux.

ابزاری سریع و هوشمند برای بررسی، سنجش پینگ و ثبت بهترین DNSهای داخلی (تحریم‌شکن و عمومی ایران) و خارجی (بین‌المللی) در لینوکس.

---

## ⚡ Quick Start / اجرای سریع

برای اجرای مستقیم اسکریپت با دسترسی روت:

```bash
curl -k -Ls https://github.com/alinezamifar/IranDNSFinder/raw/refs/heads/main/dns.sh | sudo bash
```

یا اگر به عنوان کاربر `root` لاگین هستید:

```bash
curl -k -Ls https://github.com/alinezamifar/IranDNSFinder/raw/refs/heads/main/dns.sh | bash
```

یا دانلود و اجرای محلی:

```bash
git clone https://github.com/alinezamifar/IranDNSFinder.git
cd IranDNSFinder
chmod +x dns.sh
sudo ./dns.sh
```

---

## ✨ Features / ویژگی‌ها

- **بررسی همزمان DNSهای خارجی و ایرانی:**
  - سرورهای بین‌المللی محبوب: Cloudflare (1.1.1.1), Google (8.8.8.8), Quad9 (9.9.9.9), OpenDNS, AdGuard, Control D, DNS.WATCH, Level3, Comodo.
  - سرورهای تحریم‌شکن محبوب ایرانی: شکن (Shecan), بگذر (Begzar), الکترو (Electro), 403.online, Radar Game.
  - سرورهای اپراتورها و دیتاسنترهای زیرساخت داخلی (TIC & Iranian ISPs).
- **سنجش پینگ و انتخاب هوشمند سریع‌ترین‌ها:** تمامی ۵۰ سرور به صورت موازی با دسی‌ثانیه تست شده، تاخیر (Latency) هر کدام محاسبه و برترین و کم‌تاخیرترین سرورها به عنوان nameserver فعال در `/etc/resolv.conf` ثبت می‌شوند.
- **ایمنی کامل در برابر خطای پکیج و قطعی اینترنت:**
  - اگر پکیج `dig` موجود نباشد، اسکریپت ابتدا اقدام به نصب خودکار آن از طریق پکیج منیجر (`apt`, `dnf`, `yum`, `pacman`, `zypper`, `apk`) می‌کند.
  - در صورت عدم امکان نصب، اسکریپت **به هیچ وجه فایل `/etc/resolv.conf` را پاک یا ناقص نمی‌کند** و خطا می‌دهد.
  - در صورت نبود اتصال اینترنت، تنظیمات قبلی دست‌نخورده باقی می‌ماند.
- **پشتیبان‌گیری خودکار (Auto-Backup):** پیش از اعمال هرگونه تغییر، از فایل `/etc/resolv.conf` نسخه پشتیبان با پسوند تاریخ و ساعت ذخیره می‌شود.

---

## 👨‍💻 Author & Credits

- Developed by **Ali Nezamifar**
- Powered by **[Bia2Host.Com](https://bia2host.com)**
- License: MIT
