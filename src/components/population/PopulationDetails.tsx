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

interface AgeGroupData {
  ageGroup: string;
  [year: string]: string | number;
}

interface GenderData {
  ageGroup: string;
  [year: string]: string | number;
}

export function PopulationDetails() {
  const [populationData, setPopulationData] = useState<PopulationData[]>([]);
  const [regions, setRegions] = useState<RegionInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedRegion, setSelectedRegion] = useState<string>("all");
  const [selectedPopType, setSelectedPopType] = useState<string>("all");

  const YEARS = Array.from({ length: 16 }, (_, i) => 2025 + i);
  const AGE_GROUPS = [
    "0 to 4",
    "5 to 19",
    "20 to 29",
    "30 to 44",
    "45 to 64",
    "65 to 125",
  ];
  const POPULATION_TYPES = [
    "Residents",
    "Staff",
    "Tourists/Visit",
    "Same day Visitor",
    "Construction Worker",
  ];

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

  const calculatePopulation = (
    regionId: string,
    year: number,
    ageGroup: string,
    gender: "male" | "female",
    populationType: string
  ): number => {
    // Get total population for the region, year and population type
    const totalPopulation = populationData
      .filter(
        (d) =>
          d.region_id === regionId &&
          (populationType === "all"
            ? true
            : d.population_type === populationType)
      )
      .reduce((sum, record) => {
        const value = record[`year_${year}`] || 0;
        const calculatedValue =
          (value * record.default_factor) / record.divisor;
        return sum + calculatedValue;
      }, 0);

    // Special handling for Staff population type
    if (populationType === "Staff") {
      // Only distribute across working age groups (20-64)
      const workingAgeGroups = ["20 to 29", "30 to 44", "45 to 64"];
      if (!workingAgeGroups.includes(ageGroup)) {
        return 0; // Return 0 for non-working age groups
      }

      // Working age distribution percentages
      const workingAgeDistribution = {
        "20 to 29": 0.27, // 27% of working age population
        "30 to 44": 0.45, // 45% of working age population
        "45 to 64": 0.28, // 28% of working age population
      };

      // Gender distribution for working age groups
      const workingAgeGenderDistribution = {
        "20 to 29": 0.54, // 54% male
        "30 to 44": 0.53, // 53% male
        "45 to 64": 0.52, // 52% male
      };

      const ageGroupPopulation =
        totalPopulation *
        workingAgeDistribution[ageGroup as keyof typeof workingAgeDistribution];
      const genderRatio =
        gender === "male"
          ? workingAgeGenderDistribution[
              ageGroup as keyof typeof workingAgeGenderDistribution
            ]
          : 1 -
            workingAgeGenderDistribution[
              ageGroup as keyof typeof workingAgeGenderDistribution
            ];

      return Math.round(ageGroupPopulation * genderRatio);
    }

    // Regular age group distribution for other population types
    const ageGroupPercentages: { [key: string]: number } = {
      "0 to 4": 0.08,
      "5 to 19": 0.2,
      "20 to 29": 0.18,
      "30 to 44": 0.3,
      "45 to 64": 0.19,
      "65 to 125": 0.05,
    };

    // Regular gender distribution
    const genderDistribution: { [key: string]: number } = {
      "0 to 4": 0.51,
      "5 to 19": 0.52,
      "20 to 29": 0.54,
      "30 to 44": 0.53,
      "45 to 64": 0.52,
      "65 to 125": 0.48,
    };

    const ageGroupPopulation =
      totalPopulation * (ageGroupPercentages[ageGroup] || 0);
    const genderRatio =
      gender === "male"
        ? genderDistribution[ageGroup]
        : 1 - genderDistribution[ageGroup];

    return Math.round(ageGroupPopulation * genderRatio);
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
            Population Details
          </h2>
        </div>
        <div className="flex space-x-4">
          <select
            value={selectedPopType}
            onChange={(e) => setSelectedPopType(e.target.value)}
            className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
          >
            <option value="all">All Population Types</option>
            {POPULATION_TYPES.map((type) => (
              <option key={type} value={type}>
                {type}
              </option>
            ))}
          </select>
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
                  Population Type
                </th>
                <th className="sticky left-[300px] z-10 bg-gray-50 px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Age Group
                </th>
                <th className="sticky left-[450px] z-10 bg-gray-50 px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
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
                  POPULATION_TYPES.filter(
                    (popType) =>
                      selectedPopType === "all" || selectedPopType === popType
                  ).map((popType) =>
                    AGE_GROUPS.map((ageGroup) =>
                      ["male", "female"].map((gender, genderIndex) => (
                        <tr
                          key={`${region.id}-${popType}-${ageGroup}-${gender}`}
                        >
                          <td className="sticky left-0 z-10 bg-white px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {region.name}
                          </td>
                          <td className="sticky left-[150px] z-10 bg-white px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {popType}
                          </td>
                          <td className="sticky left-[300px] z-10 bg-white px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            {ageGroup}
                          </td>
                          <td className="sticky left-[450px] z-10 bg-white px-6 py-4 whitespace-nowrap text-sm text-gray-900 capitalize">
                            {gender}
                          </td>
                          {YEARS.map((year) => (
                            <td
                              key={year}
                              className="px-6 py-4 whitespace-nowrap text-sm text-gray-900"
                            >
                              {calculatePopulation(
                                region.id,
                                year,
                                ageGroup,
                                gender as "male" | "female",
                                popType
                              ).toLocaleString()}
                            </td>
                          ))}
                        </tr>
                      ))
                    )
                  )
                )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
