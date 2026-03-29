import React from "react";

export interface SettingsState {
  serverAddress: string;
  setServerAddress: (address: string) => void;
  resetServerAddress: () => void;
}

const DEFAULT_SERVER_ADDRESS = "ws://localhost:8080/osteria";

const STORAGE_KEY = "scopone_server_address";

export const SettingsContext = React.createContext<SettingsState>({
  serverAddress: DEFAULT_SERVER_ADDRESS,
  setServerAddress: () => {},
  resetServerAddress: () => {},
});

export const SettingsProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [serverAddress, setServerAddressState] = React.useState<string>(() => {
    const stored = localStorage.getItem(STORAGE_KEY);
    return stored || DEFAULT_SERVER_ADDRESS;
  });

  const setServerAddress = (address: string) => {
    setServerAddressState(address);
    localStorage.setItem(STORAGE_KEY, address);
  };

  const resetServerAddress = () => {
    setServerAddressState(DEFAULT_SERVER_ADDRESS);
    localStorage.removeItem(STORAGE_KEY);
  };

  return (
    <SettingsContext.Provider
      value={{ serverAddress, setServerAddress, resetServerAddress }}
    >
      {children}
    </SettingsContext.Provider>
  );
};

export const useSettings = () => {
  const context = React.useContext(SettingsContext);
  if (!context) {
    throw new Error("useSettings must be used within a SettingsProvider");
  }
  return context;
};
