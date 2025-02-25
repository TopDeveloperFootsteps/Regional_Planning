import React from 'react';

interface BreakdownData {
  ageGroups: Record<string, {
    population: number;
    malePopulation: number;
    femalePopulation: number;
    maleRate: number;
    femaleRate: number;
    maleVisits: number;
    femaleVisits: number;
    totalVisits: number;
  }>;
}

interface CalculationBreakdownProps {
  selectedService: string;
  services: string[];
  breakdownData: BreakdownData | null;
  onServiceChange: (service: string) => void;
}

export function CalculationBreakdown({
  selectedService,
  services,
  breakdownData,
  onServiceChange
}: CalculationBreakdownProps) {
  if (!breakdownData?.ageGroups || Object.keys(breakdownData.ageGroups).length === 0) {
    return (
      <div className="mt-8 mb-6 bg-gray-50 rounded-lg p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Calculation Breakdown</h3>
        <div className="text-center py-8 text-gray-500">
          No data available. Please ensure a region and year are selected.
        </div>
      </div>
    );
  }

  return (
    <div className="mt-8 mb-6 bg-gray-50 rounded-lg p-6">
      <h3 className="text-lg font-medium text-gray-900 mb-4">Calculation Breakdown</h3>

      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-white">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Age Group</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Population</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Male Population</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Female Population</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Male Rate</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Female Rate</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Male Visits</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Female Visits</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Visits</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {Object.entries(breakdownData.ageGroups).map(([ageGroup, data]) => (
              <tr key={ageGroup}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{ageGroup}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{Math.round(data.population).toLocaleString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{Math.round(data.malePopulation).toLocaleString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{Math.round(data.femalePopulation).toLocaleString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{data.maleRate.toFixed(1)}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{data.femaleRate.toFixed(1)}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{Math.round(data.maleVisits).toLocaleString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{Math.round(data.femaleVisits).toLocaleString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{Math.round(data.totalVisits).toLocaleString()}</td>
              </tr>
            ))}
            <tr className="bg-emerald-50 font-medium">
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">Total</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {Math.round(Object.values(breakdownData.ageGroups)
                  .reduce((sum, data) => sum + data.population, 0)).toLocaleString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {Math.round(Object.values(breakdownData.ageGroups)
                  .reduce((sum, data) => sum + data.malePopulation, 0)).toLocaleString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {Math.round(Object.values(breakdownData.ageGroups)
                  .reduce((sum, data) => sum + data.femalePopulation, 0)).toLocaleString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">-</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">-</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {Math.round(Object.values(breakdownData.ageGroups)
                  .reduce((sum, data) => sum + data.maleVisits, 0)).toLocaleString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {Math.round(Object.values(breakdownData.ageGroups)
                  .reduce((sum, data) => sum + data.femaleVisits, 0)).toLocaleString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {Math.round(Object.values(breakdownData.ageGroups)
                  .reduce((sum, data) => sum + data.totalVisits, 0)).toLocaleString()}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}