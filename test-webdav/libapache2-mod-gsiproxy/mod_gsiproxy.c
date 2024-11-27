#include "http_core.h"
#include "openssl/ssl.h"
#include "openssl/x509.h"
#include "mod_ssl.h"

extern module AP_MODULE_DECLARE_DATA ssl_module;

#ifndef BOOL
#define BOOL unsigned int
#endif

typedef struct {
    void    *sc;
    SSL_CTX *ssl_ctx;
} modssl_ctx_t;

typedef enum {
    SSL_ENABLED_UNSET    = -1,
    SSL_ENABLED_FALSE    = 0,
    SSL_ENABLED_TRUE     = 1,
    SSL_ENABLED_OPTIONAL = 3
} ssl_enabled_t;

typedef struct {
    void            *mc;
    ssl_enabled_t    enabled;
    BOOL             proxy_enabled;
    const char      *vhost_id;
    int              vhost_id_len;
    int              session_cache_timeout;
    BOOL             cipher_server_pref;
    BOOL             insecure_reneg;
    modssl_ctx_t    *server;
    modssl_ctx_t    *proxy;
} SSLSrvConfigRec;

int hook_post_config(apr_pool_t *p, apr_pool_t *plog, apr_pool_t *ptemp, server_rec *base_server)
{
    SSLSrvConfigRec *sc;
    server_rec *s;
    for (s = base_server; s; s = s->next) {
        sc = (SSLSrvConfigRec *)ap_get_module_config(s->module_config,  &ssl_module);
        if (sc && sc->enabled && sc->server && sc->server->ssl_ctx){
            X509_VERIFY_PARAM *param = SSL_CTX_get0_param(sc->server->ssl_ctx);
            X509_VERIFY_PARAM_set_flags(param, X509_V_FLAG_ALLOW_PROXY_CERTS);
        }
    }
    return OK;
}

static void register_hooks(apr_pool_t *pool)
{
    static const char * const dep[] = { "mod_ssl.c", NULL };
    ap_hook_post_config(hook_post_config, dep, NULL, APR_HOOK_MIDDLE);
}

module AP_MODULE_DECLARE_DATA gsi_proxy_certs_module =
{
    STANDARD20_MODULE_STUFF,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    register_hooks
};
