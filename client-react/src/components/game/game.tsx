import React, { useContext, useEffect, useState } from "react";
import { Routes, Route, useNavigate, useLocation } from "react-router-dom";

import { ServerContext } from "../../context/server-context";
import { SignIn } from "../sign-in/sign-in";
import { switchMap, tap } from "rxjs/operators";
import { merge } from "rxjs";
import { PlayerState } from "../../../../scopone-rx-service/src/model/player";

import "./game.css";
import { PickGame } from "../pick-game/pick-game";
import { Hand } from "../hand/hand";
import { HandResult } from "../hand-result/hand-result";
import { Error } from "../error/error";
import { ErrorContext } from "../../context/error-context";
import { Bye } from "../bye/bye";
import { HandHistory } from "../hand-history/hand-history";
import { Navigation } from "../navigation/navigation";

const serverAddress = process.env.REACT_APP_SERVER_ADDRESS;

type GameReactState = {
  title: string;
  errorMsg?: string;
  playerName?: string;
};

export const Game = () => {
  const server = useContext(ServerContext);
  const errorService = useContext(ErrorContext);

  const [gameReactState, setGameReactState] = useState<GameReactState>({
    title: "🎴 Scopone - Italian Card Game",
  });

  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    console.log("=======> Game Component Effect run");

    // Force to go to home page when this component is first loaded
    navigate("/");

    // navigate$ Observable manages navigation as a side effect
    const navigate$ = server.playerEnteredOsteria$.pipe(
      tap((player: any) => {
        setGameReactState((prevState) => ({
          ...prevState,
          errorMsg: undefined,
          playerName: player.name,
        }));
        switch (player.status) {
          case PlayerState.playerNotPlaying:
            navigate("/pick-game");
            break;
          case PlayerState.playerPlaying:
            navigate("/hand");
            break;
          case PlayerState.playerObservingGames:
            navigate("/hand");
            break;
          case PlayerState.playerLookingAtHandResult:
            navigate("/hand-result");
            break;
          default:
            const errMsg = `State "${player.status}" is not expected`;
            console.error(errMsg);
        }
      })
    );

    const gameClosed$ = server.myCurrentGameClosed$.pipe(
      tap(() => navigate("/bye"))
    );

    const error$ = errorService.error$.pipe(
      tap((errorMsg: any) =>
        setGameReactState((prevState) => ({ ...prevState, errorMsg }))
      )
    );

    const _title$ = server.title$.pipe(
      tap((newTitle: string) =>
        setGameReactState((prevState) => ({ ...prevState, title: newTitle }))
      )
    );

    const subscription = server
      .connect(serverAddress)
      .pipe(switchMap(() => merge(navigate$, gameClosed$, error$, _title$)))
      .subscribe({
        error: (err: any) => {
          console.log("Error while communicating with the server", err);
          setGameReactState((prevState) => ({
            ...prevState,
            errorMsg: err.message,
          }));
        },
      });

    return () => {
      console.log("Unsubscribe Game subscription");
      subscription.unsubscribe();
    };
  }, [server, errorService, navigate]);

  const hideNavigation = ["/", "/error"].includes(location.pathname);

  return (
    <div className="game-container">
      {/* Poker Table Background */}
      <div className="poker-table-bg">
        <div className="poker-table-felt"></div>
        <div className="poker-table-edge"></div>
      </div>

      {/* Navigation Menu */}
      {!hideNavigation && <Navigation playerName={gameReactState.playerName} />}

      {/* Main Content */}
      <div className="game-content">
        <div className="game-card fade-in">
          <div className="game-card-header">
            <h1 className="game-card-title">{gameReactState.title}</h1>
            {gameReactState.playerName && (
              <span className="player-badge">
                👤 {gameReactState.playerName}
              </span>
            )}
          </div>
          <div className="game-card-content">
            <Routes>
              <Route path="/" element={<SignIn />} />
              <Route path="/pick-game" element={<PickGame />} />
              <Route path="/hand" element={<Hand />} />
              <Route path="/hand-result" element={<HandResult />} />
              <Route path="/bye" element={<Bye />} />
              <Route path="/hand-history" element={<HandHistory />} />
              <Route path="*" element={<Error />} />
            </Routes>
          </div>
        </div>

        {/* Error Display */}
        {gameReactState.errorMsg && (
          <div className="error-toast fade-in">
            <div className="error-toast-content">
              <span className="error-icon">⚠️</span>
              <span className="error-message">{gameReactState.errorMsg}</span>
              <button
                className="error-close"
                onClick={() =>
                  setGameReactState((prevState) => ({
                    ...prevState,
                    errorMsg: undefined,
                  }))
                }
              >
                ✕
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Footer */}
      <footer className="game-footer">
        <span>Version {process.env.REACT_APP_VERSION}</span>
        <span className="hidden-mobile">•</span>
        <span className="hidden-mobile">Scopone Card Game</span>
      </footer>
    </div>
  );
};
