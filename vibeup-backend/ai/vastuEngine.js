const fs = require('fs');
const path = require('path');

class VastuEngine {
  constructor() {
    this.data = JSON.parse(fs.readFileSync(path.join(__dirname, 'vastu_data.json'), 'utf8'));
  }

  detectAndInject(prompt) {
    const q = prompt.toLowerCase();
    let vastuContext = "";

    this.data.vastu_rules.forEach(rule => {
      if (q.includes(rule.room.toLowerCase())) {
        vastuContext += `\n- **${rule.room} Vastu**: Best direction is ${rule.best_direction}. Rules: ${rule.rules.join(' ')}. Remedy: ${rule.remedies}`;
      }
    });

    if (q.includes('north') || q.includes('east') || q.includes('south') || q.includes('west')) {
      vastuContext += `\n- **Directions**: ${Object.entries(this.data.element_colors).map(([k,v]) => `${k}: ${v}`).join(', ')}`;
    }

    return vastuContext;
  }
}

module.exports = new VastuEngine();
