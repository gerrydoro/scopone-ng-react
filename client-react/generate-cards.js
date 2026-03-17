const fs = require('fs');
const path = require('path');

const suits = [
  { code: 'c', name: 'Bastoni', color: '#4a3728', icon: '🪵' },
  { code: 'h', name: 'Coppe', color: '#c41e3a', icon: '🏆' },
  { code: 'd', name: 'Denari', color: '#d4af37', icon: '💰' },
  { code: 's', name: 'Spade', color: '#1a1a2e', icon: '⚔️' }
];

const types = [
  { code: '1', name: 'Ace', value: 'A' },
  { code: '2', name: 'Two', value: '2' },
  { code: '3', name: 'Three', value: '3' },
  { code: '4', name: 'Four', value: '4' },
  { code: '5', name: 'Five', value: '5' },
  { code: '6', name: 'Six', value: '6' },
  { code: '7', name: 'Seven', value: '7' },
  { code: 'j', name: 'Jack', value: 'J' },
  { code: 'q', name: 'Queen', value: 'Q' },
  { code: 'k', name: 'King', value: 'K' }
];

function generateCardSVG(type, suit) {
  const isRed = suit.code === 'h' || suit.code === 'd';
  const color = isRed ? '#c41e3a' : '#1a1a2e';
  const suitColor = suit.color;
  
  return `<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="140" viewBox="0 0 100 140" xmlns="http://www.w3.org/2000/svg">
  <!-- Card Background -->
  <rect width="100" height="140" rx="8" fill="white" stroke="#ddd" stroke-width="1"/>
  
  <!-- Corner Index -->
  <text x="12" y="28" font-family="Arial, sans-serif" font-size="20" font-weight="bold" fill="${color}">${type.value}</text>
  <text x="12" y="48" font-family="Arial, sans-serif" font-size="16" fill="${suitColor}">${suit.icon}</text>
  
  <!-- Center Suit Symbol (Large) -->
  <text x="50" y="80" font-family="Arial, sans-serif" font-size="50" text-anchor="middle" fill="${suitColor}" opacity="0.8">${suit.icon}</text>
  
  <!-- Bottom Corner (Rotated) -->
  <text x="88" y="112" font-family="Arial, sans-serif" font-size="20" font-weight="bold" fill="${color}" text-anchor="end" transform="rotate(180 88 112)">${type.value}</text>
  <text x="88" y="92" font-family="Arial, sans-serif" font-size="16" fill="${suitColor}" text-anchor="end" transform="rotate(180 88 92)">${suit.icon}</text>
  
  <!-- Decorative Border -->
  <rect x="5" y="5" width="90" height="130" rx="5" fill="none" stroke="${suitColor}" stroke-width="1" opacity="0.3"/>
</svg>`;
}

const outputDir = path.join(__dirname, 'public', 'card-images', 'svg');

// Create directory if it doesn't exist
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// Generate all cards
let count = 0;
suits.forEach(suit => {
  types.forEach(type => {
    const svg = generateCardSVG(type, suit);
    const filename = `${type.code}${suit.code}.svg`;
    const filepath = path.join(outputDir, filename);
    fs.writeFileSync(filepath, svg);
    console.log(`Created: ${filename}`);
    count++;
  });
});

console.log(`\n✅ Generated ${count} card SVGs in ${outputDir}`);
