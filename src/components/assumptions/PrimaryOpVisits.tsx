import React, { useState } from 'react';
import { RotateCcw } from 'lucide-react';

interface VisitRates {
  male: number;
  female: number;
}

interface RateTypes {
  model: VisitRates;
  enhanced: VisitRates;
  high_risk: VisitRates;
}

export function PrimaryOpVisits() {
  const specialties = [
    'Primary dental care',
    'Routine health checks',
    'Acute & urgent care',
    'Chronic metabolic diseases',
    'Chronic respiratory diseases',
    'Chronic mental health disorders',
    'Other chronic diseases',
    'Complex condition / Frail elderly',
    'Maternal Care',
    'Well baby care (0 to 4)',
    'Paediatric care (5 to 16)',
    'Allied Health & Health Promotion'
  ];

  const ageGroups = [
    '0 to 4',
    '5 to 19',
    '20 to 29',
    '30 to 44',
    '45 to 64',
    '65 to 125'
  ];

  // Store the initial model values for reset functionality
  const initialModelValues: Record<string, Record<string, VisitRates>> = {
    'Primary dental care': {
      '0 to 4': { male: 113.8, female: 119.5 },
      '5 to 19': { male: 955.8, female: 1004.2 },
      '20 to 29': { male: 586.3, female: 587.7 },
      '30 to 44': { male: 448.4, female: 425.0 },
      '45 to 64': { male: 503.6, female: 484.3 },
      '65 to 125': { male: 766.4, female: 621.9 }
    },
    'Routine health checks': {
      '0 to 4': { male: 0, female: 0 },
      '5 to 19': { male: 0, female: 0 },
      '20 to 29': { male: 0, female: 0 },
      '30 to 44': { male: 37.0, female: 37.0 },
      '45 to 64': { male: 111.0, female: 111.0 },
      '65 to 125': { male: 111.0, female: 111.0 }
    },
    'Acute & urgent care': {
      '0 to 4': { male: 124.5, female: 104.9 },
      '5 to 19': { male: 166.4, female: 197.0 },
      '20 to 29': { male: 551.9, female: 1073.8 },
      '30 to 44': { male: 974.9, female: 1569.5 },
      '45 to 64': { male: 1946.9, female: 1927.1 },
      '65 to 125': { male: 4369.3, female: 3550.7 }
    },
    'Chronic metabolic diseases': {
      '0 to 4': { male: 76.9, female: 75.9 },
      '5 to 19': { male: 120.2, female: 148.9 },
      '20 to 29': { male: 215.3, female: 556.8 },
      '30 to 44': { male: 331.8, female: 822.2 },
      '45 to 64': { male: 588.0, female: 657.5 },
      '65 to 125': { male: 819.7, female: 759.3 }
    },
    'Chronic respiratory diseases': {
      '0 to 4': { male: 25.2, female: 20.6 },
      '5 to 19': { male: 25.9, female: 25.4 },
      '20 to 29': { male: 61.1, female: 85.2 },
      '30 to 44': { male: 129.2, female: 133.9 },
      '45 to 64': { male: 276.4, female: 264.1 },
      '65 to 125': { male: 556.4, female: 407.7 }
    },
    'Chronic mental health disorders': {
      '0 to 4': { male: 18.4, female: 13.7 },
      '5 to 19': { male: 521.4, female: 851.9 },
      '20 to 29': { male: 593.6, female: 836.8 },
      '30 to 44': { male: 524.6, female: 596.4 },
      '45 to 64': { male: 533.5, female: 617.9 },
      '65 to 125': { male: 542.4, female: 639.3 }
    },
    'Other chronic diseases': {
      '0 to 4': { male: 7.1, female: 6.0 },
      '5 to 19': { male: 9.5, female: 11.2 },
      '20 to 29': { male: 31.4, female: 61.1 },
      '30 to 44': { male: 55.5, female: 89.3 },
      '45 to 64': { male: 110.8, female: 109.7 },
      '65 to 125': { male: 248.7, female: 202.1 }
    },
    'Complex condition / Frail elderly': {
      '0 to 4': { male: 0, female: 0 },
      '5 to 19': { male: 0, female: 0 },
      '20 to 29': { male: 0, female: 0 },
      '30 to 44': { male: 0, female: 0 },
      '45 to 64': { male: 0, female: 0 },
      '65 to 125': { male: 471.0, female: 471.0 }
    },
    'Maternal Care': {
      '0 to 4': { male: 0, female: 0 },
      '5 to 19': { male: 0, female: 50.6 },
      '20 to 29': { male: 0, female: 936.1 },
      '30 to 44': { male: 0, female: 1010.2 },
      '45 to 64': { male: 0, female: 43.7 },
      '65 to 125': { male: 0, female: 0 }
    },
    'Well baby care (0 to 4)': {
      '0 to 4': { male: 3150.0, female: 3150.0 },
      '5 to 19': { male: 0, female: 0 },
      '20 to 29': { male: 0, female: 0 },
      '30 to 44': { male: 0, female: 0 },
      '45 to 64': { male: 0, female: 0 },
      '65 to 125': { male: 0, female: 0 }
    },
    'Paediatric care (5 to 16)': {
      '0 to 4': { male: 0, female: 0 },
      '5 to 19': { male: 720.0, female: 720.0 },
      '20 to 29': { male: 0, female: 0 },
      '30 to 44': { male: 0, female: 0 },
      '45 to 64': { male: 0, female: 0 },
      '65 to 125': { male: 0, female: 0 }
    },
    'Allied Health & Health Promotion': {
      '0 to 4': { male: 76.9, female: 75.9 },
      '5 to 19': { male: 120.2, female: 148.9 },
      '20 to 29': { male: 215.3, female: 556.8 },
      '30 to 44': { male: 331.8, female: 822.2 },
      '45 to 64': { male: 588.0, female: 657.5 },
      '65 to 125': { male: 819.7, female: 759.3 }
    }
  };

  // Store the enhanced assumption values
  const enhancedValues: Record<string, Record<string, VisitRates>> = {
    'Primary dental care': {
      '0 to 4': { male: 150, female: 160 },
      '5 to 19': { male: 300, female: 320 },
      '20 to 29': { male: 250, female: 270 },
      '30 to 44': { male: 280, female: 300 },
      '45 to 64': { male: 260, female: 280 },
      '65 to 125': { male: 240, female: 260 }
    },
    'Routine health checks': {
      '0 to 4': { male: 100, female: 110 },
      '5 to 19': { male: 120, female: 130 },
      '20 to 29': { male: 150, female: 160 },
      '30 to 44': { male: 200, female: 220 },
      '45 to 64': { male: 250, female: 270 },
      '65 to 125': { male: 300, female: 320 }
    },
    'Acute & urgent care': {
      '0 to 4': { male: 400, female: 420 },
      '5 to 19': { male: 350, female: 370 },
      '20 to 29': { male: 300, female: 310 },
      '30 to 44': { male: 320, female: 330 },
      '45 to 64': { male: 360, female: 380 },
      '65 to 125': { male: 400, female: 420 }
    },
    'Chronic metabolic diseases': {
      '0 to 4': { male: 20, female: 20 },
      '5 to 19': { male: 30, female: 30 },
      '20 to 29': { male: 100, female: 110 },
      '30 to 44': { male: 200, female: 210 },
      '45 to 64': { male: 400, female: 420 },
      '65 to 125': { male: 500, female: 520 }
    },
    'Chronic respiratory diseases': {
      '0 to 4': { male: 50, female: 60 },
      '5 to 19': { male: 60, female: 70 },
      '20 to 29': { male: 100, female: 110 },
      '30 to 44': { male: 150, female: 160 },
      '45 to 64': { male: 200, female: 210 },
      '65 to 125': { male: 300, female: 310 }
    },
    'Chronic mental health disorders': {
      '0 to 4': { male: 10, female: 10 },
      '5 to 19': { male: 50, female: 70 },
      '20 to 29': { male: 120, female: 150 },
      '30 to 44': { male: 200, female: 250 },
      '45 to 64': { male: 180, female: 220 },
      '65 to 125': { male: 100, female: 130 }
    },
    'Other chronic diseases': {
      '0 to 4': { male: 20, female: 20 },
      '5 to 19': { male: 40, female: 50 },
      '20 to 29': { male: 80, female: 90 },
      '30 to 44': { male: 150, female: 170 },
      '45 to 64': { male: 250, female: 270 },
      '65 to 125': { male: 350, female: 370 }
    },
    'Complex condition / Frail elderly': {
      '0 to 4': { male: 0, female: 0 },
      '5 to 19': { male: 0, female: 0 },
      '20 to 29': { male: 10, female: 10 },
      '30 to 44': { male: 30, female: 30 },
      '45 to 64': { male: 100, female: 110 },
      '65 to 125': { male: 400, female: 420 }
    },
    'Maternal Care': {
      '0 to 4': { male: 0, female: 0 },
      '5 to 19': { male: 0, female: 20 },
      '20 to 29': { male: 0, female: 300 },
      '30 to 44': { male: 0, female: 250 },
      '45 to 64': { male: 0, female: 0 },
      '65 to 125': { male: 0, female: 0 }
    },
    'Well baby care (0 to 4)': {
      '0 to 4': { male: 350, female: 350 },
      '5 to 19': { male: 0, female: 0 },
      '20 to 29': { male: 0, female: 0 },
      '30 to 44': { male: 0, female: 0 },
      '45 to 64': { male: 0, female: 0 },
      '65 to 125': { male: 0, female: 0 }
    },
    'Paediatric care (5 to 16)': {
      '0 to 4': { male: 0, female: 0 },
      '5 to 19': { male: 300, female: 320 },
      '20 to 29': { male: 0, female: 0 },
      '30 to 44': { male: 0, female: 0 },
      '45 to 64': { male: 0, female: 0 },
      '65 to 125': { male: 0, female: 0 }
    },
    'Allied Health & Health Promotion': {
      '0 to 4': { male: 50, female: 60 },
      '5 to 19': { male: 80, female: 90 },
      '20 to 29': { male: 100, female: 110 },
      '30 to 44': { male: 120, female: 130 },
      '45 to 64': { male: 140, female: 150 },
      '65 to 125': { male: 160, female: 170 }
    }
  };

  const [visitRates, setVisitRates] = useState<Record<string, Record<string, RateTypes>>>(() => {
    const rates: Record<string, Record<string, RateTypes>> = {};

    specialties.forEach(specialty => {
      rates[specialty] = {};
      ageGroups.forEach(ageGroup => {
        rates[specialty][ageGroup] = {
          model: initialModelValues[specialty][ageGroup] || { male: 0, female: 0 },
          enhanced: enhancedValues[specialty][ageGroup] || { male: 0, female: 0 },
          high_risk: { male: 0, female: 0 }
        };
      });
    });

    return rates;
  });

  const handleRateChange = (
    specialty: string,
    ageGroup: string,
    rateType: keyof RateTypes,
    gender: keyof VisitRates,
    value: string
  ) => {
    const numValue = parseFloat(value) || 0;
    setVisitRates(prev => ({
      ...prev,
      [specialty]: {
        ...prev[specialty],
        [ageGroup]: {
          ...prev[specialty][ageGroup],
          [rateType]: {
            ...prev[specialty][ageGroup][rateType],
            [gender]: numValue
          }
        }
      }
    }));
  };

  const resetAllModelValues = () => {
    setVisitRates(prev => {
      const newRates = { ...prev };
      specialties.forEach(specialty => {
        ageGroups.forEach(ageGroup => {
          newRates[specialty][ageGroup] = {
            ...prev[specialty][ageGroup],
            model: initialModelValues[specialty][ageGroup] || { male: 0, female: 0 }
          };
        });
      });
      return newRates;
    });
  };

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-semibold text-gray-900">Primary Outpatient Visit Rate Assumptions</h2>
        <button
          onClick={resetAllModelValues}
          className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500"
        >
          <RotateCcw className="h-4 w-4 mr-2" />
          Reset Model for All Services
        </button>
      </div>
      
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Specialty
              </th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Age Group
              </th>
              <th scope="col" colSpan={2} className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                Model
              </th>
              <th scope="col" colSpan={2} className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                Enhanced Assumptions
              </th>
              <th scope="col" colSpan={2} className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                High Risk Assumptions
              </th>
            </tr>
            <tr>
              <th scope="col" className="px-6 py-3"></th>
              <th scope="col" className="px-6 py-3"></th>
              <th scope="col" className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Male</th>
              <th scope="col" className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Female</th>
              <th scope="col" className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Male</th>
              <th scope="col" className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Female</th>
              <th scope="col" className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Male</th>
              <th scope="col" className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Female</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {specialties.map(specialty => (
              <React.Fragment key={specialty}>
                {ageGroups.map((ageGroup, index) => (
                  <tr key={`${specialty}-${ageGroup}`}>
                    {index === 0 && (
                      <td rowSpan={ageGroups.length} className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 align-top">
                        {specialty}
                      </td>
                    )}
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {ageGroup}
                    </td>
                    {/* Model Values */}
                    <td className="px-6 py-4 whitespace-nowrap">
                      <input
                        type="number"
                        value={visitRates[specialty][ageGroup].model.male}
                        onChange={(e) => handleRateChange(specialty, ageGroup, 'model', 'male', e.target.value)}
                        className="w-24 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                      />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <input
                        type="number"
                        value={visitRates[specialty][ageGroup].model.female}
                        onChange={(e) => handleRateChange(specialty, ageGroup, 'model', 'female', e.target.value)}
                        className="w-24 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                      />
                    </td>
                    {/* Enhanced Assumptions Values */}
                    <td className="px-6 py-4 whitespace-nowrap">
                      <input
                        type="number"
                        value={visitRates[specialty][ageGroup].enhanced.male}
                        onChange={(e) => handleRateChange(specialty, ageGroup, 'enhanced', 'male', e.target.value)}
                        className="w-24 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                      />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <input
                        type="number"
                        value={visitRates[specialty][ageGroup].enhanced.female}
                        onChange={(e) => handleRateChange(specialty, ageGroup, 'enhanced', 'female', e.target.value)}
                        className="w-24 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                      />
                    </td>
                    {/* High Risk Assumptions Values */}
                    <td className="px-6 py-4 whitespace-nowrap">
                      <input
                        type="number"
                        value={visitRates[specialty][ageGroup].high_risk.male}
                        onChange={(e) => handleRateChange(specialty, ageGroup, 'high_risk', 'male', e.target.value)}
                        className="w-24 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                      />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <input
                        type="number"
                        value={visitRates[specialty][ageGroup].high_risk.female}
                        onChange={(e) => handleRateChange(specialty, ageGroup, 'high_risk', 'female', e.target.value)}
                        className="w-24 rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                      />
                    </td>
                  </tr>
                ))}
              </React.Fragment>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}