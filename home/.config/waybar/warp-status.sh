#!/bin/sh
if systemctl is-active --quiet cloudflare-warp; then
    printf '{"text":"WARP","class":"active","tooltip":"cloudflare-warp: active"}\n'
else
    printf '{"text":"WARP","class":"inactive","tooltip":"cloudflare-warp: inactive"}\n'
fi
