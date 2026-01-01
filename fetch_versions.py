#!/usr/bin/env python3
"""
McOne - Minecraft Version Fetcher
Fetches available Minecraft server versions from multiple sources
"""

import json
import sys
import os
import time
import urllib.request
import urllib.error
from pathlib import Path

CACHE_FILE = "minecraft_versions.json"
CACHE_MAX_AGE = 86400  # 24 hours

def fetch_from_mojang():
    """Fetch versions from Mojang's official version manifest"""
    try:
        url = "https://launchermeta.mojang.com/mc/game/version_manifest.json"
        with urllib.request.urlopen(url, timeout=10) as response:
            data = json.loads(response.read().decode())
            versions = []
            
            # Get release versions only
            for version in data.get('versions', []):
                if version.get('type') == 'release':
                    version_id = version.get('id', '')
                    manifest_url = version.get('url', '')
                    
                    # Fetch the version manifest to get server download
                    try:
                        with urllib.request.urlopen(manifest_url, timeout=10) as ver_response:
                            ver_data = json.loads(ver_response.read().decode())
                            server_url = ver_data.get('downloads', {}).get('server', {}).get('url', '')
                            
                            if server_url:
                                versions.append({
                                    'id': version_id,
                                    'type': 'release',
                                    'url': server_url,
                                    'source': 'mojang'
                                })
                    except:
                        # If we can't fetch the manifest, just store the version ID
                        versions.append({
                            'id': version_id,
                            'type': 'release',
                            'url': '',
                            'source': 'mojang'
                        })
                    
                    # Limit to first 50 versions to speed up
                    if len(versions) >= 50:
                        break
            
            return versions
    except Exception as e:
        print(f"Error fetching from Mojang: {e}", file=sys.stderr)
        return None

def fetch_from_vexyhost():
    """Fetch versions from vexyhost as fallback"""
    try:
        url = "https://jars.vexyhost.com/"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        
        with urllib.request.urlopen(req, timeout=10) as response:
            html = response.read().decode('utf-8', errors='ignore')
            
            # Extract version numbers from the HTML
            import re
            pattern = r'href="/minecraft/([0-9.]+)/"'
            version_matches = re.findall(pattern, html)
            
            versions = []
            for version_id in sorted(set(version_matches), key=lambda x: [int(i) for i in x.split('.')], reverse=True):
                versions.append({
                    'id': version_id,
                    'type': 'release',
                    'url': f'https://jars.vexyhost.com/minecraft/{version_id}/server.jar',
                    'source': 'vexyhost'
                })
            
            return versions[:100]  # Limit to 100 versions
    except Exception as e:
        print(f"Error fetching from vexyhost: {e}", file=sys.stderr)
        return None

def load_cache():
    """Load cached versions if available and recent"""
    try:
        if not os.path.exists(CACHE_FILE):
            return None
        
        # Check cache age
        cache_age = time.time() - os.path.getmtime(CACHE_FILE)
        if cache_age > CACHE_MAX_AGE:
            return None
        
        with open(CACHE_FILE, 'r') as f:
            return json.load(f)
    except:
        return None

def save_cache(data):
    """Save versions to cache file"""
    try:
        with open(CACHE_FILE, 'w') as f:
            json.dump(data, f, indent=2)
        return True
    except Exception as e:
        print(f"Error saving cache: {e}", file=sys.stderr)
        return False

def get_versions(force_refresh=False):
    """Get available Minecraft versions from cache or fetch from sources"""
    
    # Try cache first
    if not force_refresh:
        cached = load_cache()
        if cached:
            return cached
    
    # Try Mojang API first
    print("Fetching Minecraft versions from official sources...", file=sys.stderr)
    versions = fetch_from_mojang()
    
    # Fallback to vexyhost if Mojang fails
    if not versions:
        print("Falling back to alternative source...", file=sys.stderr)
        versions = fetch_from_vexyhost()
    
    if versions:
        data = {'versions': versions, 'last_updated': int(time.time())}
        save_cache(data)
        return data
    
    return {'versions': [], 'last_updated': int(time.time())}

def find_version(version_id, versions_data):
    """Find a specific version in the data"""
    for version in versions_data.get('versions', []):
        if version['id'] == version_id:
            return version
    return None

def search_version_url(version_id):
    """Try to find download URL for a specific version from multiple sources"""
    
    # Try common URL patterns
    urls_to_try = [
        f"https://jars.vexyhost.com/minecraft/{version_id}/server.jar",
        f"https://launcher.mojang.com/v1/objects/UNKNOWN/server.jar",  # Would need hash
    ]
    
    for url in urls_to_try:
        try:
            req = urllib.request.Request(url, method='HEAD')
            with urllib.request.urlopen(req, timeout=5) as response:
                if response.status == 200:
                    return url
        except:
            continue
    
    return None

if __name__ == "__main__":
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "refresh":
            data = get_versions(force_refresh=True)
            print(json.dumps(data, indent=2))
        
        elif command == "list":
            data = get_versions()
            print(json.dumps(data, indent=2))
        
        elif command == "find":
            if len(sys.argv) > 2:
                version_id = sys.argv[2]
                data = get_versions()
                version = find_version(version_id, data)
                if version:
                    print(json.dumps(version, indent=2))
                else:
                    # Try to search for it
                    url = search_version_url(version_id)
                    if url:
                        print(json.dumps({'id': version_id, 'url': url, 'source': 'searched'}, indent=2))
                    else:
                        print(json.dumps({'error': 'Version not found'}, indent=2))
                        sys.exit(1)
        
        elif command == "latest":
            count = int(sys.argv[2]) if len(sys.argv) > 2 else 5
            data = get_versions()
            latest = data.get('versions', [])[:count]
            print(json.dumps({'versions': latest}, indent=2))
    else:
        data = get_versions()
        print(json.dumps(data, indent=2))
