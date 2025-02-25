import React from 'react';
import { PieChart } from 'lucide-react';

interface SystemDistributionProps {
  data: {
    system_of_care: string;
    total_encounters: number;
    care_setting_percentages: Record<string, number>;
  }[];
}

export function SystemOfCareDistribution({ data }: SystemDistributionProps) {
  const totalEncounters = data.reduce((sum, item) => sum + item.total_encounters, 0);

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center space-x-2 mb-6">
        <PieChart className="h-6 w-6 text-emerald-600" />
        <h2 className="text-lg font-semibold text-gray-900">System of Care Distribution</h2>
      </div>
      <div className="space-y-4">
        {data.map((item) => (
          <div key={item.system_of_care} className="space-y-2">
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-gray-700">{item.system_of_care}</span>
              <span className="text-sm text-gray-500">
                {Math.round((item.total_encounters / totalEncounters) * 100)}%
              </span>
            </div>
            <div className="bg-gray-200 rounded-full h-2">
              <div
                className="bg-emerald-500 h-2 rounded-full transition-all duration-300"
                style={{ width: `${(item.total_encounters / totalEncounters) * 100}%` }}
              />
            </div>
            <div className="grid grid-cols-2 gap-2 mt-2">
              {Object.entries(item.care_setting_percentages).map(([setting, percentage]) => (
                <div key={setting} className="text-xs text-gray-500">
                  {setting}: {percentage}%
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}