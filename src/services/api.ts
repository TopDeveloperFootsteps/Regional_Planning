const API_BASE_URL = 'http://localhost:4000/api';

export const api = {
  async get(endpoint: string) {
    const response = await fetch(`${API_BASE_URL}${endpoint}`);
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`API Error: ${response.statusText} - ${errorData.message || ''}`);
    }
    return response.json();
  },

  async post(endpoint: string, data: Record<string, unknown>) {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`API Error: ${response.statusText} - ${errorData.message || ''}`);
    }
    return response.json();
  },

  async put(endpoint: string, data: Record<string, unknown>) {
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`API Error: ${response.statusText} - ${errorData.message || ''}`);
    }
    return response.json();
  }
}; 