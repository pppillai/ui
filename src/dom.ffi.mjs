// IMPORTS ---------------------------------------------------------------------

import { List, Ok, Error } from "../prelude.mjs";

// TYPES -----------------------------------------------------------------------

/**
 * @template A
 * @typedef {import("../build/dev/javascript/prelude.mjs").List} List<A>
 */

/**
 * @template A, E
 * @typedef {import("../build/dev/javascript/prelude.mjs").Result} Result<A, E>
 */

// QUERIES ---------------------------------------------------------------------

/**
 * Access the assigned elements of a Web Component's slot.
 *
 * @param {HTMLSlotElement} slot
 *
 * @returns {Result<List<Element>, List<never>>} A decoded list of elements. If
 * the slot is not an instance of `HTMLSlotElement`, an empty list of decode
 * errors is returned.
 */
export const assigned_elements = (slot) => {
  if (slot instanceof HTMLSlotElement) {
    return new Ok(List.fromArray(slot.assignedElements()));
  }

  return new Error(List.fromArray([]));
};

/**
 *
 */
export const animation_time = () => {
  return window.document.timeline.currentTime;
};

// COMPONENTS ------------------------------------------------------------------

customElements.define(
  "lustre-ui-intersection-observer",
  class LustreUiIntersectionObserver extends HTMLElement {
    constructor() {
      super();
      this.observer = null;
    }

    connectedCallback() {
      const options = {
        root: null,
        rootMargin: "0px",
        threshold: [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
      };

      this.observer = new IntersectionObserver((entries) => {
        for (const entry of entries) {
          const intersectionEvent = new CustomEvent("intersection", {
            detail: {
              target: entry.target,
              isIntersecting: entry.isIntersecting,
              intersectionRatio: entry.intersectionRatio,
            },
            bubbles: true,
            composed: true,
          });

          this.dispatchEvent(intersectionEvent);
        }
      }, options);

      // Observe self
      this.observer.observe(this);
    }

    disconnectedCallback() {
      if (this.observer) {
        this.observer.disconnect();
      }
    }
  },
);
