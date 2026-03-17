import React, { ChangeEvent, FC, useContext, useEffect, useState } from "react";
import { ServerContext } from "../../context/server-context";
import { ErrorContext } from "../../context/error-context";
import { tap } from "rxjs/operators";
import "./sign-in.css";

export const SignIn: FC = () => {
  const [playerName, setPlayerName] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const server = useContext(ServerContext);
  const errorService = useContext(ErrorContext);

  useEffect(() => {
    console.log("=======> SignIn Use Effect run");

    const playerAlreadyInOsteria$ = server.playerIsAlreadyInOsteria$.pipe(
      tap((pName) => {
        errorService.setError(`Player "${pName}" is already in the Osteria`);
      })
    );

    const subscription = playerAlreadyInOsteria$.subscribe();

    return () => {
      console.log("Unsubscribe SignIn subscription");
      subscription.unsubscribe();
    };
  }, [server, errorService]);

  const handleChange = (event: ChangeEvent<HTMLInputElement>) => {
    setPlayerName(event.target.value);
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      enterOsteria();
    }
  };

  const enterOsteria = () => {
    if (!playerName.trim()) {
      errorService.setError("Please provide a name");
      return;
    }
    setIsLoading(true);
    server.playerEntersOsteria(playerName);
  };

  return (
    <div className="sign-in-container">
      <div className="sign-in-card fade-in">
        <div className="sign-in-header">
          <div className="header-icon">👤</div>
          <h2 className="sign-in-title">Welcome to Scopone</h2>
          <p className="sign-in-subtitle">Enter your name to join the table</p>
        </div>

        <div className="sign-in-content">
          <div className="input-group">
            <label htmlFor="player-name" className="input-label">
              Player Name
            </label>
            <input
              id="player-name"
              type="text"
              className="input"
              placeholder="Enter your name"
              value={playerName}
              onChange={handleChange}
              onKeyPress={handleKeyPress}
              disabled={isLoading}
              autoFocus
            />
            <p className="input-hint">
              💡 Use the same name to reconnect if you lose your session
            </p>
          </div>

          <button
            className="btn btn-primary btn-large"
            onClick={enterOsteria}
            disabled={isLoading || !playerName.trim()}
          >
            {isLoading ? (
              <>
                <span className="spinner-small"></span>
                Joining...
              </>
            ) : (
              <>
                <span>🎴</span>
                Enter Table
              </>
            )}
          </button>
        </div>

        {/* Decorative elements */}
        <div className="decorative-cards">
          <div className="decorative-card card-1">🂡</div>
          <div className="decorative-card card-2">🂱</div>
          <div className="decorative-card card-3">🃁</div>
        </div>
      </div>

      <div className="sign-in-info">
        <div className="info-card">
          <h3>🎮 How to Play</h3>
          <ol>
            <li>Enter your name to join the game</li>
            <li>Create a new game or join an existing one</li>
            <li>Wait for 4 players to start</li>
            <li>Play your cards strategically</li>
            <li>Win by capturing cards from the table</li>
          </ol>
        </div>
      </div>
    </div>
  );
};
