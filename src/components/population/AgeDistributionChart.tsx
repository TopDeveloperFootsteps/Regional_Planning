import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

interface AgeDistributionData {
  ageGroup: string;
  male: number;
  female: number;
}

interface AgeDistributionChartProps {
  data: AgeDistributionData[];
}

export function AgeDistributionChart({ data }: AgeDistributionChartProps) {
  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <h2 className="text-xl font-semibold text-gray-900 mb-4">
        Age Distribution
      </h2>
      <div className="h-[400px]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={data}
            layout="vertical"
            margin={{ top: 20, right: 30, left: 60, bottom: 20 }}
          >
            <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
            <XAxis
              type="number"
              tick={{ fill: "#4B5563", fontSize: 12 }}
              axisLine={{ stroke: "#9CA3AF" }}
              tickFormatter={(value) => value.toLocaleString()}
            />
            <YAxis
              type="category"
              dataKey="ageGroup"
              tick={{ fill: "#4B5563", fontSize: 12 }}
              axisLine={{ stroke: "#9CA3AF" }}
            />
            <Tooltip
              formatter={(value: number) => value.toLocaleString()}
              contentStyle={{
                backgroundColor: "rgba(255, 255, 255, 0.95)",
                border: "1px solid #E5E7EB",
                borderRadius: "6px",
                boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
              }}
            />
            <Legend
              wrapperStyle={{ paddingTop: "20px" }}
              formatter={(value) => (
                <span className="text-sm text-gray-600">{value}</span>
              )}
            />
            <Bar
              dataKey="male"
              name="Male"
              fill="#3B82F6"
              stackId="gender"
              radius={[0, 4, 4, 0]}
            />
            <Bar
              dataKey="female"
              name="Female"
              fill="#EC4899"
              stackId="gender"
              radius={[4, 0, 0, 4]}
            />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
