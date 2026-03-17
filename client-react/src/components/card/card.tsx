import { FC } from "react";
import "./card.css";

import {
  Card as PlayingCard,
  Suits,
  Types,
} from "../../../../scopone-rx-service/src/model/card";

// Trevigiane card mapping
enum TypesView {
  Ace = "1",
  King = "k",
  Queen = "q",
  Jack = "j",
  Seven = "7",
  Six = "6",
  Five = "5",
  Four = "4",
  Three = "3",
  Two = "2",
}

const suitsMap = new Map<Suits, string>();
suitsMap.set(Suits.BASTONI, "c"); // Clubs → Bastoni
suitsMap.set(Suits.COPPE, "h");   // Hearts → Coppe
suitsMap.set(Suits.DENARI, "d");  // Diamonds → Denari
suitsMap.set(Suits.SPADE, "s");   // Spades → Spade

interface ICardProps {
  card: PlayingCard;
  size?: "xs" | "sm" | "md" | "lg" | "xl";
  style?: React.CSSProperties;
  clickHandler?: (card: PlayingCard) => void;
  disabled?: boolean;
  selected?: boolean;
  showBack?: boolean;
  label?: string;
  className?: string;
}

export const Card: FC<ICardProps> = (props) => {
  const {
    card,
    size = "md",
    style,
    clickHandler,
    disabled = false,
    selected = false,
    showBack = false,
    label,
    className = "",
  } = props;

  const cardSvg = (suit: Suits, type: Types) => {
    const t = TypesView[type];
    const s = suitsMap.get(suit);
    const resourcePath = `/card-images/svg/${t}${s}.svg`;
    return process.env.PUBLIC_URL + resourcePath;
  };

  const cardClasses = [
    "playing-card",
    `card-${size}`,
    className,
    disabled ? "disabled" : "",
    selected ? "selected" : "",
  ]
    .filter(Boolean)
    .join(" ");

  const handleClick = () => {
    if (!disabled && clickHandler) {
      clickHandler(card);
    }
  };

  if (showBack) {
    return (
      <div className={`${cardClasses} card-back`} style={style}>
        <span>S</span>
      </div>
    );
  }

  return (
    <div
      className={cardClasses}
      style={style}
      onClick={handleClick}
      role="button"
      tabIndex={disabled ? -1 : 0}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          handleClick();
        }
      }}
      aria-label={`${card.type} of ${card.suit}`}
      aria-disabled={disabled}
    >
      <img
        src={cardSvg(card.suit, card.type)}
        alt={`${card.type} of ${card.suit}`}
        loading="lazy"
      />
      {label && <span className="card-label">{label}</span>}
    </div>
  );
};
