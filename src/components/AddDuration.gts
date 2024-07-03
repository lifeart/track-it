import { Component, tracked } from '@lifeart/gxt';
import { formatISO } from 'date-fns';
import type { Task } from '../types/app';
import { Input } from './Input';
import { autofocus } from '@/modifiers/autofocus';

interface AddDurationArgs {
  task: Task;
  addDuration: (
    task: Task,
    duration: { time: number; date: string; note: string },
  ) => void;
  showForm: boolean;
  onClose: () => void;
}

export class AddDuration extends Component<{
  Args: AddDurationArgs;
  Blocks: {
    default: [];
  };
}> {
  @tracked durationInput = '';
  @tracked notes = '';

  // @ts-expect-error event type
  updateDuration = (event) => {
    this.durationInput = event.target.value;
  };

  // @ts-expect-error event type
  updateNotes = (event) => {
    this.notes = event.target.value;
  };

  // @ts-expect-error event type
  addDuration = async (event: Sub) => {
    event.preventDefault();
    const { default: parseDuration } = await import('parse-duration');
    const duration = parseDuration(this.durationInput);
    // @ts-expect-error duration type
    if (isNaN(duration) || !duration) {
      this.durationInput = '';
      return;
    }
    const now = formatISO(new Date());
    this.args.addDuration(this.args.task, {
      time: duration,
      date: now,
      note: this.notes.trim(),
    });
    this.durationInput = '';
    this.notes = '';
  };
  @tracked open = true;
  onCloseEvent = () => {
    this.args.onClose();
  };
  bindCloseEvents = (_: HTMLDialogElement) => {
    const initEvent = new Event('init');
    const timestampDiff = 10;
    const onEscape = (event: KeyboardEvent) => {
      if (initEvent.timeStamp + timestampDiff > event.timeStamp) {
        return;
      }
      if (event.key === 'Escape') {
        this.onCloseEvent();
      }
    };
    const onClickOutside = (event: MouseEvent) => {
      if (initEvent.timeStamp + timestampDiff > event.timeStamp) {
        return;
      }
      if (_.contains(event.target as Node)) {
        return;
      } else {
        this.onCloseEvent();
      }
    };
    document.addEventListener('keydown', onEscape);
    document.addEventListener('click', onClickOutside);
    return () => {
      document.removeEventListener('keydown', onEscape);
      document.removeEventListener('click', onClickOutside);
    };
  };
  onFocus() {
    try {
      Telegram.WebApp.HapticFeedback.impactOccurred('light');
    } catch (e) {
      // FINE
    }
  }
  bindDialogRef = (el: HTMLDialogElement) => {
    requestAnimationFrame(() => {
      el.show();
    });
    return () => {
      el.close();
    };
  };
  <template>
    <dialog
      {{this.bindCloseEvents}}
      {{this.bindDialogRef}}
      class='rounded-md p-5 bg-sky-950 fixed max-w-[96vw] top-5 shadow-xl shadow-slate-900'
    >
      {{yield}}
      {{#if @showForm}}
        <div class='mt-4'>

          <form
            class='flex flex-col'
            {{on 'submit' this.addDuration}}
            method='dialog'
          >
            <div class='flex flex-row'>
              <Input
                {{autofocus}}
                class='flex'
                @value={{this.durationInput}}
                @onInput={{this.updateDuration}}
                placeholder='Enter time (e.g., 1h20m)'
                required
              />
              <button
                type='submit'
                class='rounded-lg flex ml-2 p-2 items-center bg-blue-500 text-white'
              >Add</button>
            </div>
            <textarea
              class='bg-gray-50 mt-2 border border-gray-300 text-gray-900 text-lg rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500'
              placeholder='Notes'
              {{on 'input' this.updateNotes}}
              {{on 'focus' this.onFocus}}
            >{{this.notes}}</textarea>
          </form>
        </div>
      {{/if}}
    </dialog>
  </template>
}
