import React, { useState } from 'react';
import { Table, Settings, Info, Calendar, Clock } from 'lucide-react';
import { VisitTimeAssumptions } from './VisitTimeAssumptions';
import { SpecialistVisitTimeAssumptions } from './SpecialistVisitTimeAssumptions';
import { OperationalVisualizations } from './OperationalVisualizations';
import { SpecialtyOccupancyRates } from './SpecialtyOccupancyRates';

interface WorkingDaysData {
  setting: string;
  daysPerWeek: number;
  weeksPerYear: number;
  daysPerYear: number;
  source: string;
}

interface WorkingHoursData {
  setting: string;
  hoursPerDay: number;
  source: string;
}

interface OccupancyRateData {
  care_setting: string;
  inperson_rate: number;
  virtual_rate: number | null;
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

export function OperationalAssumptions() {
  const [workingDays, setWorkingDays] = useState<WorkingDaysData[]>([
    {
      setting: 'Primary Care',
      daysPerWeek: 6,
      weeksPerYear: 50,
      daysPerYear: 300,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Specialist Outpatient Care',
      daysPerWeek: 6,
      weeksPerYear: 50,
      daysPerYear: 300,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Emergency Care',
      daysPerWeek: 7,
      weeksPerYear: 52,
      daysPerYear: 365,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Major Diagnostic & Treatment',
      daysPerWeek: 6,
      weeksPerYear: 50,
      daysPerYear: 300,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Day Cases',
      daysPerWeek: 6,
      weeksPerYear: 50,
      daysPerYear: 300,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Inpatient Care',
      daysPerWeek: 7,
      weeksPerYear: 52,
      daysPerYear: 365,
      source: 'Based on NEOM operational decision (to be validated)'
    }
  ]);

  const [workingHours, setWorkingHours] = useState<WorkingHoursData[]>([
    {
      setting: 'Primary Care',
      hoursPerDay: 12,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Specialist Outpatient Care',
      hoursPerDay: 12,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Emergency Care',
      hoursPerDay: 24,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Major Diagnostic & Treatment',
      hoursPerDay: 12,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Day Cases',
      hoursPerDay: 12,
      source: 'Based on NEOM operational decision (to be validated)'
    },
    {
      setting: 'Inpatient Care',
      hoursPerDay: 24,
      source: 'Based on NEOM operational decision (to be validated)'
    }
  ]);

  const [occupancyRates, setOccupancyRates] = useState<OccupancyRateData[]>([
    {
      care_setting: 'Primary Care',
      inperson_rate: 0.70,
      virtual_rate: 0.90,
      source: 'BMJ'
    },
    {
      care_setting: 'Specialist Outpatient Care',
      inperson_rate: 0.70,
      virtual_rate: 0.90,
      source: 'BMJ'
    },
    {
      care_setting: 'Emergency Care',
      inperson_rate: 0.90,
      virtual_rate: 0.90,
      source: 'BMJ'
    },
    {
      care_setting: 'Major Diagnostic & Treatment',
      inperson_rate: 0.70,
      virtual_rate: null,
      source: 'No source available'
    },
    {
      care_setting: 'Day Cases',
      inperson_rate: 0.70,
      virtual_rate: 0.90,
      source: 'No source available'
    },
    {
      care_setting: 'Medical Inpatients',
      inperson_rate: 0.85,
      virtual_rate: 0.90,
      source: 'BMJ'
    },
    {
      care_setting: 'Elective Inpatients',
      inperson_rate: 0.85,
      virtual_rate: 0.90,
      source: 'BMJ'
    },
    {
      care_setting: 'Surgical Emergencies',
      inperson_rate: 0.85,
      virtual_rate: 0.90,
      source: 'BMJ'
    }
  ]);

  const updateWorkingDays = (index: number, field: keyof WorkingDaysData, value: number | string) => {
    const newData = [...workingDays];
    newData[index] = { ...newData[index], [field]: value };
    
    if (field === 'daysPerWeek' || field === 'weeksPerYear') {
      newData[index].daysPerYear = newData[index].daysPerWeek * newData[index].weeksPerYear;
    }
    
    setWorkingDays(newData);
  };

  const updateWorkingHours = (index: number, field: keyof WorkingHoursData, value: number | string) => {
    const newData = [...workingHours];
    newData[index] = { ...newData[index], [field]: value };
    setWorkingHours(newData);
  };

  const handleOccupancyRateChange = (index: number, field: keyof OccupancyRateData, value: number | string) => {
    const newData = [...occupancyRates];
    newData[index] = { ...newData[index], [field]: value };
    setOccupancyRates(newData);
  };

  return (
    <div className="space-y-8">
      {/* Visualizations */}
      <OperationalVisualizations 
        workingDays={workingDays}
        workingHours={workingHours}
        occupancyRates={occupancyRates}
      />

      {/* Available Days per Year */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-2 mb-6">
          <Calendar className="h-6 w-6 text-emerald-600" />
          <h2 className="text-xl font-semibold text-gray-900">Available Days per Year By Setting of Care</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Setting</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Working days per week</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Working weeks per year</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Available Days per year</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Source</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {workingDays.map((row, index) => (
                <tr key={index}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{row.setting}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <EditableNumberCell 
                      value={row.daysPerWeek} 
                      onChange={(value) => updateWorkingDays(index, 'daysPerWeek', value)} 
                    />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <EditableNumberCell 
                      value={row.weeksPerYear} 
                      onChange={(value) => updateWorkingDays(index, 'weeksPerYear', value)} 
                    />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <EditableNumberCell 
                      value={row.daysPerYear} 
                      onChange={(value) => updateWorkingDays(index, 'daysPerYear', value)} 
                    />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <EditableTextCell 
                      value={row.source} 
                      onChange={(value) => updateWorkingDays(index, 'source', value)} 
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Working Hours */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-2 mb-6">
          <Clock className="h-6 w-6 text-emerald-600" />
          <h2 className="text-xl font-semibold text-gray-900">Working Hours by Setting of Care</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Setting</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Working hours per day</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Source</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {workingHours.map((row, index) => (
                <tr key={index}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{row.setting}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <EditableNumberCell 
                      value={row.hoursPerDay} 
                      onChange={(value) => updateWorkingHours(index, 'hoursPerDay', value)} 
                    />
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <EditableTextCell 
                      value={row.source} 
                      onChange={(value) => updateWorkingHours(index, 'source', value)} 
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Occupancy Rates */}
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center space-x-2 mb-6">
          <Info className="h-6 w-6 text-emerald-600" />
          <h2 className="text-xl font-semibold text-gray-900">Occupancy Rate by Setting of Care</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Setting</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Inperson Occupancy Rates</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Virtual Occupancy Rates</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Source</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {occupancyRates.map((row, index) => (
                <tr key={index}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{row.care_setting}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="space-y-2">
                      <div className="flex items-center justify-between">
                        <EditableNumberCell 
                          value={Math.round(row.inperson_rate * 100)} 
                          onChange={(value) => handleOccupancyRateChange(index, 'inperson_rate', value / 100)} 
                        />
                        <span className="text-sm text-gray-500">%</span>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-2">
                        <div 
                          className="bg-emerald-500 h-2 rounded-full transition-all duration-300"
                          style={{ width: `${row.inperson_rate * 100}%` }}
                        />
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {row.virtual_rate !== null ? (
                      <div className="space-y-2">
                        <div className="flex items-center justify-between">
                          <EditableNumberCell 
                            value={Math.round(row.virtual_rate * 100)} 
                            onChange={(value) => handleOccupancyRateChange(index, 'virtual_rate', value / 100)} 
                          />
                          <span className="text-sm text-gray-500">%</span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-blue-500 h-2 rounded-full transition-all duration-300"
                            style={{ width: `${row.virtual_rate * 100}%` }}
                          />
                        </div>
                      </div>
                    ) : (
                      <span className="text-sm text-gray-500">-</span>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <EditableTextCell 
                      value={row.source} 
                      onChange={(value) => handleOccupancyRateChange(index, 'source', value)} 
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Specialty Occupancy Rates component before Visit Time Assumptions */}
      <SpecialtyOccupancyRates />

      {/* Visit Time Assumptions Components */}
      <VisitTimeAssumptions />
      <SpecialistVisitTimeAssumptions />
    </div>
  );
}