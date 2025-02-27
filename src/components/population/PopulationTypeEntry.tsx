import React, { useState, useEffect } from "react";
import { api } from "../../services/api";
import { Table } from "lucide-react";

interface PopulationData {
  id: string;
  region_id: string;
  population_type: string;
  default_factor: number;
  divisor: number;
  years: Record<
    string,
    {
      population: number | null;
      calculated_value: number | null;
    }
  >;
}

interface PopulationTypeEntryProps {
  selectedRegion: string;
}

const YEARS = Array.from({ length: 16 }, (_, i) => 2025 + i);
const POPULATION_TYPES = [
  "Staff",
  "Residents",
  "Tourists/Visit",
  "Same day Visitor",
  "Construction Worker",
];

// Define default factors and divisors for each population type
const getDefaultValues = (type: string) => {
  switch (type) {
    case "Tourists/Visit":
      return { default_factor: 3.7, divisor: 270 };
    case "Same day Visitor":
      return { default_factor: 1, divisor: 365 };
    case "Staff":
      return { default_factor: 1, divisor: 365 };
    case "Residents":
      return { default_factor: 1, divisor: 365 };
    case "Construction Worker":
      return { default_factor: 1, divisor: 365 };
    default:
      return { default_factor: 1, divisor: 365 };
  }
};

export function PopulationTypeEntry({
  selectedRegion,
}: PopulationTypeEntryProps) {
  const [data, setData] = useState<PopulationData[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (selectedRegion) {
      fetchPopulationData();
    }
  }, [selectedRegion]);

  const fetchPopulationData = async () => {
    try {
      setLoading(true);
      const response = await api.get(
        `/population/populationData?region_id=${selectedRegion}`
      );
      const fetchedData = response;

      // Initialize data for all population types
      const initializedData = POPULATION_TYPES.map((type) => {
        const existingData = fetchedData.find(
          (item) => item.population_type === type
        );
        const defaultValues = getDefaultValues(type);

        if (existingData) {
          return {
            ...existingData,
            years: Object.fromEntries(
              YEARS.map((year) => [
                year.toString(),
                {
                  population: existingData[`year_${year}`] || null,
                  calculated_value: existingData[`year_${year}`]
                    ? (existingData[`year_${year}`] *
                        existingData.default_factor) /
                      existingData.divisor
                    : null,
                },
              ])
            ),
          };
        } else {
          // Create empty data structure for population types without data
          return {
            id: "",
            region_id: selectedRegion,
            population_type: type,
            default_factor: defaultValues.default_factor,
            divisor: defaultValues.divisor,
            years: Object.fromEntries(
              YEARS.map((year) => [
                year.toString(),
                {
                  population: null,
                  calculated_value: null,
                },
              ])
            ),
          };
        }
      });

      setData(initializedData);
    } catch (err) {
      console.error("Error fetching population data:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleFactorChange = async (
    populationType: string,
    field: "default_factor" | "divisor",
    value: string
  ) => {
    const numValue = parseFloat(value) || 0;

    try {
      const record = data.find((d) => d.population_type === populationType);

      if (record?.id) {
        // Update existing record
        const { data: updatedRecord } = await api.put(
          `/population/population_data/${record.id}`,
          {
            field,
            value: numValue,
          }
        );

        // Update local state and recalculate values
        setData((prevData) =>
          prevData.map((row) => {
            if (row.population_type === populationType) {
              const updatedRow = {
                ...row,
                [field]: numValue,
                years: { ...row.years },
              };

              // Recalculate all values with new factor/divisor
              Object.keys(updatedRow.years).forEach((year) => {
                const population = updatedRow.years[year].population;
                if (population !== null) {
                  updatedRow.years[year].calculated_value =
                    (population *
                      (field === "default_factor"
                        ? numValue
                        : row.default_factor)) /
                    (field === "divisor" ? numValue : row.divisor);
                }
              });

              return updatedRow;
            }
            return row;
          })
        );
      }
    } catch (err) {
      console.error("Error updating factor:", err);
    }
  };

  const handleValueChange = async (
    populationType: string,
    year: number,
    value: string
  ) => {
    const numValue = parseInt(value) || 0;
    const record = data.find((d) => d.population_type === populationType);
    const default_factor =
      record?.default_factor || getDefaultValues(populationType).default_factor;
    const divisor = record?.divisor || getDefaultValues(populationType).divisor;

    try {
      if (record?.id) {
        // Update existing record
        await api.put(`/population/population_data/${record.id}`, {
          year,
          value: numValue,
        });

        // Update local state
        setData((prevData) =>
          prevData.map((row) =>
            row.population_type === populationType
              ? {
                  ...row,
                  years: {
                    ...row.years,
                    [year]: {
                      population: numValue,
                      calculated_value: (numValue * default_factor) / divisor,
                    },
                  },
                }
              : row
          )
        );
      } else {
        // Create new record
        const { data: newRecord } = await api.post(
          "/population/population_data",
          {
            region_id: selectedRegion,
            population_type: populationType,
            default_factor,
            divisor,
            [`year_${year}`]: numValue,
          }
        );

        // Update local state with the new record
        setData((prevData) =>
          prevData.map((row) =>
            row.population_type === populationType
              ? {
                  ...row,
                  id: newRecord.id,
                  years: {
                    ...row.years,
                    [year]: {
                      population: numValue,
                      calculated_value: (numValue * default_factor) / divisor,
                    },
                  },
                }
              : row
          )
        );
      }
    } catch (err) {
      console.error("Error updating population data:", err);
    }
  };

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center space-x-2 mb-6">
        <Table className="h-6 w-6 text-emerald-600" />
        <h2 className="text-lg font-semibold text-gray-900">
          Region Population Data
        </h2>
      </div>

      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider sticky left-0 bg-gray-50">
                Population Type
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Default Factor
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Division Factor
              </th>
              {YEARS.map((year) => (
                <th
                  key={year}
                  className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                >
                  {year}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {data.map((rowData) => (
              <tr key={rowData.population_type}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 sticky left-0 bg-white">
                  {rowData.population_type}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <input
                    type="number"
                    step="0.1"
                    value={rowData.default_factor}
                    onChange={(e) =>
                      handleFactorChange(
                        rowData.population_type,
                        "default_factor",
                        e.target.value
                      )
                    }
                    className="w-24 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                  />
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <input
                    type="number"
                    value={rowData.divisor}
                    onChange={(e) =>
                      handleFactorChange(
                        rowData.population_type,
                        "divisor",
                        e.target.value
                      )
                    }
                    className="w-24 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                  />
                </td>
                {YEARS.map((year) => (
                  <td
                    key={year}
                    className="px-6 py-4 whitespace-nowrap text-sm text-gray-500"
                  >
                    <input
                      type="number"
                      value={rowData.years[year]?.population || ""}
                      onChange={(e) =>
                        handleValueChange(
                          rowData.population_type,
                          year,
                          e.target.value
                        )
                      }
                      className="w-24 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                    />
                    {rowData.years[year]?.calculated_value !== null && (
                      <div className="text-xs text-gray-400 mt-1">
                        Calculated:{" "}
                        {Math.round(rowData.years[year].calculated_value!)}
                      </div>
                    )}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
