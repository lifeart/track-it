import { Component, tracked } from '@lifeart/gxt';
import { DateTime } from 'luxon';

import parseDuration from 'parse-duration';
import type { Task } from '../types/app';

interface AddDurationArgs {
  task: Task;
  addDuration: (task: Task, duration: { time: number; date: string }) => void;
}

export class AddDuration extends Component<{
  Args: AddDurationArgs;
}> {
  @tracked durationInput = '';

  updateDuration = (event) => {
    this.durationInput = event.target.value;
  };

  addDuration = (event) => {
    event.preventDefault();
    const duration = parseDuration(this.durationInput);
    if (isNaN(duration) || !duration) {
      return;
    }
    const now = DateTime.now().toISO();
    this.args.addDuration(this.args.task, { time: duration, date: now });
    this.durationInput = '';
  };
  <template>
    <div class='mt-4'>
      <h3 class='text-xl font-semibold'>Add Duration to {{@task.label}}</h3>
      <form {{on 'submit' this.addDuration}}>
        <input
          type='text'
          placeholder='Enter time (e.g., 1h20m)'
          class='border p-1'
          {{on 'input' this.updateDuration}}
        />
        <button type='submit' class='ml-2 p-1 bg-blue-500 text-white'>Add Time</button>
      </form>
    </div>
  </template>
}