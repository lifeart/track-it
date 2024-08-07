import { Component, type Cell } from '@lifeart/gxt';

export class Input extends Component<{
  Args: { value: string | Cell<string>; onInput?: (e: Event) => void };
  Element: HTMLInputElement;
}> {
  onInput(e: Event) {
    this.args.onInput?.(e);
  }
  onFocus() {
    try {
      Telegram.WebApp.HapticFeedback.impactOccurred('light');
    } catch (e) {
      // FINE
    }
  }
  <template>
    <input
      value={{@value}}
      type='text'
      class='bg-gray-50 border border-gray-300 text-gray-900 text-lg rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500'
      {{on 'input' this.onInput}}
      {{on 'focus' this.onFocus}}
      ...attributes
    />
  </template>
}
