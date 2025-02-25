import React from 'react';
import {
  LineChart,
  Line,
  AreaChart,
  Area,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';
import { TrendingUp, Users, Activity } from 'lucide-react';

interface PopulationData {
  population_type: string;
  years: Record<string, {
    population: number | null;
    calculated_value: number | null;
  }>;
}

interface PopulationChartsProps {
  data: PopulationData[];
}

export function PopulationCharts({ data }: PopulationChartsProps) {
  // Transform data for charts
  const chartData = Object.keys(data[0]?.years || {}).map(year => {
    const yearData: any = { year };
    data.forEach(item => {
      yearData[`${item.population_type}_raw`] = item.years[year].population;
      yearData[`${item.population_type}_calculated`] = item.years[year].calculated_value;
    });
    return yearData;
  });

  // Calculate totals for metrics
  const latestYear = chartData[chartData.length - 1];
  const totalPopulation = data.reduce((sum, item) => {
    const lastYearData = item.years[Object.keys(item.years)[Object.keys(item.years).length - 1]];
    return sum + (lastYearData.calculated_value || 0);
  }, 0);

  const growthRate = chartData.length > 1 ? (
    ((latestYear?.total || 0) - (chartData[0]?.total || 0)) / (chartData[0]?.total || 1) * 100
  ) : 0;

  return (
    <div className="space-y-8">
      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center space-x-3">
            <Users className="h-8 w-8 text-emerald-600" />
            <div>
              <p className="text-sm font-medium text-gray-600">Total Population</p>
              <h3 className="text-2xl font-bold text-gray-900">
                {Math.round(totalPopulation).toLocaleString()}
              </h3>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center space-x-3">
            <TrendingUp className="h-8 w-8 text-emerald-600" />
            <div>
              <p className="text-sm font-medium text-gray-600">Growth Rate</p>
              <h3 className="text-2xl font-bold text-gray-900">
                {growthRate.toFixed(1)}%
              </h3>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center space-x-3">
            <Activity className="h-8 w-8 text-emerald-600" />
            <div>
              <p className="text-sm font-medium text-gray-600">Population Types</p>
              <h3 className="text-2xl font-bold text-gray-900">
                {data.length}
              </h3>
            </div>
          </div>
        </div>
      </div>

      {/* Population Trend Chart */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Population Growth Trend</h3>
        <div className="h-[400px]">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="year" />
              <YAxis />
              <Tooltip />
              <Legend />
              {data.map((item, index) => (
                <Line
                  key={item.population_type}
                  type="monotone"
                  dataKey={`${item.population_type}_calculated`}
                  name={item.population_type}
                  stroke={`hsl(${index * (360 / data.length)}, 70%, 50%)`}
                  strokeWidth={2}
                />
              ))}
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Population Distribution */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Population Distribution</h3>
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={[latestYear]}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis />
                <Tooltip />
                <Legend />
                {data.map((item, index) => (
                  <Bar
                    key={item.population_type}
                    dataKey={`${item.population_type}_calculated`}
                    name={item.population_type}
                    fill={`hsl(${index * (360 / data.length)}, 70%, 50%)`}
                  />
                ))}
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Cumulative Growth</h3>
          <div className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis />
                <Tooltip />
                <Legend />
                {data.map((item, index) => (
                  <Area
                    key={item.population_type}
                    type="monotone"
                    dataKey={`${item.population_type}_calculated`}
                    name={item.population_type}
                    fill={`hsl(${index * (360 / data.length)}, 70%, 50%)`}
                    fillOpacity={0.3}
                    stroke={`hsl(${index * (360 / data.length)}, 70%, 50%)`}
                    stackId="1"
                  />
                ))}
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}