import React, { FC } from "react";
import { Card as CardObj } from "../../../../scopone-rx-service/src/model/card";
import { PlayerState } from "../../../../scopone-rx-service/src/model/player";
import { Team } from "../../../../scopone-rx-service/src/model/team";
import { Card } from "../card/card";

import "./table.css";

interface ITableProps {
  teams: [Team, Team];
  currentPlayerName: string;
  cards: CardObj[];
}

export const Table: FC<ITableProps> = ({ teams, currentPlayerName, cards }) => {
  const getPlayerName = (teamIndex: number, playerIndex: number) => {
    const player = teams[teamIndex]?.Players[playerIndex];
    if (!player) return "-";
    let name = player.name;
    if (player.status === PlayerState.playerLeftTheGame) {
      name += " (left the Osteria)";
    } else if (player.name === currentPlayerName) {
      name += " (can play card)";
    }
    return name;
  };

  const isCurrentPlayer = (teamIndex: number, playerIndex: number) => {
    return teams[teamIndex]?.Players[playerIndex]?.name === currentPlayerName;
  };

  const playerLeft = (teamIndex: number, playerIndex: number) => {
    return teams[teamIndex]?.Players[playerIndex]?.status === PlayerState.playerLeftTheGame;
  };

  const getPlayerClass = (baseClass: string, teamIndex: number, playerIndex: number) => {
    let classes = `player ${baseClass}`;
    if (playerLeft(teamIndex, playerIndex)) {
      classes += " player-absent";
    }
    if (isCurrentPlayer(teamIndex, playerIndex)) {
      classes += " current-player";
    }
    return classes;
  };

  const cardPosition = (index: number) => {
    const angle = (index / (cards.length || 1)) * 2 * Math.PI;
    const x = 50 + 20 * Math.cos(angle);
    const y = 50 + 20 * Math.sin(angle);
    return {
      left: `${x}%`,
      top: `${y}%`,
      transform: `translate(-50%, -50%) rotate(${angle + Math.PI / 2}rad)`,
    };
  };

  return (
    <div className="table-container">
      <div className="table">
        <div className="board">
          <div className={getPlayerClass("player-1", 0, 0)}>{getPlayerName(0, 0)}</div>
          <div className={getPlayerClass("player-2", 1, 0)}>{getPlayerName(1, 0)}</div>
          <div className={getPlayerClass("player-3", 0, 1)}>{getPlayerName(0, 1)}</div>
          <div className={getPlayerClass("player-4", 1, 1)}>{getPlayerName(1, 1)}</div>
          
          {cards?.map((card, i) => (
            <Card
              card={card}
              style={cardPosition(i)}
              height="80"
              key={`${card.suit}${card.type}`}
            ></Card>
          ))}
        </div>
      </div>
    </div>
  );
};
