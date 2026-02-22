# 📊 Hasil Load Test

> **Target:** [jsonplaceholder.typicode.com](https://jsonplaceholder.typicode.com)
> _(dipilih karena [dummy.restapiexample.com](https://dummy.restapiexample.com) membatasi request 1 per second)_

---

## Ringkasan Metrik

| Metrik | Nilai |
|---|---|
| Total Request | 2.080 |
| Total Failure | 0 |
| Failure Rate | 0,00% |
| Avg Response Time | 107 ms |
| P95 Response Time | 280 ms |
| Min Response Time | 34 ms |
| Max Response Time | 2.469 ms |
| Throughput (RPS) | ≈ 11,70 req/s |

---

## Assertion Results

| Metrik | Hasil | Nilai | Threshold |
|---|---|---|---|
| Avg Response Time | ✅ PASS | 107,38 ms | ≤ 2.000 ms |
| P95 Response Time | ✅ PASS | 280,00 ms | ≤ 3.000 ms |
| Failure Rate | ✅ PASS | 0,00% | ≤ 5,0% |
| Throughput (RPS) | ✅ PASS | 11,70 rps | ≥ 8,0 rps |

---

## Analisa Singkat

- **Tidak ada kegagalan request** — server stabil di beban ini.
- **Response time rata-rata sangat cepat** (107 ms, jauh di bawah threshold 2.000 ms) — performa excellent.
- **P95 280 ms aman** — distribusi response time konsisten, tidak ada outlier yang signifikan.

## Kesimpulan

> **Test LULUS ✅** — Semua 4 assertion terpenuhi.