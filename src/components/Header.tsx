import React, { useState, useEffect } from "react";
import { Link, useLocation } from "react-router-dom";
import { supabase } from "../lib/supabase";
import { Loader2, Map } from "lucide-react";

export function Header() {
  const [logoUrl, setLogoUrl] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const location = useLocation();

  useEffect(() => {
    async function getLogoUrl() {
      try {
        setIsLoading(true);
        setError(null);
        const {
          data: { publicUrl },
        } = supabase.storage.from("image").getPublicUrl("NEOM_logo.svg");

        if (publicUrl) {
          setLogoUrl(publicUrl);
        } else {
          setError("Failed to load logo");
        }
      } catch (err) {
        setError("Failed to load logo");
        console.error("Error loading logo:", err);
      } finally {
        setIsLoading(false);
      }
    }

    getLogoUrl();
  }, []);

  return (
    <header className="bg-gradient-to-r from-emerald-50 to-teal-50 border-b border-emerald-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="flex items-center justify-between">
          <Link to="/" className="flex items-center space-x-4">
            <div className="h-12 w-12 flex items-center justify-center">
              {isLoading ? (
                <Loader2 className="h-6 w-6 text-emerald-600 animate-spin" />
              ) : logoUrl && !error ? (
                <img
                  src={logoUrl}
                  alt="NEOM Logo"
                  className="h-12 w-auto"
                  onError={() => setError("Failed to load logo")}
                />
              ) : (
                <Map className="h-8 w-8 text-emerald-600" />
              )}
            </div>
            <div>
              <h1 className="text-2xl font-bold bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
                Regional Planning Models
              </h1>
              <p className="text-sm text-gray-600">
                Healthcare Infrastructure Planning
              </p>
            </div>
          </Link>
          <nav className="hidden md:flex items-center space-x-6">
            <Link
              to="/"
              className={`text-gray-600 hover:text-emerald-600 transition-colors font-medium ${
                location.pathname === "/" ? "text-emerald-600" : ""
              }`}
            >
              Overview
            </Link>
            <Link
              to="/services-and-cs"
              className={`text-gray-600 hover:text-emerald-600 transition-colors font-medium ${
                location.pathname.startsWith("/services-and-cs")
                  ? "text-emerald-600"
                  : ""
              }`}
            >
              Services & CS
            </Link>
            <Link
              to="/regions"
              className={`text-gray-600 hover:text-emerald-600 transition-colors font-medium ${
                location.pathname === "/regions" ? "text-emerald-600" : ""
              }`}
            >
              Regions
            </Link>
            <Link
              to="/assets"
              className={`text-gray-600 hover:text-emerald-600 transition-colors font-medium ${
                location.pathname === "/assets" ? "text-emerald-600" : ""
              }`}
            >
              Assets
            </Link>
            <Link
              to="/population"
              className={`text-gray-600 hover:text-emerald-600 transition-colors font-medium ${
                location.pathname === "/population" ? "text-emerald-600" : ""
              }`}
            >
              Population
            </Link>
            <Link
              to="/assumptions"
              className={`text-gray-600 hover:text-emerald-600 transition-colors font-medium ${
                location.pathname === "/assumptions" ? "text-emerald-600" : ""
              }`}
            >
              Assumptions
            </Link>
            <Link
              to="/demand-capacity"
              className={`text-gray-600 hover:text-emerald-600 transition-colors font-medium ${
                location.pathname === "/demand-capacity"
                  ? "text-emerald-600"
                  : ""
              }`}
            >
              D&C Output
            </Link>
          </nav>
        </div>
      </div>
    </header>
  );
}
