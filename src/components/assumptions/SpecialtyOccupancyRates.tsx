import React, { useState, useEffect } from "react";
import { api } from "../../services/api";
import { Table } from "lucide-react";

interface SpecialtyOccupancyRate {
  id: string;
  care_setting: string;
  specialty: string;
  virtual_rate: number;
  inperson_rate: number;
}

interface EditableNumberCellProps {
  value: number;
  onChange: (value: number) => void;
}

const EditableNumberCell: React.FC<EditableNumberCellProps> = ({
  value,
  onChange,
}) => (
  <input
    type="number"
    min="0"
    max="100"
    value={Math.round(value * 100)}
    onChange={(e) => onChange(Number(e.target.value) / 100)}
    className="w-20 px-2 py-1 text-sm border rounded focus:outline-none focus:ring-1 focus:ring-emerald-500"
  />
);

export function SpecialtyOccupancyRates() {
  const [rates, setRates] = useState<SpecialtyOccupancyRate[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedSetting, setSelectedSetting] =
    useState<string>("Primary Care");

  useEffect(() => {
    fetchRates();
  }, [selectedSetting]);

  const fetchRates = async () => {
    try {
      setLoading(true);
      const response = await api.get(
        `/assumptions/specialty_occupancy_rates?care_setting=${selectedSetting}`
      );
      setRates(response || []);
    } catch (err) {
      console.error("Error fetching specialty occupancy rates:", err);
      setError("Failed to load visit percentages");
    } finally {
      setLoading(false);
    }
  };

  const handleRateChange = async (
    id: string,
    field: "virtual_rate" | "inperson_rate",
    value: number
  ) => {
    try {
      const response = await api.put(
        `/assumptions/specialty_occupancy_rates/${id}`,
        {
          field,
          value,
        }
      );

      setRates((prev) =>
        prev.map((rate) =>
          rate.id === id ? { ...rate, [field]: value } : rate
        )
      );
    } catch (err) {
      console.error("Error updating rate:", err);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-24">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  if (error) {
    return <div className="text-red-600 p-4">{error}</div>;
  }

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-2">
          <Table className="h-6 w-6 text-emerald-600" />
          <h2 className="text-lg font-semibold text-gray-900">
            Inperson to Virtual Visit Percentages
          </h2>
        </div>
        <select
          value={selectedSetting}
          onChange={(e) => setSelectedSetting(e.target.value)}
          className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
        >
          <option value="Primary Care">Primary Care</option>
          <option value="Specialist Outpatient Care">
            Specialist Outpatient Care
          </option>
          <option value="Emergency Care">Emergency Care</option>
        </select>
      </div>

      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Specialty
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Virtual Visit %
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Inperson Visit %
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {rates.map((rate) => (
              <tr key={rate.id}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {rate.specialty}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="space-y-2">
                    <div className="flex items-center space-x-2">
                      <EditableNumberCell
                        value={rate.virtual_rate}
                        onChange={(value) =>
                          handleRateChange(rate.id, "virtual_rate", value)
                        }
                      />
                      <span className="text-sm text-gray-500">%</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-blue-500 h-2 rounded-full transition-all duration-300"
                        style={{ width: `${rate.virtual_rate * 100}%` }}
                      />
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="space-y-2">
                    <div className="flex items-center space-x-2">
                      <EditableNumberCell
                        value={rate.inperson_rate}
                        onChange={(value) =>
                          handleRateChange(rate.id, "inperson_rate", value)
                        }
                      />
                      <span className="text-sm text-gray-500">%</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-emerald-500 h-2 rounded-full transition-all duration-300"
                        style={{ width: `${rate.inperson_rate * 100}%` }}
                      />
                    </div>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
