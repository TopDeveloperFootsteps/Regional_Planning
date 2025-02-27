import React, { useState, useEffect } from "react";
import { api } from "../../services/api";
import { Table } from "lucide-react";

interface PopulationData {
  region_id: string;
  population_type: string;
  default_factor: number;
  divisor: number;
  [key: string]: any;
}

interface RegionInfo {
  id: string;
  name: string;
}

const YEARS = Array.from({ length: 16 }, (_, i) => 2025 + i);
const AGE_GROUPS = [
  "0 to 4",
  "5 to 19",
  "20 to 29",
  "30 to 44",
  "45 to 64",
  "65 to 125",
];

export function PopulationSummary() {
  const [populationData, setPopulationData] = useState<PopulationData[]>([]);
  const [regions, setRegions] = useState<RegionInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedRegion, setSelectedRegion] = useState<string>("all");

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);

      // First get all population data
      const [popDataResponse, regionsResponse] = await Promise.all([
        api.get("/population/population_data"),
        api.get("/population/regions"),
      ]);

      type FirstData = {
        region_id: string;
      };

      type SecondData = {
        id: string;
        name: string;
      };

      const firstData: FirstData[] = popDataResponse;

      const secondData: SecondData[] = regionsResponse;

      const getUniqueRegions = (
        firstData: FirstData[],
        secondData: SecondData[]
      ) => {
        // Extract unique region_ids from firstData
        const uniqueRegions = Array.from(
          new Set(firstData.map((item) => item.region_id))
        );

        // Map to new objects with id and name from secondData
        return uniqueRegions.map((regionId) => {
          const regionName =
            secondData.find((region) => region.id === regionId)?.name ||
            "Unknown";
          return { id: regionId, name: regionName };
        });
      };

      const result = getUniqueRegions(firstData, secondData);

      const popData = popDataResponse;

      const regionsData = result;

      if (regionsData) {
        setRegions(regionsData);
      }
      setPopulationData(popData);
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  const calculateTotalPopulation = (
    regionId: string,
    year: number,
    ageGroup: string,
    gender: "male" | "female"
  ): number => {
    // Get total population across all population types
    const totalPopulation = populationData
      .filter((d) => d.region_id === regionId)
      .reduce((sum, record) => {
        const value = record[`year_${year}`] || 0;
        const calculatedValue =
          (value * record.default_factor) / record.divisor;

        // Special handling for Staff and Construction Worker
        if (
          record.population_type === "Staff" ||
          record.population_type === "Construction Worker"
        ) {
          // Only count for working age groups
          if (["20 to 29", "30 to 44", "45 to 64"].includes(ageGroup)) {
            const ageGroupDistribution = {
              "20 to 29": 0.27,
              "30 to 44": 0.45,
              "45 to 64": 0.28,
            };
            return (
              sum +
              calculatedValue *
                ageGroupDistribution[
                  ageGroup as keyof typeof ageGroupDistribution
                ]
            );
          }
          return sum;
        }

        // Regular age group distribution for other population types
        const ageGroupPercentages = {
          "0 to 4": 0.08,
          "5 to 19": 0.2,
          "20 to 29": 0.18,
          "30 to 44": 0.3,
          "45 to 64": 0.19,
          "65 to 125": 0.05,
        };

        return sum + calculatedValue * ageGroupPercentages[ageGroup];
      }, 0);

    // Apply gender distribution
    const genderDistribution = {
      "0 to 4": 0.51,
      "5 to 19": 0.52,
      "20 to 29": 0.54,
      "30 to 44": 0.53,
      "45 to 64": 0.52,
      "65 to 125": 0.48,
    };

    return Math.round(
      totalPopulation *
        (gender === "male"
          ? genderDistribution[ageGroup]
          : 1 - genderDistribution[ageGroup])
    );
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-2">
          <Table className="h-6 w-6 text-emerald-600" />
          <h2 className="text-xl font-semibold text-gray-900">
            Population Summary
          </h2>
        </div>
        <select
          value={selectedRegion}
          onChange={(e) => setSelectedRegion(e.target.value)}
          className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
        >
          <option value="all">All Regions</option>
          {regions.map((region) => (
            <option key={region.id} value={region.id}>
              {region.name}
            </option>
          ))}
        </select>
      </div>

      <div className="relative overflow-x-auto">
        <div className="overflow-x-scroll">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="sticky left-0 z-10 bg-gray-50 px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Region
                </th>
                <th className="sticky left-[150px] z-10 bg-gray-50 px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Age Group
                </th>
                <th className="sticky left-[300px] z-10 bg-gray-50 px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Gender
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
              {regions
                .filter(
                  (region) =>
                    selectedRegion === "all" || selectedRegion === region.id
                )
                .map((region) =>
                  AGE_GROUPS.map((ageGroup) =>
                    ["male", "female"].map((gender, genderIndex) => (
                      <tr key={`${region.id}-${ageGroup}-${gender}`}>
                        <td className="sticky left-0 z-10 bg-white px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {region.name}
                        </td>
                        <td className="sticky left-[150px] z-10 bg-white px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {ageGroup}
                        </td>
                        <td className="sticky left-[300px] z-10 bg-white px-6 py-4 whitespace-nowrap text-sm text-gray-900 capitalize">
                          {gender}
                        </td>
                        {YEARS.map((year) => (
                          <td
                            key={year}
                            className="px-6 py-4 whitespace-nowrap text-sm text-gray-900"
                          >
                            {calculateTotalPopulation(
                              region.id,
                              year,
                              ageGroup,
                              gender as "male" | "female"
                            ).toLocaleString()}
                          </td>
                        ))}
                      </tr>
                    ))
                  )
                )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
