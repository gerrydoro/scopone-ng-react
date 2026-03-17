import React from "react";
import { BrowserRouter } from "react-router-dom";
import { ThemeProvider, createTheme } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";

import "./App.css";
import { Game } from "./components/game/game";

// MUI v6 Theme
const theme = createTheme({
  palette: {
    mode: "dark",
    primary: {
      main: "#2d5016",
    },
    secondary: {
      main: "#d4af37",
    },
    background: {
      default: "#1a1a2e",
      paper: "rgba(26, 26, 46, 0.95)",
    },
  },
  typography: {
    fontFamily: '"Segoe UI", "Roboto", "Helvetica", "Arial", sans-serif',
  },
  shape: {
    borderRadius: 12,
  },
});

function App() {
  return (
    <BrowserRouter>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <div className="App">
          <Game />
        </div>
        <span className="version-footer">
          Version {process.env.REACT_APP_VERSION}
        </span>
      </ThemeProvider>
    </BrowserRouter>
  );
}

export default App;
