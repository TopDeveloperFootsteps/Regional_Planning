import React, { useState } from 'react';
import { Clock } from 'lucide-react';

interface VisitTimeData {
  levelOfCare: string;
  reasonForVisit: string;
  newVisitDuration: number;
  followUpVisitDuration: number;
  percentNewVisits: number;
  averageVisitDuration: number;
  source: string;
}

interface EditableNumberCellProps {
  value: number;
  onChange: (value: number) => void;
}

interface EditableTextCellProps {
  value: string;
  onChange: (value: string) => void;
}

const EditableNumberCell: React.FC<EditableNumberCellProps> = ({ value, onChange }) => (
  <input
    type="number"
    value={value}
    onChange={(e) => onChange(Number(e.target.value))}
    className="w-20 px-2 py-1 text-sm border rounded focus:outline-none focus:ring-1 focus:ring-emerald-500"
  />
);

const EditableTextCell: React.FC<EditableTextCellProps> = ({ value, onChange }) => (
  <input
    type="text"
    value={value}
    onChange={(e) => onChange(e.target.value)}
    className="w-full px-2 py-1 text-sm border rounded focus:outline-none focus:ring-1 focus:ring-emerald-500"
  />
);

export function VisitTimeAssumptions() {
  const [visitTimes, setVisitTimes] = useState<VisitTimeData[]>([
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Primary dental care',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 10,
      averageVisitDuration: 21,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Routine health checks',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 15,
      averageVisitDuration: 21.5,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Acute & urgent care',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 20,
      averageVisitDuration: 22,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Chronic metabolic diseases',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 25,
      averageVisitDuration: 22.5,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Chronic respiratory diseases',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 30,
      averageVisitDuration: 23,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Chronic mental health disorders',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 35,
      averageVisitDuration: 23.5,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Other chronic diseases',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 40,
      averageVisitDuration: 24,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Complex condition / Frail elderly',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 45,
      averageVisitDuration: 24.5,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Maternal Care',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 50,
      averageVisitDuration: 25,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Well baby care (0 to 4)',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 55,
      averageVisitDuration: 25.5,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Paediatric care (5 to 16)',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 60,
      averageVisitDuration: 26,
      source: 'BMJ'
    },
    {
      levelOfCare: 'Primary Care',
      reasonForVisit: 'Allied Health & Health Promotion',
      newVisitDuration: 30,
      followUpVisitDuration: 20,
      percentNewVisits: 65,
      averageVisitDuration: 26.5,
      source: 'BMJ'
    }
  ]);

  const updateVisitTime = (index: number, field: keyof VisitTimeData, value: number | string) => {
    const newData = [...visitTimes];
    newData[index] = { ...newData[index], [field]: value };

    // Recalculate average visit duration if relevant fields change
    if (field === 'newVisitDuration' || field === 'followUpVisitDuration' || field === 'percentNewVisits') {
      const newVisitWeight = newData[index].percentNewVisits / 100;
      const followUpWeight = 1 - newVisitWeight;
      newData[index].averageVisitDuration = 
        (newData[index].newVisitDuration * newVisitWeight) + 
        (newData[index].followUpVisitDuration * followUpWeight);
    }

    setVisitTimes(newData);
  };

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center space-x-2 mb-6">
        <Clock className="h-6 w-6 text-emerald-600" />
        <h2 className="text-xl font-semibold text-gray-900">Average Visit Time for Primary Care</h2>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Level of Care</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Reason for Visit</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">New Visit Duration (minutes)</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Follow-Up Visit Duration (minutes)</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">% New Visits</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Average Visit Duration</th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Source</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {visitTimes.map((row, index) => (
              <tr key={index} className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{row.levelOfCare}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{row.reasonForVisit}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <EditableNumberCell 
                    value={row.newVisitDuration} 
                    onChange={(value) => updateVisitTime(index, 'newVisitDuration', value)} 
                  />
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <EditableNumberCell 
                    value={row.followUpVisitDuration} 
                    onChange={(value) => updateVisitTime(index, 'followUpVisitDuration', value)} 
                  />
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <EditableNumberCell 
                    value={row.percentNewVisits} 
                    onChange={(value) => updateVisitTime(index, 'percentNewVisits', value)} 
                  />
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {row.averageVisitDuration.toFixed(1)}
                </td>
                <td className="px-6 py-4">
                  <EditableTextCell 
                    value={row.source} 
                    onChange={(value) => updateVisitTime(index, 'source', value)} 
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}