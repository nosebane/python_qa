# Penjelasan Teknis: Indodax Automation Framework

**Versi:** 2.0  
**Tanggal:** Februari 2026  
**Status:** Implemented & Verified

---

## Daftar Isi
1. [Justifikasi Teknis](#1-justifikasi-teknis)
2. [Trade-off Decision](#2-trade-off-decision)
3. [Scalability Consideration](#3-scalability-consideration)
4. [Maintainability Consideration](#4-maintainability-consideration)

---

## 1. Justifikasi Teknis

### Mengapa 5-Layer Architecture?

Framework dibangun dalam 5 layer yang terpisah secara tegas:

```
tests/             → Test Cases      (WHAT to test)
keywords/          → Business Flow   (HOW to test, high-level)
page_objects/      → UI Abstraction  (WHERE the elements are)
libraries/         → Custom Logic    (Python — signing, validation, config)
external libs/     → Tool Integration (RF, Browser, Appium, Requests)
```

Setiap layer hanya boleh memanggil layer di bawahnya, tidak boleh melompati. Ini bukan aturan estetika — ini mencegah coupling yang membuat refactor menjadi mahal.

**Contoh konkret:** Saat halaman Market di aplikasi mobile berganti layout, hanya file locator di `page_objects/mobile/market/` yang berubah. Test case di `tests/mobile/` dan keyword flow di `resources/keywords/mobile/` tidak perlu disentuh sama sekali.

---

### Mengapa Custom Python Libraries Dipisah dari Robot Files?

Ada tiga logic yang tidak bisa (atau tidak seharusnya) ditulis di Robot syntax:

1. **HMAC-SHA512 signing** — Private API Indodax membutuhkan signature dari kombinasi API key, nonce, dan parameter request. Ini operasi kriptografis yang lebih tepat ditulis dan di-unit test sebagai Python class — kesalahan di sini akan menyebabkan seluruh private API test gagal dengan error yang menyesatkan.

2. **JSON Schema validation** — Validasi struktur response API (field wajib, tipe data, nested object) lebih robust menggunakan `jsonschema` di Python dibanding serangkaian `Should Contain` di robot.

3. **Config loading** — Membaca YAML, resolve environment variable, caching — ini logic yang butuh error handling yang tidak natural ditulis di robot syntax.

Hasilnya: Robot file tetap ringkas dan mudah dibaca, sementara logic kompleks yang bisa di-unit test ada di `libraries/`.

---

### Mengapa Hybrid YAML + .env untuk Konfigurasi?

Pendekatan satu file konfigurasi tidak mencukupi karena ada dua kategori data yang berbeda sifatnya:

| Kategori | Contoh | Boleh masuk Git? |
|---|---|---|
| **Non-secret** | Timeout, retry count, headless flag | ✅ Ya |
| **Secret** | API key, base URL, device UDID | ❌ Tidak |

Solusi dua lapis:

```
config/environments/production.yaml  ← timeout, retry, flags  → committed
.env.production                      ← API key, URL, secrets   → gitignored
```

`ConfigManager` menjadi satu-satunya pintu masuk: load `.env` ke `os.environ`, lalu resolve `${VAR}` di YAML dari environment tersebut. Keyword Robot tidak perlu tahu mekanisme ini — cukup panggil `Get Environment Config` dan dapatkan dict yang sudah lengkap.

Dampaknya: ganti environment hanya dengan `--variable TEST_ENV:staging`, tanpa ubah satu baris pun di test file.

---

### Mengapa Locator Dipisah dari Keyword di Layer Page Object?

Di `resources/page_objects/mobile/market/` terdapat dua file:

```
market_keywords.robot   ← FLOW: fungsi interaksi dengan halaman
market_locators.robot   ← DATA: locator id, css, xpath, accessibility_id, text selector
```

Locator adalah bagian paling volatile dari test — berubah setiap kali developer mengubah layout atau rename atribut. Dengan memisahkannya, perubahan UI hanya berdampak pada satu file, dan engineer tidak perlu memahami seluruh keyword flow untuk melakukan update.

---

## 2. Trade-off Decision

### Trade-off 1: Monorepo (API + Web + Mobile) vs Repo Terpisah

Opsi memisahkan API, Web, dan Mobile ke repo berbeda memberikan isolasi yang lebih ketat, tapi dipilih monorepo karena:

- **Shared config layer** — `config/environments/` dan `libraries/base/` dipakai oleh ketiga platform. Duplikasi di repo terpisah akan menciptakan drift (satu repo update, lainnya tidak)
- **Satu versi requirements** — dependensi dikontrol dari satu `requirements.txt`
- **Reporting terpadu** — `rebot` bisa merge output ketiga platform menjadi satu laporan

**Cost yang diterima:** CI/CD harus lebih cerdas menentukan apa yang perlu dijalankan berdasarkan perubahan (perubahan di `tests/api/` tidak perlu trigger mobile run).

---

### Trade-off 2: Suite Setup per File vs Centralized Setup

Setiap test file punya `Suite Setup` sendiri, bukan satu global setup untuk seluruh suite:

```robot
# Setiap file berdiri sendiri
Suite Setup    Initialize API Test Environment
```

**Keuntungan:** Setiap test suite bisa dijalankan secara independen, dalam urutan apapun, tanpa bergantung pada state suite lain.

**Cost yang diterima:** Ada sedikit duplikasi setup time saat menjalankan semua suite sekaligus. Diterima karena reproducibility lebih penting dari kecepatan di fase ini.

---

### Trade-off 3: Tag Inheritance — Suite Level vs Test Level

Framework menggunakan keduanya secara berlapis:

```robot
# Suite level — homogen untuk semua test dalam file
Test Tags    api    indodax    public    smoke

# Test level — bervariasi per test case
Public API - Get Bitcoin Ticker
    [Tags]    ticker    positive_case    critical
```

**Keputusan:** Suite-level tag untuk dimensi yang homogen (platform, kategori besar), test-level tag untuk dimensi yang bervariasi (feature, priority, data type). Mengurangi repetisi tanpa mengorbankan granularitas filter.

---

### Trade-off 4: Resource Path Relatif vs Absolut

Semua `Resource` import menggunakan path relatif:

```robot
# tests/mobile/android/base/search_and_validate_eth.robot
Resource    ../../../../resources/keywords/mobile/mobile_settings.robot
```

**Keuntungan:** Tidak ada dependency pada environment variable atau konfigurasi robot.ini. File bisa dipindahkan ke mesin lain tanpa setup tambahan.

**Cost yang diterima:** Saat file dipindahkan ke direktori berbeda, semua path relatif perlu diupdate. Diterima karena perpindahan file adalah kejadian langka, sedangkan portabilitas adalah kebutuhan sehari-hari.

---


## 3. Scalability Consideration

### Menambah Platform Baru Tanpa Mengubah Layer yang Ada

Arsitektur 5-layer memungkinkan platform baru ditambahkan tanpa menyentuh layer yang sudah berjalan:

```
Yang TIDAK perlu diubah saat tambah iOS:
├── libraries/base/config_manager.py     ← shared, tidak berubah
├── libraries/api/                       ← tidak relevan untuk mobile
└── resources/keywords/api/ dan web/    ← tidak relevan

Yang PERLU dibuat untuk iOS:
├── config/environments/mobile_production_ios.yaml
├── resources/page_objects/mobile/      ← bisa share dengan Android atau baru
└── tests/mobile/ios/base/             ← test file baru
```

---

### Menambah Environment Baru

Saat perlu environment baru (misal `uat`), yang dibutuhkan hanya:

```
1. Buat config/environments/uat.yaml
2. Buat .env.uat di mesin runner
3. Jalankan: robot --variable TEST_ENV:uat tests/
```

Tidak ada perubahan di test file, keyword, atau library. Bisa dilakukan QA Engineer tanpa bantuan developer.

---

### Skalabilitas Test Volume

Saat jumlah test bertambah, dua mekanisme sudah tersedia tanpa refactor:

**Selective execution via tag:**
```bash
robot --include smoke --exclude skip tests/
robot --include critical tests/api/
```

**Parallelisasi via pabot:**
```bash
pabot --processes 4 tests/api/ tests/web/
```

Karena setiap test suite sudah stateless (tidak share state antar file), parallelisasi bisa langsung diterapkan.

---

### Skalabilitas CI/CD

Two-track pipeline dirancang agar kedua track bisa berkembang secara independen:

```
Track 1: Cloud VM (ubuntu-latest)
└── API + Web → scale dengan menambah parallel jobs

Track 2: Self-Hosted Runner
└── Mobile → scale dengan menambah device dan runner
```

Penambahan 10 test web tidak memperlambat mobile run, dan sebaliknya.

---

### Multi-Device Mobile

Struktur config sudah siap untuk multiple device — cukup variasikan `DEVICE_UDID` di `.env` per runner:

```yaml
# mobile_production.yaml
capabilities:
  udid: ${DEVICE_UDID}    # berbeda per mesin/runner
  platform_name: Android
```

---

## 4. Maintainability Consideration

### Perubahan UI Hanya Berdampak pada Satu File

Ini adalah benefit paling konkret dari pemisahan locator dan keyword:

```
Skenario: Developer mengubah accessibility_id tombol "Market" di Android

Yang perlu diubah:
└── page_objects/mobile/market/market_locators.robot  ← 1 baris

Yang TIDAK perlu diubah:
├── market_keywords.robot     ← flow tetap sama
├── tests/mobile/android/     ← test cases tetap sama
└── mobile_settings.robot     ← settings tetap sama
```

---

### Keyword Reusable — Test Baru Tidak Perlu Keyword Baru

Keyword di layer page object dan keywords dirancang parameterized:

```robot
# Keyword ini sudah ada — bisa dipakai test case manapun
Search For Cryptocurrency    ${COIN}
Validate Trading Page Is Displayed    ${PAIR}
```

Menambah test untuk coin lain (misal BTC) tidak perlu keyword baru — cukup buat test case yang memanggil keyword yang sama dengan parameter berbeda.

---

### Failure Selalu Reproducible

Setiap test failure menghasilkan tiga artefak otomatis:

| File | Isi |
|---|---|
| `results/report.html` | Ringkasan: test mana yang gagal, durasi, tag breakdown |
| `results/log.html` | Detail setiap keyword step + screenshot di titik failure |
| `results/output.xml` | Data mentah untuk integrasi CI/CD |

Dengan screenshot yang hanya diambil saat failure, engineer bisa mendiagnosis masalah tanpa perlu menjalankan ulang test dan "menunggu" error muncul kembali.
