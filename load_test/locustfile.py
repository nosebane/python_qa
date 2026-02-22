"""
Load Test terhadap jsonplaceholder.typicode.com karena https://dummy.restapiexample.com/ mempunyai limit reqeust 1 per second
Target: 10 RPS
Tool: Locust
"""

import json
import logging
import random
from locust import HttpUser, task, between, events

# ─────────────────────────────────────────────
# Logger Setup
# ─────────────────────────────────────────────
logging.basicConfig(
    filename="load_test_results.log",
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger(__name__)

# ─────────────────────────────────────────────
# Thresholds (Assertion Config)
# ─────────────────────────────────────────────
THRESHOLD = {
    "max_avg_response_time_ms": 2000,   # Rata-rata response time < 2 detik
    "max_p95_response_time_ms": 3000,   # P95 response time < 3 detik
    "max_failure_rate_pct": 5.0,        # Error rate < 5%
    "min_rps": 8.0,                     # Minimal throughput 8 RPS (dari target 10)
}

# ─────────────────────────────────────────────
# Custom Listener (Event Hooks)
# ─────────────────────────────────────────────
@events.request.add_listener
def on_request(request_type, name, response_time, response_length, response,
               context, exception, start_time, url, **kwargs):
    """Listener: Log setiap request (sukses & gagal)."""
    if exception:
        logger.error(
            f"FAIL | {request_type} {name} | {response_time:.0f}ms | Error: {exception}"
        )
    else:
        status = "OK" if response.status_code < 400 else "HTTP_ERR"
        logger.info(
            f"{status} | {request_type} {name} | {response_time:.0f}ms | "
            f"Status: {response.status_code} | Size: {response_length}B"
        )


@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """Listener: Dipanggil saat test dimulai."""
    print("\n" + "=" * 60)
    print("  🚀 LOAD TEST DIMULAI")
    print(f"  Target URL : {environment.host}")
    print(f"  Target RPS : 10")
    print("=" * 60 + "\n")
    logger.info("=== LOAD TEST STARTED ===")


@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    """Listener: Dipanggil saat test selesai — jalankan assertions & print ringkasan."""
    stats = environment.stats.total

    # ── Kalkulasi Metrik ──
    total_requests   = stats.num_requests
    total_failures   = stats.num_failures
    avg_rt_ms        = stats.avg_response_time
    p95_rt_ms        = stats.get_response_time_percentile(0.95) or 0
    failure_rate_pct = (total_failures / total_requests * 100) if total_requests > 0 else 0
    rps              = stats.current_rps if hasattr(stats, "current_rps") else (
                           total_requests / (stats.last_request_timestamp - stats.start_time)
                           if stats.last_request_timestamp and stats.start_time else 0
                       )

    # ── Print Ringkasan ──
    print("\n" + "=" * 60)
    print("  📊 RINGKASAN HASIL LOAD TEST")
    print("=" * 60)
    print(f"  Total Request     : {total_requests}")
    print(f"  Total Failure     : {total_failures}")
    print(f"  Failure Rate      : {failure_rate_pct:.2f}%")
    print(f"  Avg Response Time : {avg_rt_ms:.0f} ms")
    print(f"  P95 Response Time : {p95_rt_ms:.0f} ms")
    print(f"  Min Response Time : {stats.min_response_time:.0f} ms")
    print(f"  Max Response Time : {stats.max_response_time:.0f} ms")
    print(f"  RPS (approx)      : {rps:.2f}")
    print("=" * 60)

    # ── Assertions ──
    print("\n  ✅ ASSERTION RESULTS")
    print("-" * 60)
    failures = []

    def assert_threshold(metric_name, actual, threshold, condition="<=", unit=""):
        passed = (actual <= threshold) if condition == "<=" else (actual >= threshold)
        status = "PASS ✅" if passed else "FAIL ❌"
        print(f"  [{status}] {metric_name}: {actual:.2f}{unit} (threshold: {condition} {threshold}{unit})")
        if not passed:
            failures.append(f"{metric_name} ({actual:.2f}{unit}) melanggar threshold {condition} {threshold}{unit}")

    assert_threshold("Avg Response Time", avg_rt_ms,        THRESHOLD["max_avg_response_time_ms"], "<=", " ms")
    assert_threshold("P95 Response Time", p95_rt_ms,        THRESHOLD["max_p95_response_time_ms"], "<=", " ms")
    assert_threshold("Failure Rate",      failure_rate_pct, THRESHOLD["max_failure_rate_pct"],     "<=", "%")
    assert_threshold("Throughput (RPS)",  rps,              THRESHOLD["min_rps"],                  ">=", " rps")

    print("-" * 60)

    # ── Analisa Singkat ──
    print("\n  🔍 ANALISA SINGKAT")
    print("-" * 60)

    if failure_rate_pct == 0:
        print("  • Tidak ada kegagalan request — server stabil di beban ini.")
    elif failure_rate_pct < 5:
        print(f"  • Error rate {failure_rate_pct:.1f}% masih di bawah threshold, namun perlu dimonitor.")
    else:
        print(f"  • ⚠️  Error rate {failure_rate_pct:.1f}% MELEBIHI batas 5% — server bermasalah!")

    if avg_rt_ms < 500:
        print("  • Response time rata-rata sangat cepat (< 500 ms) — performa excellent.")
    elif avg_rt_ms < 2000:
        print(f"  • Response time rata-rata {avg_rt_ms:.0f} ms — masih dalam toleransi.")
    else:
        print(f"  • ⚠️  Response time rata-rata {avg_rt_ms:.0f} ms MELEBIHI 2 detik — perlu optimasi.")

    if p95_rt_ms > THRESHOLD["max_p95_response_time_ms"]:
        print(f"  • ⚠️  P95 {p95_rt_ms:.0f} ms tinggi — 5% pengguna mengalami respons lambat.")
    else:
        print(f"  • P95 {p95_rt_ms:.0f} ms aman — distribusi response time konsisten.")

    overall = "LULUS ✅" if not failures else "GAGAL ❌"
    print(f"\n  Kesimpulan: Test {overall}")
    if failures:
        print("  Threshold yang dilanggar:")
        for f in failures:
            print(f"    - {f}")

    print("=" * 60 + "\n")

    # Log ke file
    logger.info(f"SUMMARY | Requests={total_requests} | Failures={total_failures} | "
                f"AvgRT={avg_rt_ms:.0f}ms | P95={p95_rt_ms:.0f}ms | "
                f"FailRate={failure_rate_pct:.2f}% | RPS={rps:.2f}")
    logger.info(f"RESULT  | {'PASS' if not failures else 'FAIL'}")
    if failures:
        for f in failures:
            logger.warning(f"THRESHOLD VIOLATED: {f}")
    logger.info("=== LOAD TEST ENDED ===")


# ─────────────────────────────────────────────
# User Behavior
# ─────────────────────────────────────────────
class PostApiUser(HttpUser):
    """
    Simulasi pengguna yang mengakses JSONPlaceholder API.
    wait_time mengontrol jeda antar request per user.
    Dengan 10 user & wait_time(1,2), diperoleh ~5-10 RPS.
    """
    wait_time = between(0.5, 1)

    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
    }

    # ── GET All Posts ──
    @task(3)
    def get_all_posts(self):
        with self.client.get(
            "/posts",
            name="GET /posts",
            headers=self.headers,
            catch_response=True
        ) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if isinstance(data, list) and len(data) > 0:
                        response.success()
                    else:
                        response.failure("Unexpected payload: bukan list atau kosong")
                except json.JSONDecodeError:
                    response.failure("Response bukan JSON valid")
            else:
                response.failure(f"HTTP {response.status_code}")

    # ── GET Single Post ──
    @task(2)
    def get_single_post(self):
        post_id = random.randint(1, 100)  # JSONPlaceholder punya 100 posts
        with self.client.get(
            f"/posts/{post_id}",
            name="GET /posts/{id}",
            headers=self.headers,
            catch_response=True
        ) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if data.get("id") == post_id:
                        response.success()
                    else:
                        response.failure(f"ID tidak sesuai: expected {post_id}, got {data.get('id')}")
                except json.JSONDecodeError:
                    response.failure("Response bukan JSON valid")
            else:
                response.failure(f"HTTP {response.status_code}")

    # ── CREATE Post ──
    @task(1)
    def create_post(self):
        payload = {
            "title": "Load Test Post",
            "body": "Created by Locust load test",
            "userId": random.randint(1, 10)
        }
        with self.client.post(
            "/posts",
            json=payload,
            name="POST /posts",
            headers=self.headers,
            catch_response=True
        ) as response:
            if response.status_code == 201:
                try:
                    data = response.json()
                    if data.get("id"):
                        response.success()
                    else:
                        response.failure("Response tidak mengandung id")
                except json.JSONDecodeError:
                    response.failure("Response bukan JSON valid")
            else:
                response.failure(f"HTTP {response.status_code}")
