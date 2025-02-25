import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Documentation } from './pages/Documentation';
import { Support } from './pages/Support';
import { ApiReference } from './pages/ApiReference';
import { Home } from './pages/Home';
import { ServicesAndCS } from './pages/ServicesAndCS';
import { Regions } from './pages/Regions';
import { Assets } from './pages/Assets';
import { Population } from './pages/Population';
import { Assumptions } from './pages/Assumptions';
import { DemandCapacity } from './pages/DemandCapacity';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/services-and-cs" element={<ServicesAndCS />} />
        <Route path="/documentation" element={<Documentation />} />
        <Route path="/support" element={<Support />} />
        <Route path="/api-reference" element={<ApiReference />} />
        <Route path="/regions" element={<Regions />} />
        <Route path="/assets" element={<Assets />} />
        <Route path="/population" element={<Population />} />
        <Route path="/assumptions" element={<Assumptions />} />
        <Route path="/demand-capacity" element={<DemandCapacity />} />
      </Routes>
    </Router>
  );
}

export default App;