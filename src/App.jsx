import { BrowserRouter, Routes, Route, useLocation } from "react-router-dom";
import { useLayoutEffect } from "react";
import Editor from "./pages/Editor";
import Templates from "./pages/Templates";
import SettingsContextProvider from "./context/SettingsContext";

export default function App() {
  return (
    <SettingsContextProvider>
      <BrowserRouter>
        <RestoreScroll />
        <Routes>
          <Route path="/" element={<Editor />} />
          <Route path="/templates" element={<Templates />} />
        </Routes>
      </BrowserRouter>
    </SettingsContextProvider>
  );
}

function RestoreScroll() {
  const location = useLocation();
  useLayoutEffect(() => {
    window.scroll(0, 0);
  }, [location.pathname]);
  return null;
}
