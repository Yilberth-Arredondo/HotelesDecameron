import { Route, BrowserRouter as Router, Routes } from 'react-router-dom';
import ProtectedRoute from './components/auth/ProtectedRoute';
import Layout from './components/layout/Layout';
import { AuthProvider } from './context/AuthContext';
import Dashboard from './pages/Dashboard';
import HotelDetail from './pages/Hotels/HotelDetail';
import HotelsList from './pages/Hotels/HotelsList';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route
            path='/*'
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }>
            <Route
              index
              element={<Dashboard />}
            />
            <Route
              path='hotels'
              element={<HotelsList />}
            />
            <Route
              path='hotels/:id'
              element={<HotelDetail />}
            />
          </Route>
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
