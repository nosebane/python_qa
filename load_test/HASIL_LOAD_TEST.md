============================================================
  📊 RINGKASAN HASIL LOAD TEST terhadap jsonplaceholder.typicode.com 
  (karena https://dummy.restapiexample.com/ mempunyai limit reqeust 1 per second)
============================================================
  Total Request     : 2080
  Total Failure     : 0
  Failure Rate      : 0.00%
  Avg Response Time : 107 ms
  P95 Response Time : 280 ms
  Min Response Time : 34 ms
  Max Response Time : 2469 ms
  RPS (approx)      : 11.70
============================================================

  ✅ ASSERTION RESULTS
------------------------------------------------------------
  [PASS ✅] Avg Response Time: 107.38 ms (threshold: <= 2000 ms)
  [PASS ✅] P95 Response Time: 280.00 ms (threshold: <= 3000 ms)
  [PASS ✅] Failure Rate: 0.00% (threshold: <= 5.0%)
  [PASS ✅] Throughput (RPS): 11.70 rps (threshold: >= 8.0 rps)
------------------------------------------------------------

  🔍 ANALISA SINGKAT
------------------------------------------------------------
  • Tidak ada kegagalan request — server stabil di beban ini.
  • Response time rata-rata sangat cepat (< 500 ms) — performa excellent.
  • P95 280 ms aman — distribusi response time konsisten.

  Kesimpulan: Test LULUS ✅
============================================================