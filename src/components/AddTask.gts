import { Component, tracked } from '@lifeart/gxt';
import { Input } from './Input';
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
    requestAnimationFrame(() => {
      const input = document.getElementById('task-label') as HTMLInputElement;
      if (input) {
        input.focus();
      }
    });
  };
  <template>
    <form {{on 'submit' this.addTask}} class='mt-4 mr-4 flex flex-col'>
      <Input required class="flex text-lg gap-2 mb-2" label='Task Label' placeholder='Task Label'  id='task-label' @value={{this.label}} @onInput={{this.updateLabel}} />
      <Input class="flex text-lg gap-2 mb-2" label='Task Description' placeholder='Task Description' @value={{this.description}} @onInput={{this.updateDescription}} />
      <button type='submit' class='justify-center  uppercase flex p-2 bg-green-900 rounded-md text-white'>Add Task</button>
    </form>
  </template>
}
