# CI/CD Configuration — Indodax Automation Framework

Pipeline lengkap untuk menjalankan test suite API, Web, dan Mobile secara otomatis.

---

## 🏗️ Arsitektur Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Actions                               │
│                                                                  │
│  Push / PR                   Nightly (02:00 WIB)                │
│       │                             │                            │
│       ▼                             ▼                            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                  full-suite.yml                          │    │
│  │                                                          │    │
│  │  ┌───────────┐  ┌───────────┐  ┌─────────────────────┐ │    │
│  │  │ API Tests │  │ Web Tests │  │   Mobile Tests       │ │    │
│  │  │ (Ubuntu)  │  │ (Ubuntu)  │  │ (self-hosted Mac)    │ │    │
│  │  │           │  │           │  │                      │ │    │
│  │  │ public ─┐ │  │ chromium  │  │  Android ─ ADB       │ │    │
│  │  │ private─┘ │  │ firefox   │  │  iOS ──── XCUITest   │ │    │
│  │  └─────┬─────┘  │ webkit    │  └──────────┬───────────┘ │    │
│  │        │        └─────┬─────┘             │             │    │
│  │        └──────────────┴──────────┬────────┘             │    │
│  │                                  ▼                       │    │
│  │                         merge-reports                    │    │
│  │                         (rebot → HTML)                   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

| Suite   | Runner          | Execution         |
|---------|-----------------|-------------------|
| API     | `ubuntu-latest` | GitHub-hosted VM  |
| Web     | `ubuntu-latest` | GitHub-hosted VM  |
| Mobile  | `self-hosted`   | Mac device farm   |

---

## 📁 Struktur Folder

```
ci_cd/
├── github/
│   └── workflows/
│       ├── api-tests.yml       # API-only pipeline
│       ├── web-tests.yml       # Web-only pipeline
│       ├── mobile-tests.yml    # Mobile-only pipeline
│       └── full-suite.yml      # Orchestrator (semua suite)
├── docker/
│   ├── Dockerfile.web-api      # Image untuk Web & API runner
│   └── docker-compose.yml      # Compose untuk local/Docker execution
├── scripts/
│   ├── run_api.sh              # Jalankan API tests
│   ├── run_web.sh              # Jalankan Web tests
│   ├── run_mobile.sh           # Jalankan Mobile tests
│   └── setup_device_farm.sh   # Setup Mac sebagai device farm
├── Makefile                    # Shortcut commands
└── README.md                   # Dokumentasi ini
```

---

## ⚙️ Setup

### 1. GitHub Secrets

Di repositori → **Settings → Secrets and variables → Actions**, tambahkan:

| Secret Name            | Keterangan                              |
|------------------------|-----------------------------------------|
| `API_BASE_URL`         | Base URL Public API (staging/production)|
| `PRIVATE_API_BASE_URL` | Base URL Private API                    |
| `INDODAX_API_KEY`      | API Key untuk private API tests         |
| `INDODAX_API_SECRET`   | API Secret untuk private API tests      |
| `WEB_BASE_URL`         | URL website untuk Web tests             |

### 2. Aktifkan GitHub Actions Workflows

File `.yml` di folder `ci_cd/github/workflows/` perlu disalin ke `.github/workflows/` di root repositori agar GitHub Actions membacanya:

```bash
# Dari root repositori
mkdir -p .github/workflows
cp automation-framework/ci_cd/github/workflows/*.yml .github/workflows/
```

Atau buat symlink (lebih mudah maintenance):

```bash
mkdir -p .github
ln -sf ../automation-framework/ci_cd/github/workflows .github/workflows
```

### 3. Setup Self-Hosted Runner (Mobile Device Farm)

Pada Mac yang memiliki device Android/iOS terhubung:

```bash
# Install Appium dan dependencies
./automation-framework/ci_cd/scripts/setup_device_farm.sh

# Dengan iOS support
./automation-framework/ci_cd/scripts/setup_device_farm.sh --ios
```

Setelah itu, daftarkan Mac sebagai GitHub Actions self-hosted runner:

1. Go to repo → **Settings → Actions → Runners → New self-hosted runner**
2. Pilih **macOS**
3. Ikuti instruksi download & konfigurasi
4. Saat `./config.sh`, tambahkan labels: `self-hosted,macOS,device-farm`
5. Start runner: `./run.sh`

---

## 🚀 Menjalankan Tests

### Via Makefile (Rekomendasi)

```bash
cd automation-framework

# API tests
make test-api                              # staging, semua suite
make test-api ENV=production SUITE=public  # production, public saja
make test-api-private                      # private API saja

# Web tests
make test-web                              # staging, chromium, headless
make test-web BROWSER=firefox HEADLESS=false
make test-web-all-browsers                 # chromium + firefox + webkit

# Mobile tests
make test-mobile                           # auto-detect device
make test-mobile DEVICE=R8AIGF001200RC6    # device spesifik
make test-mobile PLATFORM=ios

# Full suite
make test-all    # API + Web (tanpa Mobile)
make test-full   # API + Web + Mobile

# Lainnya
make check-devices   # Cek device Android terhubung
make check-appium    # Cek status Appium server
make open-report     # Buka merged report di browser
make clean           # Hapus hasil test
```

### Via Shell Scripts

```bash
cd automation-framework

# API
./ci_cd/scripts/run_api.sh -e staging -s all
./ci_cd/scripts/run_api.sh -e production -s public -t smoke

# Web
./ci_cd/scripts/run_web.sh -e staging -b chromium -H true
./ci_cd/scripts/run_web.sh -b all  # semua browser

# Mobile
./ci_cd/scripts/run_mobile.sh -p android -e production
./ci_cd/scripts/run_mobile.sh -p android -d R8AIGF001200RC6 -s search_and_validate_eth.robot
```

### Via Docker (Web & API)

```bash
cd automation-framework

# Build image
make docker-build

# Jalankan
make docker-api          # Semua API tests
make docker-api-public   # Public API saja
make docker-web          # Web tests (chromium default)
make docker-web BROWSER=firefox
```

### Trigger via GitHub Actions UI

1. Go to **Actions** tab di repositori
2. Pilih workflow: `API Tests` / `Web Tests` / `Mobile Tests` / `Full Test Suite`
3. Klik **Run workflow**
4. Isi parameter (environment, suite, browser, dll.)
5. Klik **Run workflow**

---

## 📊 Test Reports

Setelah pipeline selesai:

- **Artifacts** tersedia di halaman GitHub Actions run (retention: 30 hari, full suite: 90 hari)
- **Merged report** gabungan semua suite ada di artifact `full-suite-report-<run_id>`
- Lokal: buka `results/merged/report.html` atau `make open-report`

---

## 🔧 Konfigurasi Pipeline

### Trigger Otomatis

| Workflow           | Trigger Push/PR Path                          |
|--------------------|-----------------------------------------------|
| `api-tests.yml`    | `tests/api/**`, `libraries/api/**`             |
| `web-tests.yml`    | `tests/web/**`, `resources/page_objects/web/**`|
| `mobile-tests.yml` | `tests/mobile/**`, `resources/page_objects/mobile/**`|
| `full-suite.yml`   | `main` branch push + nightly cron (02:00 WIB) |

### Environment Variables di Runner

Mobile runner memerlukan file `.env.mobile.production` di folder `automation-framework/`:

```dotenv
APPIUM_SERVER=http://127.0.0.1:4723
ANDROID_DEVICE_NAME=R8AIGF001200RC6
ANDROID_APP_PACKAGE=id.co.bitcoin
ANDROID_APP_ACTIVITY=.ui.main.SplashScreenActivity
```

---

## 🛠️ Troubleshooting

| Problem | Solution |
|---------|----------|
| Mobile job skip: "No devices" | Cek `adb devices` di device farm Mac |
| Appium not ready | Cek `/tmp/appium.log`, restart: `make check-appium` |
| Playwright browser error | Jalankan `rfbrowser init chromium` di runner |
| Private API 401 | Pastikan `INDODAX_API_KEY` & `INDODAX_API_SECRET` secrets sudah diset |
| Self-hosted runner offline | SSH ke Mac, cek `./run.sh` jalan, restart runner service |
