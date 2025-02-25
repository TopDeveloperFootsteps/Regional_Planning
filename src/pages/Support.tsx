import React from 'react';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Mail, MessageCircle, Phone, Clock } from 'lucide-react';

export function Support() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      
      <main className="flex-grow p-8">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white rounded-lg shadow-sm p-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-6">Support Center</h1>
            
            <div className="space-y-8">
              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">Contact Us</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="bg-emerald-50 rounded-lg p-6">
                    <div className="flex items-start">
                      <Mail className="h-6 w-6 text-emerald-600 mt-1" />
                      <div className="ml-4">
                        <h3 className="text-lg font-semibold text-gray-900">Email Support</h3>
                        <p className="mt-2 text-gray-600">support@neom.com</p>
                        <p className="mt-1 text-sm text-gray-500">24/7 response time</p>
                      </div>
                    </div>
                  </div>

                  <div className="bg-emerald-50 rounded-lg p-6">
                    <div className="flex items-start">
                      <Phone className="h-6 w-6 text-emerald-600 mt-1" />
                      <div className="ml-4">
                        <h3 className="text-lg font-semibold text-gray-900">Phone Support</h3>
                        <p className="mt-2 text-gray-600">+1 (555) 123-4567</p>
                        <p className="mt-1 text-sm text-gray-500">Mon-Fri, 9am-5pm EST</p>
                      </div>
                    </div>
                  </div>
                </div>
              </section>

              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">Support Hours</h2>
                <div className="bg-emerald-50 rounded-lg p-6">
                  <div className="flex items-start">
                    <Clock className="h-6 w-6 text-emerald-600 mt-1" />
                    <div className="ml-4">
                      <h3 className="text-lg font-semibold text-gray-900">Operating Hours</h3>
                      <ul className="mt-2 space-y-2 text-gray-600">
                        <li>Monday - Friday: 9:00 AM - 5:00 PM EST</li>
                        <li>Saturday: 10:00 AM - 2:00 PM EST</li>
                        <li>Sunday: Closed</li>
                      </ul>
                      <p className="mt-4 text-sm text-gray-500">
                        Emergency support available 24/7 via email
                      </p>
                    </div>
                  </div>
                </div>
              </section>

              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">FAQ</h2>
                <div className="space-y-4">
                  <div className="border border-gray-200 rounded-lg p-4">
                    <h3 className="text-lg font-medium text-gray-900">How do I reset my password?</h3>
                    <p className="mt-2 text-gray-600">
                      Click on the "Forgot Password" link on the login page and follow the instructions 
                      sent to your registered email address.
                    </p>
                  </div>
                  <div className="border border-gray-200 rounded-lg p-4">
                    <h3 className="text-lg font-medium text-gray-900">Can I bulk upload ICD-10 codes?</h3>
                    <p className="mt-2 text-gray-600">
                      Yes, you can upload a CSV file containing multiple ICD-10 codes for batch processing.
                    </p>
                  </div>
                  <div className="border border-gray-200 rounded-lg p-4">
                    <h3 className="text-lg font-medium text-gray-900">How accurate are the mappings?</h3>
                    <p className="mt-2 text-gray-600">
                      Each mapping includes a confidence score indicating the accuracy level. High confidence 
                      mappings are validated by healthcare professionals.
                    </p>
                  </div>
                </div>
              </section>

              <section>
                <h2 className="text-2xl font-semibold text-gray-800 mb-4">Live Chat</h2>
                <div className="bg-emerald-50 rounded-lg p-6">
                  <div className="flex items-start">
                    <MessageCircle className="h-6 w-6 text-emerald-600 mt-1" />
                    <div className="ml-4">
                      <h3 className="text-lg font-semibold text-gray-900">Start a Chat</h3>
                      <p className="mt-2 text-gray-600">
                        Connect with our support team in real-time during business hours.
                      </p>
                      <button className="mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-emerald-600 hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500">
                        Start Chat
                      </button>
                    </div>
                  </div>
                </div>
              </section>
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}