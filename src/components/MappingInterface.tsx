import React, { useState } from "react";
import { supabase } from "../lib/supabase";
import {
  Search,
  Upload,
  Download,
  AlertCircle,
  CheckCircle,
  Loader2,
} from "lucide-react";

interface MappingResult {
  service: string;
  confidence: string;
  mapping_logic: string;
}

interface CsvRow {
  "Care Setting": string;
  "Systems of Care": string;
  "ICD Code": string;
  Service?: string;
  Confidence?: string;
  "Mapping Logic"?: string;
}

const careSettings = [
  { id: "1", name: "HEALTH STATION", table: "health_station_services_mapping" },
  { id: "2", name: "HOME", table: "home_services_mapping" },
  {
    id: "3",
    name: "AMBULATORY SERVICE CENTER",
    table: "ambulatory_service_center_services_mapping",
  },
  {
    id: "4",
    name: "SPECIALTY CARE CENTER",
    table: "specialty_care_center_services_mapping",
  },
  {
    id: "5",
    name: "EXTENDED CARE FACILITY",
    table: "extended_care_facility_services_mapping",
  },
  { id: "6", name: "HOSPITAL", table: "hospital_services_mapping" },
];

const systemsOfCare = [
  "Unplanned care",
  "Planned care",
  "Children and young people",
  "Complex, multi-morbid",
  "Chronic conditions",
  "Palliative care and support",
  "Wellness and longevity",
];

export function MappingInterface() {
  const [selectedSetting, setSelectedSetting] = useState<string>("");
  const [selectedSystem, setSelectedSystem] = useState<string>("");
  const [icdCode, setIcdCode] = useState<string>("");
  const [isSearching, setIsSearching] = useState(false);
  const [mappingResult, setMappingResult] = useState<MappingResult | null>(
    null
  );
  const [error, setError] = useState<string>("");
  const [csvData, setCsvData] = useState<CsvRow[]>([]);
  const [isProcessing, setIsProcessing] = useState(false);
  const [progress, setProgress] = useState(0);

  const getIcdPrefix = (icdCode: string): string => {
    // Extract the first part of the ICD code (e.g., "Z23" from "Z23 - ENCOUNTER FOR IMMUNIZATION")
    const cleanCode = icdCode.replace(/['"]/g, "").trim();
    const codeMatch = cleanCode.match(/^([A-Z]\d+)/i);
    return codeMatch ? codeMatch[1].toUpperCase() : cleanCode;
  };

  const processBatch = async (
    batch: CsvRow[],
    setting: { id: string; name: string; table: string }
  ) => {
    const promises = batch.map(async (row) => {
      try {
        const icdPrefix = getIcdPrefix(row["ICD Code"]);
        const { data, error: queryError } = await supabase
          .from(setting.table)
          .select("service, confidence, mapping_logic")
          .ilike("icd_code", `${icdPrefix}%`)
          .eq("systems_of_care", row["Systems of Care"])
          .limit(1);

        if (queryError) {
          console.error("Error querying mapping:", queryError);
          return row;
        }

        if (data && data[0]) {
          row.Service = data[0].service;
          row.Confidence = data[0].confidence;
          row["Mapping Logic"] = data[0].mapping_logic;
        }
        return row;
      } catch (err) {
        console.error("Error processing row:", err);
        return row;
      }
    });

    return await Promise.all(promises);
  };

  const handleFileUpload = async (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setIsProcessing(true);
    setProgress(0);
    setError("");

    const reader = new FileReader();
    reader.onload = async (e) => {
      try {
        const text = e.target?.result as string;
        const rows = text.split("\n").filter((row) => row.trim());
        const headers = rows[0].split(",");

        const parsedData: CsvRow[] = rows.slice(1).map((row) => {
          const values = row.split(",");
          return {
            "Care Setting": values[0]?.trim() || "",
            "Systems of Care": values[1]?.trim() || "",
            "ICD Code": values[2]?.trim() || "",
          };
        });

        setCsvData(parsedData);

        // Process in batches of 100
        const BATCH_SIZE = 100;
        const totalBatches = Math.ceil(parsedData.length / BATCH_SIZE);

        for (let i = 0; i < parsedData.length; i += BATCH_SIZE) {
          const batch = parsedData.slice(i, i + BATCH_SIZE);
          const setting = careSettings.find(
            (s) => s.name === batch[0]["Care Setting"]
          );

          if (!setting) {
            console.warn(
              `Invalid care setting for batch starting at index ${i}`
            );
            continue;
          }

          const processedBatch = await processBatch(batch, setting);

          setCsvData((prevData) => {
            const newData = [...prevData];
            processedBatch.forEach((row, index) => {
              newData[i + index] = row;
            });
            return newData;
          });

          // Update progress
          const currentBatch = Math.floor(i / BATCH_SIZE) + 1;
          setProgress((currentBatch / totalBatches) * 100);
        }
      } catch (err) {
        console.error("Error processing CSV:", err);
        setError(
          "Error processing CSV file. Please check the format and try again."
        );
      } finally {
        setIsProcessing(false);
        setProgress(100);
      }
    };

    reader.readAsText(file);
  };

  const handleSearch = async () => {
    if (!selectedSetting || !icdCode.trim()) {
      setError("Please select a care setting and enter an ICD code");
      return;
    }

    setIsSearching(true);
    setError("");
    setMappingResult(null);

    try {
      const setting = careSettings.find((s) => s.id === selectedSetting);
      if (!setting) {
        throw new Error("Invalid care setting");
      }

      const icdPrefix = getIcdPrefix(icdCode);
      let query = supabase
        .from(setting.table)
        .select("service, confidence, mapping_logic")
        .ilike("icd_code", `${icdPrefix}%`);

      if (selectedSystem) {
        query = query.eq("systems_of_care", selectedSystem);
      }

      const { data, error: queryError } = await query.limit(1);

      if (queryError) throw queryError;

      if (data && data.length > 0) {
        setMappingResult(data[0]);
      } else {
        setError("No mapping found for the given ICD code and settings");
      }
    } catch (err) {
      console.error("Error searching for mapping:", err);
      setError("An error occurred while searching. Please try again.");
    } finally {
      setIsSearching(false);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-sm p-8">
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label
              htmlFor="care-setting"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              Care Setting
            </label>
            <select
              id="care-setting"
              className="block w-full rounded-lg border border-gray-300 bg-white px-4 py-3 shadow-sm focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500"
              value={selectedSetting}
              onChange={(e) => setSelectedSetting(e.target.value)}
            >
              <option value="">Select a care setting...</option>
              {careSettings.map((setting) => (
                <option key={setting.id} value={setting.id}>
                  {setting.name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label
              htmlFor="system-of-care"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              System of Care
            </label>
            <select
              id="system-of-care"
              className="block w-full rounded-lg border border-gray-300 bg-white px-4 py-3 shadow-sm focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500"
              value={selectedSystem}
              onChange={(e) => setSelectedSystem(e.target.value)}
            >
              <option value="">Select a system of care...</option>
              {systemsOfCare.map((system) => (
                <option key={system} value={system}>
                  {system}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="flex gap-4">
          <div className="flex-1">
            <label
              htmlFor="icd-code"
              className="block text-sm font-medium text-gray-700 mb-2"
            >
              ICD-10 Code
            </label>
            <div className="relative">
              <input
                id="icd-code"
                type="text"
                className="block w-full rounded-lg border border-gray-300 bg-white px-4 py-3 pr-12 shadow-sm focus:border-emerald-500 focus:outline-none focus:ring-1 focus:ring-emerald-500"
                placeholder="Enter ICD-10 code"
                value={icdCode}
                onChange={(e) => setIcdCode(e.target.value)}
                onKeyPress={(e) => e.key === "Enter" && handleSearch()}
              />
              <button
                onClick={handleSearch}
                disabled={isSearching}
                className="absolute right-2 top-2.5 p-1.5 text-gray-400 hover:text-gray-600 focus:outline-none"
              >
                <Search className="h-5 w-5" />
              </button>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Bulk Upload
            </label>
            <input
              type="file"
              accept=".csv"
              onChange={handleFileUpload}
              disabled={isProcessing}
              className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-emerald-50 file:text-emerald-700 hover:file:bg-emerald-100"
            />
          </div>
        </div>

        {error && (
          <div className="flex items-center gap-2 text-red-600 text-sm">
            <AlertCircle className="h-4 w-4" />
            {error}
          </div>
        )}

        {isProcessing && (
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-emerald-600">
              <Loader2 className="h-4 w-4 animate-spin" />
              <span className="text-sm">
                Processing CSV file... {Math.round(progress)}%
              </span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-emerald-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>
        )}

        {mappingResult && (
          <div className="bg-emerald-50 rounded-lg p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Mapping Result
            </h3>
            <dl className="grid grid-cols-1 gap-4">
              <div>
                <dt className="text-sm font-medium text-gray-500">Service</dt>
                <dd className="mt-1 text-sm text-gray-900">
                  {mappingResult.service}
                </dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-gray-500">
                  Confidence
                </dt>
                <dd className="mt-1 text-sm text-gray-900">
                  {mappingResult.confidence}
                </dd>
              </div>
              <div>
                <dt className="text-sm font-medium text-gray-500">
                  Mapping Logic
                </dt>
                <dd className="mt-1 text-sm text-gray-900">
                  {mappingResult.mapping_logic}
                </dd>
              </div>
            </dl>
          </div>
        )}

        {csvData.length > 0 && (
          <div className="mt-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              Bulk Results
            </h3>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Care Setting
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Systems of Care
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      ICD Code
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Service
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Confidence
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Mapping Logic
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {csvData.map((row, index) => (
                    <tr key={index}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {row["Care Setting"]}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {row["Systems of Care"]}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {row["ICD Code"]}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {row.Service || "-"}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {row.Confidence || "-"}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {row["Mapping Logic"] || "-"}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
