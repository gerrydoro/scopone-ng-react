# 🎴 Scopone React Client - Poker Table Edition

A beautifully redesigned React client for the Scopone Italian card game with a poker-table aesthetic and fully responsive design.

## ✨ Features

### Visual Design
- 🃏 **Poker Table Theme**: Green felt table with wooden edges
- 📱 **Fully Responsive**: Works on PC, tablet, and mobile
- 🎨 **Trevigiane Cards**: Traditional Italian playing cards
- 🌙 **Dark Mode**: Easy on the eyes for long gaming sessions
- ✨ **Smooth Animations**: Card hover effects, transitions, and more

### User Experience
- 🧭 **Intuitive Navigation**: Clear menu system with mobile support
- 👤 **Player Profile**: Persistent player name display
- ⚠️ **Error Handling**: Beautiful toast notifications
- 📜 **Game History**: Track your past games
- 🏆 **Results View**: See hand results clearly

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd client-react
npm install
```

### 2. Generate Card Images (if needed)
```bash
node generate-cards.js
```

This creates 40 SVG cards in the `public/card-images/svg/` directory.

### 3. Configure Server Address
Create or edit `.env.development`:
```
REACT_APP_SERVER_ADDRESS=ws://localhost:65025/osteria
```

### 4. Start Development Server
```bash
npm start
```

The app will open at `http://localhost:3000`

### 5. Build for Production
```bash
npm run build
```

Output will be in `build/` directory.

## 🎨 Customization

### Table Colors
Edit `src/index.css` to customize the poker table colors:
```css
:root {
  --table-green: #2d5016;        /* Main felt color */
  --table-green-dark: #1a3009;   /* Dark edges */
  --table-green-light: #3d6b1f;  /* Light highlights */
  --table-edge: #4a3728;         /* Wood edge */
  --card-gold: #d4af37;          /* Gold accents */
}
```

### Card Design
The Trevigiane cards are generated as SVGs. To customize:
1. Edit `generate-cards.js` to change the SVG template
2. Run `node generate-cards.js` to regenerate

### Responsive Breakpoints
- **Mobile**: < 480px
- **Tablet**: 480px - 768px
- **Desktop**: 768px - 1024px
- **Large Desktop**: > 1024px

## 📁 Project Structure

```
client-react/
├── public/
│   └── card-images/
│       └── svg/              # 40 Trevigiane card SVGs
├── src/
│   ├── components/
│   │   ├── card/             # Card component
│   │   ├── cards/            # Multiple cards display
│   │   ├── game/             # Main game container with poker table
│   │   ├── hand/             # Player's hand view
│   │   ├── navigation/       # Responsive navigation menu
│   │   ├── sign-in/          # Player sign-in
│   │   └── ...
│   ├── index.css             # Global styles & theme
│   └── App.tsx               # Main app component
├── generate-cards.js         # Card SVG generator
└── package.json
```

## 🎮 Game Flow

1. **Sign In**: Enter your player name
2. **Pick Game**: Create or join a game table
3. **Play Hand**: Play your cards strategically
4. **View Results**: See hand results
5. **Continue**: Play next hand or close game

## 🎯 Responsive Design Features

### Desktop (> 1024px)
- Full poker table view
- Expanded navigation menu
- Large card displays
- Multi-column layouts

### Tablet (768px - 1024px)
- Adjusted table size
- Icon-only navigation
- Medium card sizes
- Two-column layouts

### Mobile (< 768px)
- Compact table view
- Hamburger menu
- Small card sizes
- Single-column layouts
- Touch-optimized controls

## 🔧 Development Tips

### Hot Reload
The app supports hot reload. Changes to components will reflect immediately.

### Debugging
Open browser DevTools Console to see game state logs.

### Testing Responsive Design
Use Chrome DevTools Device Mode to test different screen sizes.

## 📝 Notes

- The poker table background is CSS-generated (no images needed)
- Card images are SVG for crisp display at any size
- All animations are GPU-accelerated for smooth performance
- The design follows accessibility best practices

## 🎨 Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Table Green | `#2d5016` | Main felt color |
| Table Dark | `#1a3009` | Shadow areas |
| Table Light | `#3d6b1f` | Highlights |
| Wood Edge | `#4a3728` | Table border |
| Gold | `#d4af37` | Accents, text |
| UI Dark | `#1a1a2e` | Backgrounds |
| UI Accent | `#e94560` | Buttons, alerts |

## 📄 License

MIT License - See LICENSE file for details.

## 🙏 Credits

- Card design inspired by traditional Italian Trevigiane deck
- Poker table aesthetic inspired by classic casino design
- Built with React, TypeScript, and Material-UI

---

**Enjoy playing Scopone with style! 🎴✨**
