import { Component, tracked } from '@lifeart/gxt';

import type { Task } from '../types/app';

interface AddTaskArgs {
  addTask: (task: Task) => void;
}

export class AddTask extends Component<{
  Args: AddTaskArgs;
}> {
  @tracked label = '';
  @tracked description = '';

  updateLabel = (event) => {
    this.label = event.target.value;
  };

  updateDescription = (event) => {
    this.description = event.target.value;
  };

  addTask = (event) => {
    event.preventDefault();
    this.args.addTask({
      label: this.label,
      description: this.description,
      durations: [],
    });
    this.label = '';
    this.description = '';
  };
  <template>
    <form {{on 'submit' this.addTask}} class='mt-4'>
      <input
        type='text'
        placeholder='Task Label'
        class='border p-1'
        {{on 'input' this.updateLabel}}
      />
      <input
        type='text'
        placeholder='Task Description'
        class='border p-1 ml-2'
        {{on 'input' this.updateDescription}}
      />
      <button type='submit' class='ml-2 p-1 bg-green-500 text-white'>Add Task</button>
    </form>
  </template>
}
