import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  Card,
  CardContent,
  CardHeader,
  TextField,
  Button,
  Box,
  Typography,
  Alert,
} from "@mui/material";
import { useSettings } from "../../context/settings-context";
import { getServerAddress } from "../../helpers/server-address";
import "./settings.css";

export const Settings: React.FC = () => {
  const { serverAddress, setServerAddress, resetServerAddress } = useSettings();
  const navigate = useNavigate();
  const [tempAddress, setTempAddress] = useState(serverAddress);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState("");

  const handleSave = () => {
    if (!tempAddress.trim()) {
      setError("Server address cannot be empty");
      return;
    }

    // Basic validation
    if (
      !tempAddress.startsWith("ws://") &&
      !tempAddress.startsWith("wss://")
    ) {
      setError("Server address must start with ws:// or wss://");
      return;
    }

    setError("");
    setServerAddress(tempAddress);
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  const handleReset = () => {
    resetServerAddress();
    setTempAddress(getServerAddress());
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  const examples = [
    "ws://localhost:8080/osteria",
    "wss://server-scopone.gerryd.myaddr.io/osteria",
    "wss://server-scopone.gerryd.it/osteria",
  ];

  return (
    <div className="settings-container">
      <Card className="settings-card">
        <CardHeader
          title="⚙️ Server Settings"
          className="settings-header"
          subheader="Configure the WebSocket server address"
        />
        <CardContent>
          <Box sx={{ mb: 3 }}>
            <TextField
              fullWidth
              label="Server Address"
              value={tempAddress}
              onChange={(e) => setTempAddress(e.target.value)}
              placeholder="ws://localhost:8080/osteria"
              helperText="The WebSocket URL of the Scopone server"
              error={!!error}
              variant="outlined"
            />
            {error && (
              <Alert severity="error" sx={{ mt: 1 }}>
                {error}
              </Alert>
            )}
            {saved && (
              <Alert severity="success" sx={{ mt: 1 }}>
                Server address saved successfully!
              </Alert>
            )}
          </Box>

          <Box sx={{ mb: 3 }}>
            <Typography variant="subtitle2" gutterBottom>
              Quick Select:
            </Typography>
            <Box sx={{ display: "flex", flexWrap: "wrap", gap: 1 }}>
              {examples.map((example) => (
                <Button
                  key={example}
                  size="small"
                  variant="outlined"
                  onClick={() => setTempAddress(example)}
                  sx={{ fontSize: "0.75rem" }}
                >
                  {example}
                </Button>
              ))}
            </Box>
          </Box>

          <Box sx={{ display: "flex", gap: 2, flexWrap: "wrap" }}>
            <Button
              variant="contained"
              color="primary"
              onClick={handleSave}
              size="large"
            >
              Save Settings
            </Button>
            <Button
              variant="outlined"
              color="secondary"
              onClick={handleReset}
              size="large"
            >
              Reset to Default
            </Button>
            <Button
              variant="text"
              onClick={() => navigate("/")}
              size="large"
            >
              Back to Home
            </Button>
          </Box>

          <Alert severity="info" sx={{ mt: 3 }}>
            <Typography variant="body2">
              <strong>Note:</strong> After changing the server address, you may
              need to refresh the page for the changes to take effect.
            </Typography>
          </Alert>
        </CardContent>
      </Card>
    </div>
  );
};
