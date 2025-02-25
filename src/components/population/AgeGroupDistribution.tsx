import React, { useState } from 'react';
import { Table } from 'lucide-react';

interface AgeGroupData {
  ageGroup: string;
  [year: string]: string | number;
}

const YEARS = Array.from({ length: 16 }, (_, i) => 2025 + i);
const AGE_GROUPS = ['0 to 4', '5 to 19', '20 to 29', '30 to 44', '45 to 64', '65 to 125'];

const INITIAL_DATA: AgeGroupData[] = [
  {
    ageGroup: '0 to 4',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.0167, 0.02, 0.0267, 0.03, 0.0333, 0.04, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06, 0.06][i]
    ]))
  },
  {
    ageGroup: '5 to 19',
    ...Object.fromEntries(YEARS.map(() => [
      YEARS[0],
      0.1525
    ]))
  },
  {
    ageGroup: '20 to 29',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.1919, 0.1858, 0.1836, 0.1825, 0.1764, 0.1742, 0.1675, 0.1675, 0.1625, 0.1625, 0.1625, 0.1625, 0.1625, 0.1575, 0.1575, 0.1575][i]
    ]))
  },
  {
    ageGroup: '30 to 44',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.3394, 0.3333, 0.3311, 0.33, 0.3239, 0.3217, 0.315, 0.315, 0.31, 0.31, 0.31, 0.31, 0.31, 0.305, 0.305, 0.305][i]
    ]))
  },
  {
    ageGroup: '45 to 64',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.2894, 0.2883, 0.2861, 0.285, 0.2839, 0.2817, 0.275, 0.275, 0.275, 0.275, 0.275, 0.275, 0.275, 0.275, 0.275, 0.275][i]
    ]))
  },
  {
    ageGroup: '65 to 125',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.01, 0.02, 0.02, 0.02, 0.03, 0.03, 0.03, 0.03, 0.04, 0.04, 0.04, 0.04, 0.04, 0.05, 0.05, 0.05][i]
    ]))
  }
];

// Fix the "5 to 19" age group data after initialization
INITIAL_DATA[1] = {
  ageGroup: '5 to 19',
  ...Object.fromEntries(YEARS.map(year => [year, 0.1525]))
};

export function AgeGroupDistribution() {
  const [data, setData] = useState<AgeGroupData[]>(INITIAL_DATA);

  const handleValueChange = (ageGroup: string, year: number, value: string) => {
    // Remove the % sign and convert to decimal
    const numValue = parseFloat(value.replace('%', '')) / 100;
    if (isNaN(numValue)) return;

    setData(prevData => 
      prevData.map(row => 
        row.ageGroup === ageGroup 
          ? { ...row, [year]: numValue }
          : row
      )
    );
  };

  const formatValue = (value: number) => {
    return (value * 100).toFixed(2) + '%';
  };

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center space-x-2 mb-6">
        <Table className="h-6 w-6 text-emerald-600" />
        <h2 className="text-lg font-semibold text-gray-900">Population Distribution by Age Group</h2>
      </div>

      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider sticky left-0 bg-gray-50">
                Age Group
              </th>
              {YEARS.map(year => (
                <th key={year} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  {year}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {data.map((row) => (
              <tr key={row.ageGroup}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 sticky left-0 bg-white">
                  {row.ageGroup}
                </td>
                {YEARS.map(year => (
                  <td key={year} className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <input
                      type="text"
                      value={formatValue(row[year] as number)}
                      onChange={(e) => handleValueChange(row.ageGroup, year, e.target.value)}
                      className="w-20 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                    />
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