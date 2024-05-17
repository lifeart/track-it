import { Component, tracked } from '@lifeart/gxt';
import { formatISO } from 'date-fns';

import parseDuration from 'parse-duration';
import type { Task } from '../types/app';
import { Input } from './Input';
import { autofocus } from '@/modifiers/autofocus';

interface AddDurationArgs {
  task: Task;
  addDuration: (task: Task, duration: { time: number; date: string, note: string }) => void;
}

export class AddDuration extends Component<{
  Args: AddDurationArgs;
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
  addDuration = (event) => {
    // event.preventDefault();
    const duration = parseDuration(this.durationInput);
    // @ts-expect-error duration type
    if (isNaN(duration) || !duration) {
      return;
    }
    const now = formatISO(new Date());
    this.args.addDuration(this.args.task, { time: duration, date: now, note: this.notes.trim() });
    this.durationInput = '';
    this.notes = '';
  };
  <template>
    <dialog open class='rounded p-5 bg-slate-800 shadow-xl shadow-slate-900'>
      <h3 class='text-xl font-semibold text-slate-300'>+ {{@task.label}}</h3>
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
          >{{this.notes}}</textarea>
        </form>

      </div>
    </dialog>
  </template>
}
