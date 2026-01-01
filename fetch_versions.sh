#!/bin/bash

# McOne - Minecraft Version Fetcher
# Fetches available Minecraft server versions from official sources

VERSIONS_JSON="$SCRIPT_DIR/minecraft_versions.json"
CACHE_MAX_AGE=86400  # 24 hours in seconds

# Fetch versions from Mojang's official API
fetch_from_mojang() {
    echo "Fetching versions from Mojang API..." >&2
    
    if command -v curl &> /dev/null; then
        curl -s "https://launchermeta.mojang.com/mc/game/version_manifest.json" 2>/dev/null
    elif command -v wget &> /dev/null; then
        wget -qO- "https://launchermeta.mojang.com/mc/game/version_manifest.json" 2>/dev/null
    else
        return 1
    fi
}

# Fetch versions from vexyhost (fallback)
fetch_from_vexyhost() {
    echo "Fetching versions from vexyhost..." >&2
    
    local html=""
    if command -v curl &> /dev/null; then
        html=$(curl -s "https://jars.vexyhost.com/" 2>/dev/null)
    elif command -v wget &> /dev/null; then
        html=$(wget -qO- "https://jars.vexyhost.com/" 2>/dev/null)
    else
        return 1
    fi
    
    # Parse HTML to extract version info
    # This creates a simple JSON structure
    echo '{"versions":['
    echo "$html" | grep -oP 'href="/minecraft/\K[0-9.]+(?=/)' | sort -V -r | while IFS= read -r version; do
        echo "{\"id\":\"$version\",\"type\":\"release\",\"url\":\"https://jars.vexyhost.com/minecraft/$version/server.jar\"},"
    done | sed '$ s/,$//'
    echo ']}'
}

# Main function to get versions
get_versions() {
    local force_refresh=${1:-false}
    
    # Check if cache exists and is recent
    if [ -f "$VERSIONS_JSON" ] && [ "$force_refresh" != "true" ]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$VERSIONS_JSON" 2>/dev/null || stat -f %m "$VERSIONS_JSON" 2>/dev/null || echo 0)))
        if [ $cache_age -lt $CACHE_MAX_AGE ]; then
            cat "$VERSIONS_JSON"
            return 0
        fi
    fi
    
    # Try Mojang API first
    local manifest=$(fetch_from_mojang)
    
    if [ -n "$manifest" ] && echo "$manifest" | grep -q '"versions"'; then
        # Extract release versions only and format as our JSON
        echo "$manifest" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    versions = []
    for v in data.get('versions', []):
        if v.get('type') == 'release':
            version_id = v.get('id', '')
            # Fetch download URL
            versions.append({
                'id': version_id,
                'type': 'release',
                'url': v.get('url', '')
            })
    print(json.dumps({'versions': versions[:50]}, indent=2))  # Top 50 versions
except:
    pass
" 2>/dev/null > "$VERSIONS_JSON.tmp"
        
        if [ -s "$VERSIONS_JSON.tmp" ]; then
            mv "$VERSIONS_JSON.tmp" "$VERSIONS_JSON"
            cat "$VERSIONS_JSON"
            return 0
        fi
        rm -f "$VERSIONS_JSON.tmp"
    fi
    
    # Fallback to vexyhost
    local vexy_data=$(fetch_from_vexyhost)
    if [ -n "$vexy_data" ]; then
        echo "$vexy_data" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(json.dumps(data, indent=2))
except:
    pass
" 2>/dev/null > "$VERSIONS_JSON.tmp"
        
        if [ -s "$VERSIONS_JSON.tmp" ]; then
            mv "$VERSIONS_JSON.tmp" "$VERSIONS_JSON"
            cat "$VERSIONS_JSON"
            return 0
        fi
        rm -f "$VERSIONS_JSON.tmp"
    fi
    
    return 1
}

# Get server download URL for a specific version
get_download_url() {
    local version=$1
    local versions_data=$2
    
    # Try to find in our data
    echo "$versions_data" | python3 -c "
import sys, json
version = '$version'
try:
    data = json.load(sys.stdin)
    for v in data.get('versions', []):
        if v.get('id') == version:
            url = v.get('url', '')
            if url:
                print(url)
                sys.exit(0)
    
    # If not found, construct likely URLs to try
    print(f'https://piston-data.mojang.com/v1/objects/UNKNOWN/server.jar')
except:
    pass
" 2>/dev/null
}
