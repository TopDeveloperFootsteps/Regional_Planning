import { useEffect, useState } from "react";
import { api } from "../services/api";
import { Database, Loader2 } from "lucide-react";

interface TableInfo {
  name: string;
  count: number;
}

export function TableList() {
  const [tables, setTables] = useState<TableInfo[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchTables() {
      try {
        setLoading(true);
        setError(null);

        const response = await api.get("/tablelist"); // Update to your backend API
        setTables(response);
      } catch (err) {
        console.error("Error fetching tables:", err);
        setError("Failed to fetch table information");
      } finally {
        setLoading(false);
      }
    }

    fetchTables();
  }, []);

  const formatTableName = (name: string): string => {
    return name
      .split("_")
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
      .join(" ");
  };

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="flex items-center justify-center space-x-2">
          <Loader2 className="h-5 w-5 text-emerald-600 animate-spin" />
          <span className="text-gray-600">Loading tables...</span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-white rounded-lg shadow-sm p-6">
        <div className="text-red-600 text-sm">{error}</div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex items-center space-x-2 mb-4">
        <Database className="h-5 w-5 text-emerald-600" />
        <h2 className="text-lg font-semibold text-gray-900">Database Tables</h2>
      </div>

      {tables.length === 0 ? (
        <p className="text-gray-500 text-sm">No tables available</p>
      ) : (
        <ul className="space-y-2">
          {tables.map((table) => (
            <li
              key={table.name}
              className="flex items-center justify-between text-sm p-2 hover:bg-gray-50 rounded-md transition-colors"
            >
              <span className="text-gray-600">
                {formatTableName(table.name)}
              </span>
              <span className="text-gray-400 text-xs">
                {table.count} records
              </span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
