import React from 'react';
import { Link } from 'react-router-dom';
import { FileText, BookOpen, HelpCircle } from 'lucide-react';

export function QuickLinks() {
  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Links</h2>
      <div className="space-y-3">
        <Link 
          to="/documentation" 
          className="group flex items-center p-2 text-gray-600 hover:text-emerald-600 hover:bg-emerald-50 rounded-md transition-all"
        >
          <FileText className="h-5 w-5 mr-3 text-gray-400 group-hover:text-emerald-500" />
          Documentation
        </Link>
        <Link 
          to="/api-reference" 
          className="group flex items-center p-2 text-gray-600 hover:text-emerald-600 hover:bg-emerald-50 rounded-md transition-all"
        >
          <BookOpen className="h-5 w-5 mr-3 text-gray-400 group-hover:text-emerald-500" />
          API Reference
        </Link>
        <Link 
          to="/support" 
          className="group flex items-center p-2 text-gray-600 hover:text-emerald-600 hover:bg-emerald-50 rounded-md transition-all"
        >
          <HelpCircle className="h-5 w-5 mr-3 text-gray-400 group-hover:text-emerald-500" />
          Support
        </Link>
      </div>
    </div>
  );
}