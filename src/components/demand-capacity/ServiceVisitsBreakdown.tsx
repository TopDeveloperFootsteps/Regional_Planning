import React from 'react';
import { Calculator } from 'lucide-react';

interface ServiceVisit {
  service: string;
  visits: number;
  maleVisits: number;
  femaleVisits: number;
}

interface ServiceVisitsBreakdownProps {
  regions: Array<{ id: string; name: string }>;
  selectedRegion: string;
  selectedYear: number;
  serviceVisits: ServiceVisit[];
  calculationDetails: string;
}

export function ServiceVisitsBreakdown({
  regions,
  selectedRegion,
  selectedYear,
  serviceVisits,
  calculationDetails
}: ServiceVisitsBreakdownProps) {
  // Get the region name for display
  const regionName = selectedRegion === 'all' 
    ? 'All Regions' 
    : regions.find(r => r.id === selectedRegion)?.name || 'Unknown Region';

  // Parse population data from calculation details
  const populationMatch = calculationDetails.match(/Total Population \(\d+\): (\d+)/);
  const totalPopulation = populationMatch ? parseInt(populationMatch[1]) : 0;

  // Extract male/female population from details
  const malePopulationMatch = calculationDetails.match(/Male: (\d+)/);
  const femalePopulationMatch = calculationDetails.match(/Female: (\d+)/);
  const malePopulation = malePopulationMatch ? parseInt(malePopulationMatch[1]) : 0;
  const femalePopulation = femalePopulationMatch ? parseInt(femalePopulationMatch[1]) : 0;

  return (
    <div className="mt-8">
      <div className="flex items-center justify-between mb-4">
        <div className="space-y-1">
          <h3 className="text-lg font-medium text-gray-900">Service Visits Breakdown</h3>
          <p className="text-sm text-gray-600">
            Showing data for {regionName} in {selectedYear}
          </p>
        </div>
        <button
          onClick={() => console.log(calculationDetails)}
          className="flex items-center space-x-2 text-sm text-emerald-600 hover:text-emerald-700"
        >
          <Calculator className="h-4 w-4" />
          <span>View Calculation Details</span>
        </button>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Service</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Male Population</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Female Population</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Male Visits</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Female Visits</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Visits</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {serviceVisits.map((visit, index) => (
              <tr key={index} className={visit.visits === 0 ? 'bg-gray-50' : ''}>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{visit.service}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{malePopulation.toLocaleString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{femalePopulation.toLocaleString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{visit.maleVisits.toLocaleString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{visit.femaleVisits.toLocaleString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{visit.visits.toLocaleString()}</td>
              </tr>
            ))}
            <tr className="bg-emerald-50 font-medium">
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">Total</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{malePopulation.toLocaleString()}</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{femalePopulation.toLocaleString()}</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {serviceVisits.reduce((sum, visit) => sum + visit.maleVisits, 0).toLocaleString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {serviceVisits.reduce((sum, visit) => sum + visit.femaleVisits, 0).toLocaleString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {serviceVisits.reduce((sum, visit) => sum + visit.visits, 0).toLocaleString()}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}