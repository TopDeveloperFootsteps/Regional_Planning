import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import { Region } from '../../types/regions';

interface RegionFormProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (region: Partial<Region>) => Promise<void>;
  region?: Region;
}

const defaultFormData: Partial<Region> = {
  name: '',
  latitude: 0,
  longitude: 0,
  status: 'active' as const,
  is_neom: true
};

export function RegionForm({ isOpen, onClose, onSave, region }: RegionFormProps) {
  const [formData, setFormData] = useState<Partial<Region>>(defaultFormData);
  const [isSaving, setIsSaving] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!isOpen) {
      setFormData(defaultFormData);
      setErrors({});
    } else if (region) {
      setFormData(region);
      setErrors({});
    } else {
      setFormData(defaultFormData);
      setErrors({});
    }
  }, [isOpen, region]);

  if (!isOpen) return null;

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.name?.trim()) {
      newErrors.name = 'Name is required';
    }

    if (formData.latitude === undefined || formData.latitude === null || isNaN(formData.latitude)) {
      newErrors.latitude = 'Valid latitude is required';
    } else if (formData.latitude < -90 || formData.latitude > 90) {
      newErrors.latitude = 'Latitude must be between -90 and 90';
    }

    if (formData.longitude === undefined || formData.longitude === null || isNaN(formData.longitude)) {
      newErrors.longitude = 'Valid longitude is required';
    } else if (formData.longitude < -180 || formData.longitude > 180) {
      newErrors.longitude = 'Longitude must be between -180 and 180';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSave = async () => {
    if (!validateForm()) {
      return;
    }

    setIsSaving(true);
    try {
      await onSave(formData);
      onClose();
    } catch (error) {
      console.error('Error saving region:', error);
      setErrors({ submit: 'Failed to save region. Please try again.' });
    } finally {
      setIsSaving(false);
    }
  };

  const handleInputChange = (field: keyof Region, value: any) => {
    if (value === '' && (field === 'latitude' || field === 'longitude')) {
      value = null;
    }
    
    if (value !== null && (field === 'latitude' || field === 'longitude')) {
      value = parseFloat(value) || 0;
    }

    setFormData(prev => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-md">
        <div className="flex justify-between items-center p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">
            {region ? 'Edit Region' : 'Add New Region'}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-500"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="p-6 space-y-6">
          <div className="space-y-4">
            {region && (
              <div>
                <label className="block text-sm font-medium text-gray-700">Region ID</label>
                <input
                  type="text"
                  value={region.id}
                  disabled
                  className="mt-1 block w-full rounded-md border-gray-300 bg-gray-100 shadow-sm sm:text-sm cursor-not-allowed"
                />
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700">Name</label>
              <input
                type="text"
                value={formData.name || ''}
                onChange={(e) => handleInputChange('name', e.target.value)}
                className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
                  errors.name 
                    ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
                    : 'border-gray-300 focus:border-emerald-500 focus:ring-emerald-500'
                }`}
              />
              {errors.name && (
                <p className="mt-1 text-sm text-red-600">{errors.name}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">NEOM</label>
              <select
                value={formData.is_neom ? 'yes' : 'no'}
                onChange={(e) => handleInputChange('is_neom', e.target.value === 'yes')}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
              >
                <option value="yes">Yes</option>
                <option value="no">No</option>
              </select>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Latitude</label>
                <input
                  type="number"
                  step="any"
                  value={formData.latitude ?? ''}
                  onChange={(e) => handleInputChange('latitude', e.target.value)}
                  className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
                    errors.latitude 
                      ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
                      : 'border-gray-300 focus:border-emerald-500 focus:ring-emerald-500'
                  }`}
                />
                {errors.latitude && (
                  <p className="mt-1 text-sm text-red-600">{errors.latitude}</p>
                )}
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Longitude</label>
                <input
                  type="number"
                  step="any"
                  value={formData.longitude ?? ''}
                  onChange={(e) => handleInputChange('longitude', e.target.value)}
                  className={`mt-1 block w-full rounded-md shadow-sm sm:text-sm ${
                    errors.longitude 
                      ? 'border-red-300 focus:border-red-500 focus:ring-red-500'
                      : 'border-gray-300 focus:border-emerald-500 focus:ring-emerald-500'
                  }`}
                />
                {errors.longitude && (
                  <p className="mt-1 text-sm text-red-600">{errors.longitude}</p>
                )}
              </div>
            </div>

            {region && (
              <div>
                <label className="block text-sm font-medium text-gray-700">Status</label>
                <select
                  value={formData.status}
                  onChange={(e) => handleInputChange('status', e.target.value as 'active' | 'inactive')}
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-emerald-500 focus:ring-emerald-500 sm:text-sm"
                >
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                </select>
              </div>
            )}
          </div>

          {errors.submit && (
            <div className="text-sm text-red-600 mt-2">{errors.submit}</div>
          )}
        </div>

        <div className="flex justify-end gap-3 px-6 py-4 bg-gray-50 rounded-b-lg">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={handleSave}
            disabled={isSaving}
            className="px-4 py-2 text-sm font-medium text-white bg-emerald-600 border border-transparent rounded-md hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 disabled:opacity-50"
          >
            {isSaving ? 'Saving...' : 'Save Region'}
          </button>
        </div>
      </div>
    </div>
  );
}