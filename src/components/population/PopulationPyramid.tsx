import React from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  ReferenceLine
} from 'recharts';

// Sample data
const sampleData = [
  { ageGroup: '0 to 4', male: 5000, female: 4800 },
  { ageGroup: '5 to 19', male: 15000, female: 14500 },
  { ageGroup: '20 to 29', male: 12000, female: 11800 },
  { ageGroup: '30 to 44', male: 18000, female: 17500 },
  { ageGroup: '45 to 64', male: 14000, female: 13800 },
  { ageGroup: '65 to 125', male: 4000, female: 4200 }
];

interface PyramidData {
  ageGroup: string;
  male: number;
  female: number;
}

interface PopulationPyramidProps {
  data?: PyramidData[]; // Make data optional since we have sample data
}

export function PopulationPyramid({ data = sampleData }: PopulationPyramidProps) {
  // Convert male values to negative for pyramid effect and ensure proper ordering
  const pyramidData = [...data]
    .sort((a, b) => {
      // Extract numbers from age groups for proper sorting
      const aStart = parseInt(a.ageGroup.split(' to ')[0]);
      const bStart = parseInt(b.ageGroup.split(' to ')[0]);
      return bStart - aStart; // Sort in descending order for correct vertical alignment
    })
    .map(item => ({
      ageGroup: item.ageGroup,
      male: -item.male, // Make male values negative
      female: item.female
    }));

  const maxValue = Math.max(
    ...data.map(item => Math.max(item.male, item.female))
  );

  // Function to determine tick values based on data range
  const getTickValues = (max: number) => {
    let step;
    if (max <= 100) step = 50;
    else if (max <= 1000) step = 200;
    else if (max <= 10000) step = 2000;
    else if (max <= 100000) step = 20000;
    else step = 50000;

    const ticks = [];
    for (let i = 0; i <= max; i += step) {
      ticks.push(i);
      if (i !== 0) ticks.push(-i);
    }
    return ticks.sort((a, b) => a - b);
  };

  // Colors for the bars
  const COLORS = {
    male: '#3B82F6', // Blue
    female: '#EC4899', // Pink
    maleHover: '#2563EB', // Darker blue
    femaleHover: '#DB2777' // Darker pink
  };

  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-white p-3 border border-gray-200 rounded-lg shadow-lg">
          <p className="font-medium text-gray-900 mb-1">{label}</p>
          {payload.map((entry: any, index: number) => (
            <p key={index} className="text-sm" style={{ color: entry.color }}>
              {entry.name}: {Math.abs(entry.value).toLocaleString()}
            </p>
          ))}
        </div>
      );
    }
    return null;
  };

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <h2 className="text-xl font-semibold text-gray-900 mb-4">Population Pyramid</h2>
      <div className="h-[500px]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={pyramidData}
            layout="vertical"
            margin={{ top: 20, right: 30, left: 60, bottom: 20 }}
            barCategoryGap={2} // Small gap between age groups
            barGap={0} // No gap between male and female bars
            barSize={24} // Slightly larger bars for better visibility
          >
            <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
            <XAxis 
              type="number"
              tick={{ fill: '#4B5563', fontSize: 12 }}
              axisLine={{ stroke: '#9CA3AF' }}
              tickFormatter={(value) => Math.abs(value).toLocaleString()}
              domain={[-maxValue, maxValue]}
              ticks={getTickValues(maxValue)}
            />
            <YAxis 
              type="category"
              dataKey="ageGroup"
              tick={{ fill: '#4B5563', fontSize: 12 }}
              axisLine={{ stroke: '#9CA3AF' }}
              width={80} // Ensure consistent width for labels
            />
            <Tooltip content={<CustomTooltip />} />
            <Legend 
              wrapperStyle={{ paddingTop: '20px' }}
              formatter={(value) => <span className="text-sm text-gray-600">{value}</span>}
            />
            <ReferenceLine x={0} stroke="#9CA3AF" />
            <Bar 
              dataKey="male" 
              name="Male" 
              fill={COLORS.male}
              radius={[4, 0, 0, 4]} // Rounded corners on left side for male bars
              onMouseOver={() => {
                // Optional: Add hover effect
                document.querySelectorAll('.recharts-bar-rectangle').forEach(el => {
                  if (el.getAttribute('fill') === COLORS.male) {
                    el.setAttribute('fill', COLORS.maleHover);
                  }
                });
              }}
              onMouseOut={() => {
                // Reset hover effect
                document.querySelectorAll('.recharts-bar-rectangle').forEach(el => {
                  if (el.getAttribute('fill') === COLORS.maleHover) {
                    el.setAttribute('fill', COLORS.male);
                  }
                });
              }}
            />
            <Bar 
              dataKey="female" 
              name="Female" 
              fill={COLORS.female}
              radius={[0, 4, 4, 0]} // Rounded corners on right side for female bars
              onMouseOver={() => {
                // Optional: Add hover effect
                document.querySelectorAll('.recharts-bar-rectangle').forEach(el => {
                  if (el.getAttribute('fill') === COLORS.female) {
                    el.setAttribute('fill', COLORS.femaleHover);
                  }
                });
              }}
              onMouseOut={() => {
                // Reset hover effect
                document.querySelectorAll('.recharts-bar-rectangle').forEach(el => {
                  if (el.getAttribute('fill') === COLORS.femaleHover) {
                    el.setAttribute('fill', COLORS.female);
                  }
                });
              }}
            />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}