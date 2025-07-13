#!/usr/bin/env python3
"""
playground_geocoder.py

Add Google Maps addresses to an OSM playground GeoJSON.

USAGE
-----
python playground_geocoder.py input.geojson output.geojson --apikey YOUR_GOOGLE_API_KEY

OPTIONS
-------
--delay     Seconds to wait between API calls (default 0.1 to stay polite)
--language  Address language/locale (default "is" for Icelandic)
--retries   Number of retry attempts for failed requests (default 3)
--cache     Enable coordinate caching to avoid duplicate requests (default True)
--resume    Resume from a checkpoint file if processing was interrupted

The script
  • computes a representative lat/lon for every feature
  • hits the Google Geocoding API once per feature
  • injects the best address back into feature["properties"]["address"]
  • writes the enriched GeoJSON to disk

Requires: Python 3.8+, `pip install requests tqdm`
Google usage billed per request (see your account's quota/billing page).
"""

import argparse
import json
import statistics
import time
import logging
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
from tqdm import tqdm
import hashlib
import os


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('geocoding.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


class GeocodeCache:
    """Simple file-based cache for geocoding results."""
    
    def __init__(self, cache_file: str = ".geocode_cache.json"):
        self.cache_file = cache_file
        self.cache = self._load_cache()
    
    def _load_cache(self) -> Dict:
        try:
            if os.path.exists(self.cache_file):
                with open(self.cache_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
        except Exception as e:
            logger.warning(f"Could not load cache: {e}")
        return {}
    
    def _save_cache(self):
        try:
            with open(self.cache_file, 'w', encoding='utf-8') as f:
                json.dump(self.cache, f, ensure_ascii=False, indent=2)
        except Exception as e:
            logger.error(f"Could not save cache: {e}")
    
    def get_key(self, lat: float, lon: float) -> str:
        """Generate cache key for coordinates."""
        return hashlib.md5(f"{lat:.6f},{lon:.6f}".encode()).hexdigest()
    
    def get(self, lat: float, lon: float) -> Optional[Dict]:
        return self.cache.get(self.get_key(lat, lon))
    
    def set(self, lat: float, lon: float, result: Dict):
        self.cache[self.get_key(lat, lon)] = result
        self._save_cache()


def centroid(ring):
    """Simple centroid of a linear ring (average of vertices)."""
    if not ring:
        raise ValueError("Empty ring provided")
    lons = [p[0] for p in ring]
    lats = [p[1] for p in ring]
    return statistics.mean(lats), statistics.mean(lons)


def representative_point(geom):
    """Return (lat, lon) for Point, Polygon or MultiPolygon."""
    try:
        gtype = geom["type"]
        if gtype == "Point":
            lon, lat = geom["coordinates"]
            return lat, lon
        elif gtype == "Polygon":
            return centroid(geom["coordinates"][0])
        elif gtype == "MultiPolygon":
            centers = [centroid(p[0]) for p in geom["coordinates"]]
            lats, lons = zip(*centers)
            return statistics.mean(lats), statistics.mean(lons)
        else:
            raise ValueError(f"Unsupported geometry type: {gtype}")
    except (KeyError, IndexError, TypeError) as e:
        raise ValueError(f"Invalid geometry structure: {e}")


def create_session_with_retries(max_retries: int = 3) -> requests.Session:
    """Create a requests session with retry strategy."""
    session = requests.Session()
    retry_strategy = Retry(
        total=max_retries,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504],
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    return session


def geocode(lat: float, lon: float, api_key: str, language: str = "is", 
           session: Optional[requests.Session] = None, cache: Optional[GeocodeCache] = None) -> Optional[Dict]:
    """Geocode coordinates using Google Maps API with caching and retry logic."""
    
    # Check cache first
    if cache:
        cached_result = cache.get(lat, lon)
        if cached_result:
            logger.debug(f"Cache hit for {lat:.6f},{lon:.6f}")
            return cached_result
    
    if session is None:
        session = requests.Session()
    
    url = (
        "https://maps.googleapis.com/maps/api/geocode/json"
        f"?latlng={lat},{lon}&key={api_key}&language={language}"
    )
    
    try:
        r = session.get(url, timeout=15)
        r.raise_for_status()
        data = r.json()
        
        if data.get("status") == "OK" and data["results"]:
            best = data["results"][0]
            result = {
                "google_formatted": best["formatted_address"],
                "google_components": best["address_components"],
            }
            
            # Cache the result
            if cache:
                cache.set(lat, lon, result)
            
            return result
        elif data.get("status") == "ZERO_RESULTS":
            logger.warning(f"No results found for {lat:.6f},{lon:.6f}")
            return None
        elif data.get("status") == "OVER_QUERY_LIMIT":
            logger.error("Google API quota exceeded")
            raise Exception("API quota exceeded")
        else:
            logger.warning(f"Geocoding failed: {data.get('status')} for {lat:.6f},{lon:.6f}")
            return None
            
    except requests.exceptions.RequestException as e:
        logger.error(f"Network error geocoding {lat:.6f},{lon:.6f}: {e}")
        return None
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON response for {lat:.6f},{lon:.6f}: {e}")
        return None
    except Exception as e:
        logger.error(f"Unexpected error geocoding {lat:.6f},{lon:.6f}: {e}")
        return None


def save_checkpoint(features: List[Dict], processed_count: int, checkpoint_file: str):
    """Save processing checkpoint."""
    checkpoint = {
        "processed_count": processed_count,
        "features": features
    }
    try:
        with open(checkpoint_file, 'w', encoding='utf-8') as f:
            json.dump(checkpoint, f, ensure_ascii=False, indent=2)
        logger.info(f"Checkpoint saved: {processed_count} features processed")
    except Exception as e:
        logger.error(f"Could not save checkpoint: {e}")


def load_checkpoint(checkpoint_file: str) -> Optional[Tuple[List[Dict], int]]:
    """Load processing checkpoint."""
    try:
        if os.path.exists(checkpoint_file):
            with open(checkpoint_file, 'r', encoding='utf-8') as f:
                checkpoint = json.load(f)
                return checkpoint["features"], checkpoint["processed_count"]
    except Exception as e:
        logger.error(f"Could not load checkpoint: {e}")
    return None


def validate_geojson(geo: Dict) -> bool:
    """Basic validation of GeoJSON structure."""
    if not isinstance(geo, dict):
        return False
    if geo.get("type") != "FeatureCollection":
        logger.warning("Input is not a FeatureCollection")
        return False
    if not isinstance(geo.get("features"), list):
        logger.error("No features array found")
        return False
    return True


def main():
    ap = argparse.ArgumentParser(description="Reverse‑geocode playground layer with Google Maps")
    ap.add_argument("input", help="Input GeoJSON file")
    ap.add_argument("output", help="Output GeoJSON file")
    ap.add_argument("--apikey", required=True, help="Google Geocoding API key")
    ap.add_argument("--delay", type=float, default=0.1, help="Delay between requests (s)")
    ap.add_argument("--language", default="is", help="Locale for address strings (default 'is')")
    ap.add_argument("--retries", type=int, default=3, help="Number of retry attempts")
    ap.add_argument("--no-cache", action="store_true", help="Disable coordinate caching")
    ap.add_argument("--resume", help="Resume from checkpoint file")
    ap.add_argument("--checkpoint-interval", type=int, default=10, help="Save checkpoint every N features")
    args = ap.parse_args()

    # Validate input file
    input_path = Path(args.input)
    if not input_path.exists():
        logger.error(f"Input file not found: {args.input}")
        sys.exit(1)

    try:
        geo = json.loads(input_path.read_text(encoding="utf-8"))
    except Exception as e:
        logger.error(f"Could not read input file: {e}")
        sys.exit(1)

    if not validate_geojson(geo):
        logger.error("Invalid GeoJSON structure")
        sys.exit(1)

    feats = geo.get("features", [])
    if not feats:
        logger.warning("No features found in input file")
        sys.exit(0)

    # Initialize cache
    cache = None if args.no_cache else GeocodeCache()
    
    # Create session with retry logic
    session = create_session_with_retries(args.retries)
    
    # Handle resume functionality
    start_idx = 0
    checkpoint_file = args.resume or f".checkpoint_{Path(args.output).stem}.json"
    
    if args.resume and os.path.exists(checkpoint_file):
        checkpoint_data = load_checkpoint(checkpoint_file)
        if checkpoint_data:
            feats, start_idx = checkpoint_data
            logger.info(f"Resuming from checkpoint: {start_idx} features already processed")

    # Process features
    failed_count = 0
    processed_count = start_idx
    
    with tqdm(total=len(feats), initial=start_idx, desc="Geocoding") as pbar:
        for idx, f in enumerate(feats[start_idx:], start_idx):
            try:
                lat, lon = representative_point(f["geometry"])
                addr = geocode(lat, lon, args.apikey, language=args.language, 
                             session=session, cache=cache)
                
                if addr:
                    f.setdefault("properties", {})["address"] = addr
                    feature_id = f['properties'].get('@id', f'feature_{idx}')
                    logger.info(f"[{idx+1}/{len(feats)}] {feature_id} → {addr['google_formatted']}")
                else:
                    feature_id = f['properties'].get('@id', f'feature_{idx}')
                    logger.warning(f"[{idx+1}/{len(feats)}] {feature_id} → no result")
                    failed_count += 1
                
                processed_count += 1
                pbar.update(1)
                
                # Save checkpoint periodically
                if (processed_count - start_idx) % args.checkpoint_interval == 0:
                    save_checkpoint(feats, processed_count, checkpoint_file)
                
                time.sleep(args.delay)
                
            except Exception as e:
                logger.error(f"Error processing feature {idx}: {e}")
                failed_count += 1
                processed_count += 1
                pbar.update(1)
                continue

    # Save final output
    try:
        output_path = Path(args.output)
        output_path.write_text(json.dumps(geo, ensure_ascii=False, indent=2), encoding="utf-8")
        logger.info(f"✅  Saved {args.output}")
        
        # Clean up checkpoint file on successful completion
        if os.path.exists(checkpoint_file):
            os.remove(checkpoint_file)
            logger.info("Checkpoint file cleaned up")
            
    except Exception as e:
        logger.error(f"Could not save output file: {e}")
        sys.exit(1)

    # Summary
    success_count = len(feats) - failed_count
    logger.info(f"Processing complete: {success_count}/{len(feats)} features successfully geocoded")
    if failed_count > 0:
        logger.warning(f"{failed_count} features failed to geocode")


if __name__ == "__main__":
    main()
