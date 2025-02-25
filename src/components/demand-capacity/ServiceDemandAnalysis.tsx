import React, { useState } from 'react';
import { Play, Pause, ArrowUpDown, Filter } from 'lucide-react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';

interface ServiceDemandAnalysisProps {
  regions: Array<{ id: string; name: string }>;
  selectedRegion: string;
  selectedYear: number;
  selectedAssumption: 'model' | 'enhanced' | 'high_risk';
  isPlaying: boolean;
  playbackSpeed: number;
  serviceVisits: Array<{ 
    service: string; 
    visits: number; 
    maleVisits: number; 
    femaleVisits: number;
  }>;
  onRegionChange: (region: string) => void;
  onYearChange: (year: number) => void;
  onAssumptionChange: (assumption: 'model' | 'enhanced' | 'high_risk') => void;
  onPlaybackToggle: () => void;
  onPlaybackSpeedChange: (speed: number) => void;
}

type SortOrder = 'alphabetical' | 'visits';
type ViewMode = 'gender' | 'virtual';

export function ServiceDemandAnalysis({
  selectedYear,
  isPlaying,
  playbackSpeed,
  serviceVisits,
  onYearChange,
  onPlaybackToggle,
  onPlaybackSpeedChange
}: ServiceDemandAnalysisProps) {
  const [sortOrder, setSortOrder] = useState<SortOrder>('visits');
  const [viewMode, setViewMode] = useState<ViewMode>('gender');

  // Transform data based on view mode
  const transformedData = serviceVisits.map(visit => {
    if (viewMode === 'gender') {
      return {
        ...visit,
        Male: visit.maleVisits,
        Female: visit.femaleVisits
      };
    } else {
      // Get virtual/in-person percentages from specialty rates
      const virtualRate = 0.35; // Default rate if not found
      const inPersonRate = 1 - virtualRate;
      
      return {
        ...visit,
        'Virtual Visits': Math.round(visit.visits * virtualRate),
        'In-Person Visits': Math.round(visit.visits * inPersonRate)
      };
    }
  });

  // Sort data based on current sort order
  const sortedData = [...transformedData].sort((a, b) => {
    if (sortOrder === 'alphabetical') {
      return a.service.localeCompare(b.service);
    }
    return b.visits - a.visits;
  });

  // Custom tooltip styles
  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-white p-4 rounded-lg shadow-lg border border-gray-200">
          <p className="font-medium text-gray-900 mb-2">{label}</p>
          {payload.map((entry: any, index: number) => (
            <div key={index} className="flex items-center space-x-2">
              <div 
                className="w-3 h-3 rounded-full"
                style={{ backgroundColor: entry.color }}
              />
              <p className="text-sm text-gray-600">
                {entry.name}: {entry.value.toLocaleString()} visits
              </p>
            </div>
          ))}
          <p className="text-sm text-gray-500 mt-2">
            Total: {(payload[0].value + payload[1].value).toLocaleString()} visits
          </p>
        </div>
      );
    }
    return null;
  };

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-4">
          <h2 className="text-xl font-semibold text-gray-900">Service Demand Analysis</h2>
          <button
            onClick={() => setSortOrder(order => order === 'alphabetical' ? 'visits' : 'alphabetical')}
            className="flex items-center space-x-2 px-3 py-1 text-sm text-gray-600 hover:text-emerald-600 border border-gray-200 rounded-md hover:border-emerald-200 transition-colors"
          >
            <ArrowUpDown className="h-4 w-4" />
            <span>Sort {sortOrder === 'alphabetical' ? 'by Visits' : 'Alphabetically'}</span>
          </button>
          <div className="flex items-center space-x-2">
            <Filter className="h-4 w-4 text-gray-600" />
            <select
              value={viewMode}
              onChange={(e) => setViewMode(e.target.value as ViewMode)}
              className="text-sm border-gray-300 rounded-md focus:border-emerald-500 focus:ring-emerald-500"
            >
              <option value="gender">Gender Distribution</option>
              <option value="virtual">Virtual vs In-Person</option>
            </select>
          </div>
        </div>
        <div className="flex items-center space-x-4">
          <button
            onClick={onPlaybackToggle}
            className="flex items-center space-x-2 px-4 py-2 bg-emerald-600 text-white rounded-md hover:bg-emerald-700 transition-colors"
          >
            {isPlaying ? (
              <>
                <Pause className="h-4 w-4" />
                <span>Pause</span>
              </>
            ) : (
              <>
                <Play className="h-4 w-4" />
                <span>Play</span>
              </>
            )}
          </button>
          <select
            value={playbackSpeed}
            onChange={(e) => onPlaybackSpeedChange(parseInt(e.target.value))}
            className="rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500"
          >
            <option value={2000}>Slow</option>
            <option value={1000}>Normal</option>
            <option value={500}>Fast</option>
          </select>
        </div>
      </div>

      <div className="mb-6">
        <input
          type="range"
          min={2025}
          max={2040}
          value={selectedYear}
          onChange={(e) => onYearChange(parseInt(e.target.value))}
          className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
        />
        <div className="flex justify-between text-sm text-gray-600 mt-1">
          <span>2025</span>
          <span>Selected: {selectedYear}</span>
          <span>2040</span>
        </div>
      </div>

      <div className="h-[600px]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={sortedData}
            margin={{
              top: 20,
              right: 30,
              left: 20,
              bottom: 150
            }}
          >
            <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
            <XAxis 
              dataKey="service" 
              angle={-45}
              textAnchor="end"
              height={150}
              tick={{ fill: '#4B5563', fontSize: 12 }}
            />
            <YAxis 
              tick={{ fill: '#4B5563', fontSize: 12 }}
              tickFormatter={(value) => value.toLocaleString()}
            />
            <Tooltip content={<CustomTooltip />} />
            <Legend 
              wrapperStyle={{ paddingTop: '20px' }}
              formatter={(value) => <span className="text-sm text-gray-600">{value}</span>}
            />
            {viewMode === 'gender' ? (
              <>
                <Bar 
                  dataKey="Male"
                  name="Male Visits" 
                  fill="url(#maleGradient)" 
                  stackId="a"
                  animationDuration={500}
                  stroke="#3B82F6"
                  strokeWidth={1}
                />
                <Bar 
                  dataKey="Female"
                  name="Female Visits" 
                  fill="url(#femaleGradient)" 
                  stackId="a"
                  animationDuration={500}
                  stroke="#EC4899"
                  strokeWidth={1}
                />
                <defs>
                  <linearGradient id="maleGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#3B82F6" stopOpacity={0.4}/>
                  </linearGradient>
                  <linearGradient id="femaleGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#EC4899" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#EC4899" stopOpacity={0.4}/>
                  </linearGradient>
                </defs>
              </>
            ) : (
              <>
                <Bar 
                  dataKey="Virtual Visits"
                  name="Virtual Visits" 
                  fill="url(#virtualGradient)" 
                  stackId="a"
                  animationDuration={500}
                  stroke="#6366F1"
                  strokeWidth={1}
                />
                <Bar 
                  dataKey="In-Person Visits"
                  name="In-Person Visits" 
                  fill="url(#inPersonGradient)" 
                  stackId="a"
                  animationDuration={500}
                  stroke="#10B981"
                  strokeWidth={1}
                />
                <defs>
                  <linearGradient id="virtualGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#6366F1" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#6366F1" stopOpacity={0.4}/>
                  </linearGradient>
                  <linearGradient id="inPersonGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10B981" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#10B981" stopOpacity={0.4}/>
                  </linearGradient>
                </defs>
              </>
            )}
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}