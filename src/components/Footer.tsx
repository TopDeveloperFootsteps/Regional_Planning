// import React from 'react';
import { Link } from "react-router-dom";
import { Mail, Phone, FileText, BookOpen, HelpCircle } from "lucide-react";

export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-gradient-to-r from-emerald-50 to-teal-50 border-t border-emerald-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-12">
          <div>
            <h3 className="text-sm font-semibold text-gray-900 uppercase tracking-wider">
              About
            </h3>
            <p className="mt-4 text-base text-gray-600 leading-relaxed">
              Regional Planning Models is a comprehensive healthcare
              infrastructure planning system that helps optimize the
              distribution of healthcare facilities and services across
              different regions, ensuring efficient resource allocation and
              improved healthcare accessibility.
            </p>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-gray-900 uppercase tracking-wider">
              Quick Links
            </h3>
            <ul className="mt-4 space-y-3">
              <li>
                <Link
                  to="/documentation"
                  className="group flex items-center text-base text-gray-600 hover:text-emerald-600 transition-colors"
                >
                  <FileText className="h-5 w-5 mr-2 text-gray-400 group-hover:text-emerald-500 transition-colors" />
                  Documentation
                </Link>
              </li>
              <li>
                <Link
                  to="/api-reference"
                  className="group flex items-center text-base text-gray-600 hover:text-emerald-600 transition-colors"
                >
                  <BookOpen className="h-5 w-5 mr-2 text-gray-400 group-hover:text-emerald-500 transition-colors" />
                  API Reference
                </Link>
              </li>
              <li>
                <Link
                  to="/support"
                  className="group flex items-center text-base text-gray-600 hover:text-emerald-600 transition-colors"
                >
                  <HelpCircle className="h-5 w-5 mr-2 text-gray-400 group-hover:text-emerald-500 transition-colors" />
                  Support
                </Link>
              </li>
            </ul>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-gray-900 uppercase tracking-wider">
              Contact
            </h3>
            <ul className="mt-4 space-y-3">
              <li>
                <a
                  href="mailto:support@neom.com"
                  className="group flex items-center text-base text-gray-600 hover:text-emerald-600 transition-colors"
                >
                  <Mail className="h-5 w-5 mr-2 text-gray-400 group-hover:text-emerald-500 transition-colors" />
                  support@neom.com
                </a>
              </li>
              <li>
                <a
                  href="tel:+15551234567"
                  className="group flex items-center text-base text-gray-600 hover:text-emerald-600 transition-colors"
                >
                  <Phone className="h-5 w-5 mr-2 text-gray-400 group-hover:text-emerald-500 transition-colors" />
                  +1 (555) 123-4567
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="mt-12 pt-8 border-t border-gray-200">
          <p className="text-center text-base text-gray-600">
            © {currentYear} NEOM Healthcare. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}
