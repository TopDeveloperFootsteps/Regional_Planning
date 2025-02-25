import React from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';

interface RegionInfo {
  id: string;
  name: string;
}

interface PopulationTrend {
  year: number;
  [key: string]: number | string;
}

interface PopulationGrowthChartProps {
  data: PopulationTrend[];
  regions: RegionInfo[];
}

export function PopulationGrowthChart({ data, regions }: PopulationGrowthChartProps) {
  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <h2 className="text-xl font-semibold text-gray-900 mb-4">Population Growth Trend</h2>
      <div className="h-[400px]">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data}>
            <defs>
              {regions.map((region, index) => (
                <linearGradient key={region.id} id={`gradient-${region.id}`} x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor={`hsl(${index * (360 / regions.length)}, 70%, 50%)`} stopOpacity={0.8}/>
                  <stop offset="95%" stopColor={`hsl(${index * (360 / regions.length)}, 70%, 50%)`} stopOpacity={0.2}/>
                </linearGradient>
              ))}
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
            <XAxis 
              dataKey="year" 
              tick={{ fill: '#4B5563', fontSize: 12 }}
              axisLine={{ stroke: '#9CA3AF' }}
            />
            <YAxis 
              tick={{ fill: '#4B5563', fontSize: 12 }}
              tickFormatter={(value) => value.toLocaleString()}
              axisLine={{ stroke: '#9CA3AF' }}
            />
            <Tooltip 
              formatter={(value: number) => value.toLocaleString()}
              labelFormatter={(label) => `Year: ${label}`}
              contentStyle={{
                backgroundColor: 'rgba(255, 255, 255, 0.95)',
                border: '1px solid #E5E7EB',
                borderRadius: '6px',
                boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)'
              }}
            />
            <Legend 
              wrapperStyle={{ paddingTop: '20px' }}
              formatter={(value) => <span className="text-sm text-gray-600">{value}</span>}
            />
            {regions.map((region, index) => (
              <Line
                key={region.id}
                type="monotone"
                dataKey={region.name}
                stroke={`hsl(${index * (360 / regions.length)}, 70%, 50%)`}
                strokeWidth={3}
                dot={{ r: 4, fill: `hsl(${index * (360 / regions.length)}, 70%, 50%)` }}
                activeDot={{ r: 6, stroke: 'white', strokeWidth: 2 }}
                fillOpacity={0.2}
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}