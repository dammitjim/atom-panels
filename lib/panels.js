'use babel';

const VERTICAL = 'vertical';
const HORIZONTAL = 'horizontal';

// Atoms stores orientation in two axis objects whose children are valid panels to move to.
// These constants are defined numerically to symbolise their effect on navigating through the
// arrays.
//
// e.g LEFT wants to move to the previous axis child in the array.
const LEFT = -1;
const RIGHT = 1;
const UP = -1;
const DOWN = 1;

// Calculate now to avoid nasty switch processing.
const AVAILABLE_COMBOS = {
  LEFT: `${HORIZONTAL} ${LEFT}`,
  RIGHT: `${HORIZONTAL} ${RIGHT}`,
  UP: `${VERTICAL} ${UP}`,
  DOWN: `${VERTICAL} ${DOWN}`,
};

export default {

  /**
   * Activate registers all commands within the atom workspace.
   * @param state {object}
   */
  activate(state) {
    atom.commands.add('atom-workspace',
      'atom-panels:move-right', (event) => this.move(HORIZONTAL, RIGHT, false)
    );
    atom.commands.add('atom-workspace',
      'atom-panels:move-left', (event) => this.move(HORIZONTAL, LEFT, false)
    );
    atom.commands.add('atom-workspace',
      'atom-panels:move-up', (event) => this.move(VERTICAL, UP, false)
    );
    atom.commands.add('atom-workspace',
      'atom-panels:move-down', (event) => this.move(VERTICAL, DOWN, false)
    );
    atom.commands.add('atom-workspace',
      'atom-panels:split-right', (event) => this.move(HORIZONTAL, RIGHT, true)
    );
    atom.commands.add('atom-workspace',
      'atom-panels:split-left', (event) => this.move(HORIZONTAL, LEFT, true)
    );
    atom.commands.add('atom-workspace',
      'atom-panels:split-up', (event) => this.move(VERTICAL, UP, true)
    );
    atom.commands.add('atom-workspace',
      'atom-panels:split-down', (event) => this.move(VERTICAL, DOWN, true)
    );
  },

  /**
   * Moves in the direction specified by the given parameters.
   * If split is true the editor will split in the given direction when
   * available.
   *
   * @param direction {string} - horizontal or vertical, use consts available.
   * @param distance {number} - 1 or -1, use consts available in file.
   * @param split {boolean} - if true attempt to split in the given direction.
   */
  move(direction, distance, split) {
    // Tracks whether navigation to a new pane has occured.
    let swapped = false;

    // The current atom pane.
    const pane = atom.workspace.getActivePane();

    // If we have more than one pane currently we want to check to see
    // if we can navigate to the new pane.
    if (atom.workspace.getPanes().length > 1) {
      const target = this.getTargetPane(pane, direction, distance);
      if (target) {
        this.moveTo(target);
        swapped = true;
      }
    }

    // If we're not currently swapped and intend to split panes.
    if (!swapped && split) {
      // Load the active buffer.
      const activeBuffer = pane.getActiveItem().buffer;
      activeBuffer.load();

      // Our options for the split.
      const keys = { copyActiveItem: true };

      // Split in the relevant direction.
      switch ([direction, distance].join(' ')) {
        case AVAILABLE_COMBOS.RIGHT:
          pane.splitRight(keys);
          break;
        case AVAILABLE_COMBOS.LEFT:
          pane.splitLeft(keys);
          break;
        case AVAILABLE_COMBOS.UP:
          pane.splitUp(keys);
          break;
        case AVAILABLE_COMBOS.DOWN:
          pane.splitDown(keys);
          break;
        default:
          // Invalid combination
          break;
      }
    }
  },

  /**
   * Activates the target pane.
   *
   * @param target {object}
   */
  moveTo(target) {
    target.activate();
  },

  /**
   * Calculates the intended target of movement based on current pane & direction params.
   *
   * @param currentPane {object} - the currently active panel.
   * @param direction {string} - horizontal / vertical.
   * @param distance {number} - delta to increment / decrement.
   */
  getTargetPane(currentPane, direction, distance) {
    let axis = currentPane.parent;
    let target = currentPane;

    // If we are using the incorrect orientation we must go up a level to the next orientation.
    // Atom stores panes on two orientations, horizontal and vertical. Vertical is the first
    // to be encountered.
    if (axis.orientation !== direction) {
      target = axis;
      axis = axis.parent;
    }

    if (!axis.children) {
      return null;
    }

    // Get our current position within the pane axis.
    const currentPosition = axis.children.indexOf(target);

    // Calculate our intended position to move to.
    const newPosition = currentPosition + distance;

    // If the intended position is out of the bounds
    // of the axis children it is unavailable.
    if (newPosition > axis.children.length) {
      return null;
    }

    // If we have a child pane to move to.
    if (axis.children[newPosition]) {
      return axis.children[newPosition].getPanes()[0];
    }

    return null;
  },
};
