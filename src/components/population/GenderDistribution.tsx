import React, { useState, useEffect } from 'react';
import { Users, ChevronLeft, ChevronRight, RotateCcw } from 'lucide-react';
import { supabase } from '../../lib/supabase';

interface GenderData {
  ageGroup: string;
  [year: string]: string | number;
}

const YEARS = Array.from({ length: 16 }, (_, i) => 2025 + i);
const AGE_GROUPS = ['0 to 4', '5 to 19', '20 to 29', '30 to 44', '45 to 64', '65 to 125'];

// Softer colors for gender representation
const COLORS = {
  male: '#4B83C5',  // Softer blue
  female: '#E88B8B', // Softer red
  maleText: '#2C5282', // Darker blue for text
  femaleText: '#9B2C2C' // Darker red for text
};

const INITIAL_MALE_DATA: GenderData[] = [
  {
    ageGroup: '0 to 4',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50][i]
    ]))
  },
  {
    ageGroup: '5 to 19',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.57, 0.56, 0.56, 0.56, 0.56, 0.55, 0.55, 0.54, 0.54, 0.53, 0.53, 0.52, 0.52, 0.52, 0.51, 0.51][i]
    ]))
  },
  {
    ageGroup: '20 to 29',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.70, 0.69, 0.69, 0.68, 0.67, 0.65, 0.64, 0.63, 0.61, 0.60, 0.59, 0.58, 0.57, 0.56, 0.55, 0.54][i]
    ]))
  },
  {
    ageGroup: '30 to 44',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.70, 0.69, 0.68, 0.67, 0.66, 0.64, 0.63, 0.62, 0.60, 0.59, 0.58, 0.57, 0.56, 0.55, 0.54, 0.54][i]
    ]))
  },
  {
    ageGroup: '45 to 64',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.70, 0.69, 0.68, 0.67, 0.66, 0.65, 0.63, 0.62, 0.61, 0.59, 0.58, 0.57, 0.55, 0.54, 0.53, 0.53][i]
    ]))
  },
  {
    ageGroup: '65 to 125',
    ...Object.fromEntries(YEARS.map((year, i) => [
      year,
      [0.48, 0.47, 0.47, 0.47, 0.47, 0.46, 0.46, 0.46, 0.45, 0.45, 0.45, 0.44, 0.44, 0.44, 0.43, 0.43][i]
    ]))
  }
];

export function GenderDistribution() {
  const [maleData, setMaleData] = useState<GenderData[]>(INITIAL_MALE_DATA);
  const [selectedYear, setSelectedYear] = useState(YEARS[0]);
  const [baselineData, setBaselineData] = useState<GenderData[]>(INITIAL_MALE_DATA);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchBaseline();
  }, []);

  const fetchBaseline = async () => {
    try {
      const { data, error } = await supabase
        .from('gender_distribution_baseline')
        .select('*');
      
      if (error) throw error;
      
      if (data && data.length > 0) {
        setBaselineData(data[0].male_data);
        setMaleData(data[0].male_data);
      } else {
        // If no baseline exists, save current data as baseline
        saveBaseline(INITIAL_MALE_DATA);
      }
    } catch (err) {
      console.error('Error fetching baseline:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const saveBaseline = async (data: GenderData[]) => {
    try {
      const { error } = await supabase
        .from('gender_distribution_baseline')
        .upsert({ id: 1, male_data: data });
      
      if (error) throw error;
      
      setBaselineData(data);
    } catch (err) {
      console.error('Error saving baseline:', err);
    }
  };

  // Calculate female data based on male data
  const femaleData = maleData.map(maleRow => ({
    ageGroup: maleRow.ageGroup,
    ...Object.fromEntries(
      YEARS.map(year => [
        year,
        1 - (maleRow[year] as number)
      ])
    )
  }));

  const handleMaleValueChange = (ageGroup: string, year: number, value: number | string) => {
    let numValue: number;
    
    if (typeof value === 'string') {
      numValue = parseFloat(value.replace('%', '')) / 100;
    } else {
      numValue = value;
    }
    
    if (isNaN(numValue) || numValue < 0 || numValue > 1) return;

    setMaleData(prevData => 
      prevData.map(row => 
        row.ageGroup === ageGroup 
          ? { ...row, [year]: numValue }
          : row
      )
    );
  };

  const handleReset = () => {
    setMaleData(baselineData);
  };

  const formatValue = (value: number) => {
    return (value * 100).toFixed(0) + '%';
  };

  const handlePreviousYear = () => {
    const currentIndex = YEARS.indexOf(selectedYear);
    if (currentIndex > 0) {
      setSelectedYear(YEARS[currentIndex - 1]);
    }
  };

  const handleNextYear = () => {
    const currentIndex = YEARS.indexOf(selectedYear);
    if (currentIndex < YEARS.length - 1) {
      setSelectedYear(YEARS[currentIndex + 1]);
    }
  };

  if (isLoading) {
    return (
      <div className="bg-white rounded-lg shadow-sm p-6 flex items-center justify-center h-96">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-2">
          <Users className="h-6 w-6 text-emerald-600" />
          <h2 className="text-lg font-semibold text-gray-900">Population Distribution by Age Group and Gender</h2>
        </div>
        <div className="flex items-center space-x-4">
          <button
            onClick={handleReset}
            className="flex items-center space-x-2 px-3 py-2 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors"
          >
            <RotateCcw className="h-4 w-4 text-gray-600" />
            <span className="text-sm text-gray-600">Reset to Baseline</span>
          </button>
          <button
            onClick={handlePreviousYear}
            disabled={selectedYear === YEARS[0]}
            className="p-2 rounded-full hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ChevronLeft className="h-5 w-5 text-gray-600" />
          </button>
          <span className="text-lg font-semibold text-gray-900">{selectedYear}</span>
          <button
            onClick={handleNextYear}
            disabled={selectedYear === YEARS[YEARS.length - 1]}
            className="p-2 rounded-full hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ChevronRight className="h-5 w-5 text-gray-600" />
          </button>
        </div>
      </div>

      <div className="border rounded-lg p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <div className="w-4 h-4 rounded" style={{ backgroundColor: COLORS.male }}></div>
              <span className="text-sm font-medium" style={{ color: COLORS.maleText }}>Male</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-4 h-4 rounded" style={{ backgroundColor: COLORS.female }}></div>
              <span className="text-sm font-medium" style={{ color: COLORS.femaleText }}>Female</span>
            </div>
          </div>
        </div>

        <div className="space-y-6">
          {maleData.map((row, index) => {
            const maleValue = row[selectedYear] as number;
            const femaleValue = femaleData[index][selectedYear] as number;

            return (
              <div key={row.ageGroup} className="space-y-2">
                <div className="flex justify-between items-center">
                  <span className="text-sm font-medium text-gray-700">{row.ageGroup}</span>
                  <div className="flex items-center space-x-4">
                    <input
                      type="text"
                      value={formatValue(maleValue)}
                      onChange={(e) => handleMaleValueChange(row.ageGroup, selectedYear, e.target.value)}
                      className="w-20 text-right rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
                      style={{ color: COLORS.maleText }}
                    />
                    <span className="w-20 text-right text-sm" style={{ color: COLORS.femaleText }}>
                      {formatValue(femaleValue)}
                    </span>
                  </div>
                </div>
                <div className="relative h-8">
                  {/* Slider input */}
                  <input
                    type="range"
                    min="0"
                    max="100"
                    value={maleValue * 100}
                    onChange={(e) => handleMaleValueChange(row.ageGroup, selectedYear, parseInt(e.target.value) / 100)}
                    className="absolute w-full h-full opacity-0 cursor-pointer z-10"
                  />
                  {/* Male portion (left side) */}
                  <div 
                    className="absolute left-0 top-0 h-full rounded-l transition-all duration-300 flex items-center justify-end pr-2"
                    style={{ width: `${maleValue * 100}%`, backgroundColor: COLORS.male }}
                  >
                    <span className="text-white text-sm font-medium">{formatValue(maleValue)}</span>
                  </div>
                  {/* Female portion (right side) */}
                  <div 
                    className="absolute right-0 top-0 h-full rounded-r transition-all duration-300 flex items-center justify-start pl-2"
                    style={{ width: `${femaleValue * 100}%`, backgroundColor: COLORS.female }}
                  >
                    <span className="text-white text-sm font-medium">{formatValue(femaleValue)}</span>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}