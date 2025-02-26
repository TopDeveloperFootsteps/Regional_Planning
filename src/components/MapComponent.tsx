import { useRef, useEffect } from "react";
import "ol/ol.css";
import Map from "ol/Map";
import View from "ol/View";
import TileLayer from "ol/layer/Tile";
import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import OSM from "ol/source/OSM";
import Feature from "ol/Feature";
import Point from "ol/geom/Point";
import { fromLonLat } from "ol/proj";
import {
  Circle as CircleStyle,
  Fill,
  Stroke,
  Style,
  RegularShape,
} from "ol/style";

interface Region {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  status: "active" | "inactive";
}

interface SubRegion {
  id: string;
  region_id: string;
  name: string;
  latitude: number;
  longitude: number;
  status: "active" | "inactive";
}

interface Asset {
  id: string;
  name: string;
  type: string;
  owner: string;
  archetype: string;
  latitude: number;
  longitude: number;
  status: string;
}

interface MapSettings {
  show_circles: boolean;
  circle_transparency: number;
  circle_border: boolean;
  circle_radius_km: number;
}

interface MapComponentProps {
  regions: Region[];
  subRegions: SubRegion[];
  mapSettings: MapSettings;
  showInactive: boolean;
  assets?: Asset[];
  onRegionClick?: (region: Region) => void;
  onSubRegionClick?: (subRegion: SubRegion) => void;
  onAssetClick?: (asset: Asset) => void;
}

export function MapComponent({
  regions,
  subRegions,
  mapSettings,
  showInactive,
  assets = [],
  onRegionClick,
  onSubRegionClick,
  onAssetClick,
}: MapComponentProps) {
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<Map | null>(null);

  // Convert km to pixels for circle radius
  const kmToPixels = (km: number) => {
    return km * 3;
  };

  // Get color based on asset status
  const getStatusColor = (status: string) => {
    switch (status) {
      case "Operational":
        return "#059669"; // emerald-600
      case "Partially Operational":
        return "#D97706"; // amber-600
      case "Not Started":
        return "#6B7280"; // gray-500
      case "Design":
      case "Planning":
        return "#2563EB"; // blue-600
      default:
        return "#9CA3AF"; // gray-400
    }
  };

  // Create style function for features
  const createFeatureStyle = (feature: Feature) => {
    const featureType = feature.get("type");
    const featureData = feature.get("data");
    const circleRadius = kmToPixels(mapSettings.circle_radius_km);

    if (featureType === "asset") {
      const color = getStatusColor(featureData.status);
      const size = 12; // Base size for markers

      // Create different marker styles based on archetype
      switch (featureData.archetype) {
        case "Hospital":
          // Diamond shape for hospitals
          return new Style({
            image: new RegularShape({
              points: 4,
              radius: size,
              angle: Math.PI / 4,
              fill: new Fill({ color: color + "80" }),
              stroke: new Stroke({ color, width: 2 }),
            }),
          });

        case "Hub":
          // Hexagon for hubs
          return new Style({
            image: new RegularShape({
              points: 6,
              radius: size,
              fill: new Fill({ color: color + "80" }),
              stroke: new Stroke({ color, width: 2 }),
            }),
          });

        case "Spoke":
          // Star for spokes
          return new Style({
            image: new RegularShape({
              points: 5,
              radius: size,
              radius2: size / 2,
              fill: new Fill({ color: color + "80" }),
              stroke: new Stroke({ color, width: 2 }),
            }),
          });

        case "Family Health Center":
        case "Advance Health Center":
          // Square for health centers
          return new Style({
            image: new RegularShape({
              points: 4,
              radius: size,
              angle: 0,
              fill: new Fill({ color: color + "80" }),
              stroke: new Stroke({ color, width: 2 }),
            }),
          });

        case "First Aid Point":
          // Triangle for first aid points
          return new Style({
            image: new RegularShape({
              points: 3,
              radius: size,
              fill: new Fill({ color: color + "80" }),
              stroke: new Stroke({ color, width: 2 }),
            }),
          });

        case "Clinic":
          // Cross for clinics
          return new Style({
            image: new RegularShape({
              points: 4,
              radius: size,
              radius2: size / 3,
              angle: Math.PI / 4,
              fill: new Fill({ color: color + "80" }),
              stroke: new Stroke({ color, width: 2 }),
            }),
          });

        default:
          // Circle for other types
          return new Style({
            image: new CircleStyle({
              radius: size * 0.8,
              fill: new Fill({ color: color + "80" }),
              stroke: new Stroke({ color, width: 2 }),
            }),
          });
      }
    }

    // Default style for regions/subregions
    if (mapSettings.show_circles) {
      return new Style({
        image: new CircleStyle({
          radius: circleRadius,
          fill: new Fill({
            color: `rgba(16, 185, 129, ${
              mapSettings.circle_transparency / 100
            })`,
          }),
          stroke: mapSettings.circle_border
            ? new Stroke({
                color: "#059669",
                width: 2,
              })
            : undefined,
        }),
      });
    }

    // Fallback style
    return new Style({
      image: new CircleStyle({
        radius: 8,
        fill: new Fill({
          color:
            featureType === "region"
              ? "rgba(59, 130, 246, 0.8)"
              : "rgba(16, 185, 129, 0.8)",
        }),
        stroke: new Stroke({
          color: featureType === "region" ? "#2563EB" : "#059669",
          width: 2,
        }),
      }),
    });
  };

  // Initialize map
  useEffect(() => {
    if (!mapRef.current) return;

    // Create vector sources
    const vectorSource = new VectorSource();

    // Create vector layer
    const vectorLayer = new VectorLayer({
      source: vectorSource,
      style: createFeatureStyle,
    });

    // Create map instance
    const map = new Map({
      target: mapRef.current,
      layers: [
        new TileLayer({
          source: new OSM(),
        }),
        vectorLayer,
      ],
      view: new View({
        center: [0, 0],
        zoom: 2,
        minZoom: 2,
        maxZoom: 18,
      }),
    });

    mapInstanceRef.current = map;

    // Add click handler
    map.on("click", (event) => {
      const feature = map.forEachFeatureAtPixel(
        event.pixel,
        (feature) => feature
      );
      if (feature) {
        const type = feature.get("type");
        const data = feature.get("data");
        if (type === "region" && onRegionClick) {
          onRegionClick(data);
        } else if (type === "subregion" && onSubRegionClick) {
          onSubRegionClick(data);
        } else if (type === "asset" && onAssetClick) {
          onAssetClick(data);
        }
      }
    });

    // Add hover effect
    map.on("pointermove", (event) => {
      const pixel = map.getEventPixel(event.originalEvent);
      const hit = map.hasFeatureAtPixel(pixel);
      mapRef.current!.style.cursor = hit ? "pointer" : "";
    });

    return () => {
      map.setTarget(undefined);
    };
  }, []);

  // Update features when data changes
  useEffect(() => {
    if (!mapInstanceRef.current) return;

    const vectorSource = (
      mapInstanceRef.current
        .getLayers()
        .getArray()[1] as VectorLayer<VectorSource>
    ).getSource();
    if (!vectorSource) return;

    vectorSource.clear();

    // Add regions
    regions
      .filter((r) => showInactive || r.status === "active")
      .forEach((region) => {
        const feature = new Feature({
          geometry: new Point(fromLonLat([region.longitude, region.latitude])),
          type: "region",
          data: region,
        });
        vectorSource.addFeature(feature);
      });

    // Add subregions
    subRegions
      .filter((sr) => showInactive || sr.status === "active")
      .forEach((subRegion) => {
        const feature = new Feature({
          geometry: new Point(
            fromLonLat([subRegion.longitude, subRegion.latitude])
          ),
          type: "subregion",
          data: subRegion,
        });
        vectorSource.addFeature(feature);
      });

    // Add assets
    assets.forEach((asset) => {
      const feature = new Feature({
        geometry: new Point(fromLonLat([asset.longitude, asset.latitude])),
        type: "asset",
        data: asset,
      });
      vectorSource.addFeature(feature);
    });

    // Fit view to features
    if (vectorSource.getFeatures().length > 0) {
      const extent = vectorSource.getExtent();
      mapInstanceRef.current.getView().fit(extent, {
        padding: [50, 50, 50, 50],
        duration: 1000,
      });
    }
  }, [regions, subRegions, assets, showInactive, mapSettings]);

  return (
    <div ref={mapRef} className="w-full h-full rounded-lg overflow-hidden" />
  );
}
