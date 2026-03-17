import { FC, useState } from "react";
import { Link, useLocation } from "react-router-dom";
import "./navigation.css";

interface NavigationProps {
  playerName?: string;
}

export const Navigation: FC<NavigationProps> = ({ playerName }) => {
  const [menuOpen, setMenuOpen] = useState(false);
  const location = useLocation();

  const navItems = [
    { path: "/pick-game", label: "🎮 Games", icon: "🎮" },
    { path: "/hand", label: "🃏 Play", icon: "🃏" },
    { path: "/hand-history", label: "📜 History", icon: "📜" },
    { path: "/hand-result", label: "🏆 Results", icon: "🏆" },
  ];

  const isActive = (path: string) => location.pathname === path;

  return (
    <nav className="navigation">
      <div className="nav-container">
        {/* Logo / Brand */}
        <Link to="/" className="nav-brand">
          <span className="brand-icon">🎴</span>
          <span className="brand-text">Scopone</span>
        </Link>

        {/* Desktop Navigation */}
        <div className="nav-desktop">
          <div className="nav-links">
            {navItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                className={`nav-link ${isActive(item.path) ? "active" : ""}`}
              >
                <span className="nav-icon">{item.icon}</span>
                <span className="nav-label">{item.label}</span>
              </Link>
            ))}
          </div>

          {playerName && (
            <div className="nav-player">
              <span className="player-avatar">👤</span>
              <span className="player-name">{playerName}</span>
            </div>
          )}
        </div>

        {/* Mobile Menu Button */}
        <button
          className={`nav-toggle ${menuOpen ? "active" : ""}`}
          onClick={() => setMenuOpen(!menuOpen)}
          aria-label="Toggle menu"
        >
          <span className="toggle-bar"></span>
          <span className="toggle-bar"></span>
          <span className="toggle-bar"></span>
        </button>
      </div>

      {/* Mobile Navigation */}
      <div className={`nav-mobile ${menuOpen ? "open" : ""}`}>
        <div className="nav-mobile-content">
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={`nav-mobile-link ${isActive(item.path) ? "active" : ""}`}
              onClick={() => setMenuOpen(false)}
            >
              <span className="nav-icon">{item.icon}</span>
              <span className="nav-label">{item.label}</span>
              {isActive(item.path) && (
                <span className="nav-active-indicator"></span>
              )}
            </Link>
          ))}

          {playerName && (
            <div className="nav-mobile-player">
              <span className="player-avatar">👤</span>
              <span className="player-name">{playerName}</span>
            </div>
          )}
        </div>
      </div>

      {/* Overlay */}
      {menuOpen && (
        <div
          className="nav-overlay"
          onClick={() => setMenuOpen(false)}
        />
      )}
    </nav>
  );
};
