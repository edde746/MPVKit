#include <stdbool.h>
#include <stdio.h>
#include <assert.h>
#include <stdarg.h>

struct priv { bool spdif; bool multichannel_supported; };
struct ao   { struct priv *priv; };

static bool g_route_supported;
static int  g_spdif_reload_calls;
static int  g_ao_reload_calls;

static void log_sink(const char *fmt, ...) { (void)fmt; }
#define MP_WARN(ao, ...) log_sink(__VA_ARGS__)
#define MP_INFO(ao, ...) log_sink(__VA_ARGS__)
static bool spdif_route_supports_multichannel(struct ao *ao) { (void)ao; return g_route_supported; }
static void spdif_reload(struct ao *ao) { (void)ao; g_spdif_reload_calls++; }
static void ao_request_reload(struct ao *ao) { (void)ao; g_ao_reload_calls++; }

#include "extracted.inc"

static void reset(void) { g_spdif_reload_calls = 0; g_ao_reload_calls = 0; }

int main(void) {
    // 1. compressed audio, capability lost -> fall back to PCM exactly once
    { struct priv p = {.spdif = true, .multichannel_supported = true};
      struct ao ao = {&p}; reset(); g_route_supported = false;
      spdif_reevaluate_capabilities(&ao, "t");
      assert(g_spdif_reload_calls == 1 && g_ao_reload_calls == 0);
      // repeated notifications with no change must not reload again
      spdif_reevaluate_capabilities(&ao, "t");
      spdif_reevaluate_capabilities(&ao, "t");
      assert(g_spdif_reload_calls == 1); }

    // 2. compressed audio, capability unchanged -> no action
    { struct priv p = {.spdif = true, .multichannel_supported = true};
      struct ao ao = {&p}; reset(); g_route_supported = true;
      spdif_reevaluate_capabilities(&ao, "t");
      assert(g_spdif_reload_calls == 0 && g_ao_reload_calls == 0); }

    // 3. PCM, capability regained -> retry native audio exactly once
    { struct priv p = {.spdif = false, .multichannel_supported = false};
      struct ao ao = {&p}; reset(); g_route_supported = true;
      spdif_reevaluate_capabilities(&ao, "t");
      assert(g_ao_reload_calls == 1 && g_spdif_reload_calls == 0);
      spdif_reevaluate_capabilities(&ao, "t");
      assert(g_ao_reload_calls == 1); }

    // 4. PCM, capability lost -> nothing to do
    { struct priv p = {.spdif = false, .multichannel_supported = true};
      struct ao ao = {&p}; reset(); g_route_supported = false;
      spdif_reevaluate_capabilities(&ao, "t");
      assert(g_spdif_reload_calls == 0 && g_ao_reload_calls == 0); }

    // 5. flapping must not loop: each edge acts once, N cycles -> N reloads
    { struct priv p = {.spdif = true, .multichannel_supported = true};
      struct ao ao = {&p}; reset();
      for (int i = 0; i < 5; i++) {
          g_route_supported = false; spdif_reevaluate_capabilities(&ao, "t");
          g_route_supported = true;  spdif_reevaluate_capabilities(&ao, "t");
      }
      assert(g_spdif_reload_calls == 5);
      assert(g_ao_reload_calls == 0); }  // p.spdif stays true, so no upgrade path

    printf("all 5 capability-observer cases passed\n");
    return 0;
}
