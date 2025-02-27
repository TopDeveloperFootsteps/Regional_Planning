import React, { useState } from "react";
import { UploadCloud, Table, AlertCircle, Save } from "lucide-react";
import { api } from "../../services/api";
import { Planning } from "./Planning";

interface CapacityRequirement {
  careType: string;
  reasonForVisit: string;
  capacityType: string;
  inperson: number;
  virtual: number;
}

interface ActivityDemand {
  careType: string;
  reasonForVisit: string;
  capacityType: string;
  inperson: number;
  virtual: number;
}

interface PlanDetails {
  name: string;
  population: number;
  date: string;
}

type TabType = "analysis" | "planning";

export function DCOutputAnalysis() {
  const [activeTab, setActiveTab] = useState<TabType>("analysis");
  const [capacityData, setCapacityData] = useState<CapacityRequirement[]>([]);
  const [activityData, setActivityData] = useState<ActivityDemand[]>([]);
  const [capacityError, setCapacityError] = useState<string>("");
  const [activityError, setActivityError] = useState<string>("");
  const [debugInfo, setDebugInfo] = useState<{
    headers: string[];
    separator: string;
  }>();
  const [planDetails, setPlanDetails] = useState<PlanDetails>({
    name: "",
    population: 0,
    date: new Date().toISOString().split("T")[0],
  });
  const [isSaving, setIsSaving] = useState(false);
  const [saveError, setSaveError] = useState<string>("");

  const parseCSV = (text: string) => {
    const rows = text.split("\n");
    const separator = rows[0].includes("\t") ? "\t" : ",";
    const headers = rows[0].split(separator).map((h) => h.trim());

    setDebugInfo({ headers, separator });

    const expectedHeaders = [
      "Care Type",
      "Reason for Visit / Specialty",
      "Capacity Type",
      "Inperson",
      "Virtual",
    ];

    const missingHeaders = expectedHeaders.filter(
      (header) => !headers.includes(header)
    );
    if (missingHeaders.length > 0) {
      throw new Error(
        `Missing required columns: ${missingHeaders.join(
          ", "
        )}\n\nDetected columns: ${headers.join(", ")}`
      );
    }

    return rows
      .slice(1)
      .filter((row) => row.trim())
      .map((row) => {
        const columns = row.split(separator).map((col) => col.trim());
        return {
          careType: columns[0],
          reasonForVisit: columns[1],
          capacityType: columns[2],
          inperson: parseFloat(columns[3]) || 0,
          virtual: parseFloat(columns[4]) || 0,
        };
      });
  };

  const handleCapacityFileUpload = (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const file = event.target.files?.[0];
    setCapacityError("");
    setDebugInfo(undefined);
    setSaveError("");

    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        try {
          const text = e.target?.result as string;
          const data = parseCSV(text);
          setCapacityData(data);
        } catch (err) {
          setCapacityError(
            err instanceof Error ? err.message : "Error processing file"
          );
        }
      };
      reader.readAsText(file);
    }
  };

  const handleActivityFileUpload = (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const file = event.target.files?.[0];
    setActivityError("");
    setDebugInfo(undefined);
    setSaveError("");

    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        try {
          const text = e.target?.result as string;
          const data = parseCSV(text);
          setActivityData(data);
        } catch (err) {
          setActivityError(
            err instanceof Error ? err.message : "Error processing file"
          );
        }
      };
      reader.readAsText(file);
    }
  };

  const handleSave = async () => {
    if (!planDetails.name || planDetails.population <= 0) {
      setSaveError("Please enter a plan name and valid population number");
      return;
    }

    if (capacityData.length === 0 && activityData.length === 0) {
      setSaveError("Please upload at least one data file");
      return;
    }

    setIsSaving(true);
    setSaveError("");

    try {
      const response = await api.post("/api/dc_plans", {
        name: planDetails.name,
        population: planDetails.population,
        date: planDetails.date,
        capacity_data: capacityData,
        activity_data: activityData,
      });

      console.log(response);

      // Reset form
      setPlanDetails({
        name: "",
        population: 0,
        date: new Date().toISOString().split("T")[0],
      });
      setCapacityData([]);
      setActivityData([]);
      setDebugInfo(undefined);

      alert("Plan saved successfully!");
    } catch (error) {
      console.error("Error saving plan:", error);
      setSaveError("Failed to save plan. Please try again.");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="space-y-8">
      {/* Tabs */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8">
            <button
              onClick={() => setActiveTab("analysis")}
              className={`${
                activeTab === "analysis"
                  ? "border-emerald-500 text-emerald-600"
                  : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm`}
            >
              Analysis
            </button>
            <button
              onClick={() => setActiveTab("planning")}
              className={`${
                activeTab === "planning"
                  ? "border-emerald-500 text-emerald-600"
                  : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              } whitespace-nowrap pb-4 px-1 border-b-2 font-medium text-sm`}
            >
              Planning
            </button>
          </nav>
        </div>
      </div>

      {/* Tab Content */}
      {activeTab === "analysis" ? (
        <>
          {/* Plan Details */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-6">
              Plan Details
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Plan Name
                </label>
                <input
                  type="text"
                  value={planDetails.name}
                  onChange={(e) =>
                    setPlanDetails((prev) => ({
                      ...prev,
                      name: e.target.value,
                    }))
                  }
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
                  placeholder="Enter plan name"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Population
                </label>
                <input
                  type="number"
                  value={planDetails.population || ""}
                  onChange={(e) =>
                    setPlanDetails((prev) => ({
                      ...prev,
                      population: parseInt(e.target.value) || 0,
                    }))
                  }
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
                  placeholder="Enter population number"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Date
                </label>
                <input
                  type="date"
                  value={planDetails.date}
                  onChange={(e) =>
                    setPlanDetails((prev) => ({
                      ...prev,
                      date: e.target.value,
                    }))
                  }
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
                />
              </div>
            </div>
          </div>

          {/* Required Columns Info */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center space-x-2 text-gray-600 mb-4">
              <AlertCircle className="h-5 w-5" />
              <h3 className="font-medium">Required CSV/TSV File Format</h3>
            </div>
            <div className="bg-gray-50 rounded-lg p-4">
              <p className="text-sm text-gray-600 mb-2">
                Your file must have these exact column headers:
              </p>
              <code className="block bg-gray-100 p-3 rounded text-sm font-mono text-gray-800">
                Care Type,Reason for Visit / Specialty,Capacity
                Type,Inperson,Virtual
              </code>
              <p className="text-sm text-gray-500 mt-2">
                Note: Headers are case-sensitive and must match exactly
              </p>
            </div>
          </div>

          {/* Debug Info */}
          {debugInfo && (
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h3 className="font-medium text-gray-900 mb-2">File Analysis</h3>
              <div className="space-y-2 text-sm text-gray-600">
                <p>
                  Detected separator:{" "}
                  {debugInfo.separator === "," ? "Comma (CSV)" : "Tab (TSV)"}
                </p>
                <p>Detected headers:</p>
                <ul className="list-disc list-inside pl-4 space-y-1">
                  {debugInfo.headers.map((header, i) => (
                    <li key={i} className="font-mono">
                      {header}
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          )}

          {/* Detailed Capacity Requirements Section */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Detailed Capacity Requirements
            </h2>

            {/* File Upload */}
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Upload Capacity Requirements File
              </label>
              <div className="flex items-center justify-center w-full">
                <label className="flex flex-col items-center justify-center w-full h-32 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-gray-50 hover:bg-gray-100">
                  <div className="flex flex-col items-center justify-center pt-5 pb-6">
                    <UploadCloud className="w-8 h-8 mb-4 text-gray-500" />
                    <p className="mb-2 text-sm text-gray-500">
                      <span className="font-semibold">Click to upload</span> or
                      drag and drop
                    </p>
                    <p className="text-xs text-gray-500">
                      CSV or TSV file with required columns
                    </p>
                  </div>
                  <input
                    type="file"
                    className="hidden"
                    accept=".csv,.tsv,.txt"
                    onChange={handleCapacityFileUpload}
                  />
                </label>
              </div>
              {capacityError && (
                <p className="mt-2 text-sm text-red-600 whitespace-pre-line">
                  {capacityError}
                </p>
              )}
            </div>

            {/* Capacity Data Table */}
            {capacityData.length > 0 && (
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Care Type
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Reason for Visit / Specialty
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Capacity Type
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Inperson
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Virtual
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {capacityData.map((row, index) => (
                      <tr key={index}>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.careType}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.reasonForVisit}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.capacityType}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.inperson.toLocaleString(undefined, {
                            maximumFractionDigits: 2,
                          })}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.virtual.toLocaleString(undefined, {
                            maximumFractionDigits: 2,
                          })}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>

          {/* Detailed Activity/Demand Section */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Detailed Activity/Demand
            </h2>

            {/* File Upload */}
            <div className="mb-6">
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Upload Activity/Demand File
              </label>
              <div className="flex items-center justify-center w-full">
                <label className="flex flex-col items-center justify-center w-full h-32 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-gray-50 hover:bg-gray-100">
                  <div className="flex flex-col items-center justify-center pt-5 pb-6">
                    <UploadCloud className="w-8 h-8 mb-4 text-gray-500" />
                    <p className="mb-2 text-sm text-gray-500">
                      <span className="font-semibold">Click to upload</span> or
                      drag and drop
                    </p>
                    <p className="text-xs text-gray-500">
                      CSV or TSV file with required columns
                    </p>
                  </div>
                  <input
                    type="file"
                    className="hidden"
                    accept=".csv,.tsv,.txt"
                    onChange={handleActivityFileUpload}
                  />
                </label>
              </div>
              {activityError && (
                <p className="mt-2 text-sm text-red-600 whitespace-pre-line">
                  {activityError}
                </p>
              )}
            </div>

            {/* Activity Data Table */}
            {activityData.length > 0 && (
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Care Type
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Reason for Visit / Specialty
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Capacity Type
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Inperson
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Virtual
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {activityData.map((row, index) => (
                      <tr key={index}>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.careType}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.reasonForVisit}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.capacityType}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.inperson.toLocaleString(undefined, {
                            maximumFractionDigits: 2,
                          })}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {row.virtual.toLocaleString(undefined, {
                            maximumFractionDigits: 2,
                          })}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>

          {/* Save Button */}
          {(capacityData.length > 0 || activityData.length > 0) && (
            <div className="flex flex-col items-end space-y-2">
              {saveError && <p className="text-sm text-red-600">{saveError}</p>}
              <button
                onClick={handleSave}
                disabled={
                  isSaving || !planDetails.name || planDetails.population <= 0
                }
                className="flex items-center space-x-2 px-4 py-2 bg-emerald-600 text-white rounded-md hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Save className="h-5 w-5" />
                <span>{isSaving ? "Saving..." : "Save Plan"}</span>
              </button>
            </div>
          )}
        </>
      ) : (
        <Planning />
      )}
    </div>
  );
}
