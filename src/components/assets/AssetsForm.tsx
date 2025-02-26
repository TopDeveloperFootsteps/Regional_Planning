import React, { useState, useEffect } from "react";
import { useRegions } from "../../hooks/useRegions";
import { api } from "../../services/api";

interface Asset {
  id: string;
  region_id: string;
  asset_id: string;
  name: string;
  type: "Permanent" | "Temporary" | "PPP" | "MoH";
  owner:
    | "Neom"
    | "MoD"
    | "Construction Camp"
    | "AlBassam"
    | "Nessma"
    | "Tamasuk"
    | "Alfanar"
    | "Almutlaq"
    | "MoH";
  archetype:
    | "Family Health Center"
    | "Resort"
    | "Spoke"
    | "Field Hospital"
    | "N/A"
    | "Advance Health Center"
    | "Hub"
    | "First Aid Point"
    | "Clinic"
    | "Hospital";
  population_types: string[];
  start_date: string;
  end_date: string | null;
  latitude: number;
  longitude: number;
  gfa: number;
  status: string;
}

interface AssetsFormProps {
  initialAsset?: Asset | null;
}

const POPULATION_TYPES = [
  "Residents",
  "Staff",
  "Visitors/Tourists",
  "Construction Workers",
];

const ARCHETYPES = [
  "N/A",
  "Family Health Center",
  "Resort",
  "Spoke",
  "Field Hospital",
  "Advance Health Center",
  "Hub",
  "First Aid Point",
  "Clinic",
  "Hospital",
] as const;

const ASSET_TYPES = ["Permanent", "Temporary", "PPP", "MoH"] as const;

const OWNERS = [
  "Neom",
  "MoD",
  "Construction Camp",
  "AlBassam",
  "Nessma",
  "Tamasuk",
  "Alfanar",
  "Almutlaq",
  "MoH",
] as const;

// Sorted in logical project lifecycle order
const STATUSES = [
  "Not Started", // Initial state
  "Design", // Design phase
  "Planning", // Planning phase
  "Partially Operational", // Transition state
  "Operational", // Fully operational
  "Closed", // End of lifecycle
] as const;

export function AssetsForm({ initialAsset }: AssetsFormProps) {
  const { regions } = useRegions();
  const [formData, setFormData] = useState<Partial<Asset>>({
    population_types: [],
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isActive, setIsActive] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    if (initialAsset) {
      setFormData(initialAsset);
      setIsActive(initialAsset.status !== "Closed");
    } else {
      setFormData({ population_types: [] });
      setIsActive(true);
    }
    setErrors({});
  }, [initialAsset]);

  const generateAssetId = (regionId: string) => {
    return `Asset-${regionId}`;
  };

  const handleRegionChange = (regionId: string) => {
    setFormData((prev) => ({
      ...prev,
      region_id: regionId,
      asset_id: generateAssetId(regionId),
    }));
  };

  const handlePopulationTypeChange = (type: string) => {
    setFormData((prev) => {
      const types = prev.population_types || [];
      if (types.includes(type)) {
        return {
          ...prev,
          population_types: types.filter((t) => t !== type),
        };
      } else {
        return {
          ...prev,
          population_types: [...types, type],
        };
      }
    });
  };

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.region_id) newErrors.region_id = "Region is required";
    if (!formData.name) newErrors.name = "Asset name is required";
    if (!formData.type) newErrors.type = "Type is required";
    if (!formData.owner) newErrors.owner = "Owner is required";
    if (!formData.archetype) newErrors.archetype = "Archetype is required";
    if (!formData.population_types?.length)
      newErrors.population_types = "At least one population type is required";
    if (!formData.start_date) newErrors.start_date = "Start date is required";
    if (!formData.latitude) newErrors.latitude = "Latitude is required";
    if (!formData.longitude) newErrors.longitude = "Longitude is required";
    if (!formData.gfa) newErrors.gfa = "GFA is required";
    if (!formData.status) newErrors.status = "Status is required";

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) return;

    try {
      setIsSaving(true);

      // Update status based on isActive
      const dataToSave = {
        ...formData,
        status: isActive ? formData.status : "Closed",
      };

      const response = await api.post("/assets/assetsForm", dataToSave);
      // Reset form
      setFormData({ population_types: [] });
      setIsActive(true);
      setErrors({});
    } catch (error) {
      console.error("Error saving asset:", error);
      setErrors({ submit: "Failed to save asset" });
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Region Selection */}
      <div>
        <label className="block text-sm font-medium text-gray-700">
          Region
        </label>
        <select
          value={formData.region_id || ""}
          onChange={(e) => handleRegionChange(e.target.value)}
          className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
            errors.region_id
              ? "border-red-300 focus:border-red-500 focus:ring-red-500"
              : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
          }`}
        >
          <option value="">Select a region</option>
          {regions
            .filter((r) => r.status === "active")
            .map((region) => (
              <option key={region.id} value={region.id}>
                {region.name}
              </option>
            ))}
        </select>
        {errors.region_id && (
          <p className="mt-1 text-sm text-red-600">{errors.region_id}</p>
        )}
      </div>

      {/* Asset ID (Read-only) */}
      <div>
        <label className="block text-sm font-medium text-gray-700">
          Asset ID
        </label>
        <input
          type="text"
          value={formData.asset_id || ""}
          readOnly
          className="mt-1 block w-full rounded-md border-gray-300 bg-gray-50 shadow-sm sm:text-sm"
        />
      </div>

      {/* Asset Name */}
      <div>
        <label className="block text-sm font-medium text-gray-700">
          Asset Name
        </label>
        <input
          type="text"
          value={formData.name || ""}
          onChange={(e) =>
            setFormData((prev) => ({ ...prev, name: e.target.value }))
          }
          className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
            errors.name
              ? "border-red-300 focus:border-red-500 focus:ring-red-500"
              : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
          }`}
        />
        {errors.name && (
          <p className="mt-1 text-sm text-red-600">{errors.name}</p>
        )}
      </div>

      {/* Type of Asset */}
      <div>
        <label className="block text-sm font-medium text-gray-700">
          Type of Asset
        </label>
        <select
          value={formData.type || ""}
          onChange={(e) =>
            setFormData((prev) => ({
              ...prev,
              type: e.target.value as Asset["type"],
            }))
          }
          className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
            errors.type
              ? "border-red-300 focus:border-red-500 focus:ring-red-500"
              : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
          }`}
        >
          <option value="">Select type</option>
          {ASSET_TYPES.map((type) => (
            <option key={type} value={type}>
              {type}
            </option>
          ))}
        </select>
        {errors.type && (
          <p className="mt-1 text-sm text-red-600">{errors.type}</p>
        )}
      </div>

      {/* Owner */}
      <div>
        <label className="block text-sm font-medium text-gray-700">Owner</label>
        <select
          value={formData.owner || ""}
          onChange={(e) =>
            setFormData((prev) => ({
              ...prev,
              owner: e.target.value as Asset["owner"],
            }))
          }
          className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
            errors.owner
              ? "border-red-300 focus:border-red-500 focus:ring-red-500"
              : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
          }`}
        >
          <option value="">Select owner</option>
          {OWNERS.map((owner) => (
            <option key={owner} value={owner}>
              {owner}
            </option>
          ))}
        </select>
        {errors.owner && (
          <p className="mt-1 text-sm text-red-600">{errors.owner}</p>
        )}
      </div>

      {/* Asset Archetype */}
      <div>
        <label className="block text-sm font-medium text-gray-700">
          Asset Archetype (Care Level)
        </label>
        <select
          value={formData.archetype || ""}
          onChange={(e) =>
            setFormData((prev) => ({
              ...prev,
              archetype: e.target.value as Asset["archetype"],
            }))
          }
          className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
            errors.archetype
              ? "border-red-300 focus:border-red-500 focus:ring-red-500"
              : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
          }`}
        >
          <option value="">Select archetype</option>
          {ARCHETYPES.map((archetype) => (
            <option key={archetype} value={archetype}>
              {archetype}
            </option>
          ))}
        </select>
        {errors.archetype && (
          <p className="mt-1 text-sm text-red-600">{errors.archetype}</p>
        )}
      </div>

      {/* Population Types */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Population Type
        </label>
        <div className="space-y-2">
          {POPULATION_TYPES.map((type) => (
            <label key={type} className="flex items-center">
              <input
                type="checkbox"
                checked={formData.population_types?.includes(type) || false}
                onChange={() => handlePopulationTypeChange(type)}
                className="h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-gray-300 rounded"
              />
              <span className="ml-2 text-sm text-gray-700">{type}</span>
            </label>
          ))}
        </div>
        {errors.population_types && (
          <p className="mt-1 text-sm text-red-600">{errors.population_types}</p>
        )}
      </div>

      {/* Dates */}
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">
            Start Date
          </label>
          <input
            type="date"
            min="2017-01-01"
            value={formData.start_date || ""}
            onChange={(e) =>
              setFormData((prev) => ({ ...prev, start_date: e.target.value }))
            }
            className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
              errors.start_date
                ? "border-red-300 focus:border-red-500 focus:ring-red-500"
                : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
            }`}
          />
          {errors.start_date && (
            <p className="mt-1 text-sm text-red-600">{errors.start_date}</p>
          )}
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">
            End Date
          </label>
          <input
            type="date"
            min={formData.start_date || "2017-01-01"}
            value={formData.end_date || ""}
            onChange={(e) =>
              setFormData((prev) => ({ ...prev, end_date: e.target.value }))
            }
            className="mt-1 block w-full rounded-md border-gray-300 focus:border-emerald-500 focus:ring-emerald-500 shadow-sm sm:text-sm"
          />
        </div>
      </div>

      {/* Coordinates */}
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">
            Latitude
          </label>
          <input
            type="number"
            step="any"
            value={formData.latitude || ""}
            onChange={(e) =>
              setFormData((prev) => ({
                ...prev,
                latitude: parseFloat(e.target.value),
              }))
            }
            className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
              errors.latitude
                ? "border-red-300 focus:border-red-500 focus:ring-red-500"
                : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
            }`}
          />
          {errors.latitude && (
            <p className="mt-1 text-sm text-red-600">{errors.latitude}</p>
          )}
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">
            Longitude
          </label>
          <input
            type="number"
            step="any"
            value={formData.longitude || ""}
            onChange={(e) =>
              setFormData((prev) => ({
                ...prev,
                longitude: parseFloat(e.target.value),
              }))
            }
            className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
              errors.longitude
                ? "border-red-300 focus:border-red-500 focus:ring-red-500"
                : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
            }`}
          />
          {errors.longitude && (
            <p className="mt-1 text-sm text-red-600">{errors.longitude}</p>
          )}
        </div>
      </div>

      {/* GFA */}
      <div>
        <label className="block text-sm font-medium text-gray-700">
          GFA (sqm)
        </label>
        <input
          type="number"
          min="0"
          step="0.01"
          value={formData.gfa || ""}
          onChange={(e) =>
            setFormData((prev) => ({
              ...prev,
              gfa: parseFloat(e.target.value),
            }))
          }
          className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
            errors.gfa
              ? "border-red-300 focus:border-red-500 focus:ring-red-500"
              : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
          }`}
        />
        {errors.gfa && (
          <p className="mt-1 text-sm text-red-600">{errors.gfa}</p>
        )}
      </div>

      {/* Status */}
      <div>
        <label className="block text-sm font-medium text-gray-700">
          Status
        </label>
        <select
          value={formData.status || ""}
          onChange={(e) =>
            setFormData((prev) => ({ ...prev, status: e.target.value }))
          }
          className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
            errors.status
              ? "border-red-300 focus:border-red-500 focus:ring-red-500"
              : "border-gray-300 focus:border-emerald-500 focus:ring-emerald-500"
          }`}
          disabled={!isActive}
        >
          <option value="">Select status</option>
          {STATUSES.map((status) => (
            <option key={status} value={status}>
              {status}
            </option>
          ))}
        </select>
        {errors.status && (
          <p className="mt-1 text-sm text-red-600">{errors.status}</p>
        )}
      </div>

      {/* Active Status Checkbox */}
      <div className="flex items-center space-x-2">
        <input
          type="checkbox"
          id="isActive"
          checked={isActive}
          onChange={(e) => setIsActive(e.target.checked)}
          className="h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-gray-300 rounded"
        />
        <label htmlFor="isActive" className="text-sm font-medium text-gray-700">
          Asset is active
        </label>
      </div>

      {/* Submit Button */}
      <div>
        <button
          type="submit"
          disabled={isSaving}
          className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-emerald-600 hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 disabled:opacity-50"
        >
          {isSaving
            ? "Saving..."
            : initialAsset
            ? "Update Asset"
            : "Save Asset"}
        </button>
      </div>

      {errors.submit && (
        <p className="text-sm text-red-600 text-center">{errors.submit}</p>
      )}
    </form>
  );
}
