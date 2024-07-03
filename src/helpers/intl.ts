const en = {
  msg_confirm_task_removal: 'Are you sure you want to remove this task?',
  msg_task_with_this_label_already_exists:
    'Task with label {label} already exists',
  app_name: 'Track It',
  new_task: 'New Task',
  check_on: 'Check on',
  git_hub: 'GitHub',
  placeholder_duration: 'Enter time (e.g., 1h20m)',
  placeholder_notes: 'Notes',
  add: 'Add',
  add_task: 'Add Task',
  task_description: 'Task Description',
  task_label: 'Task Label',
  // Total time spent
  total_time_spent: 'Total time spent',
  // Time spent this month
  time_spent_this_month: 'Time spent this month',
  // Date
  date: 'Date',
  // Time

  time: 'Time',
  // Note
  note: 'Note',
  // Remove Task
  remove_task: 'Remove Task',
  // Edit Task
  edit_task: 'Edit Task',
};

const ru = {
  msg_confirm_task_removal: 'Вы уверены, что хотите удалить эту задачу?',
  msg_task_with_this_label_already_exists:
    'Задача с меткой {label} уже существует',
  app_name: 'Track It',
  new_task: 'Новая задача',
  check_on: 'Проверить на',
  git_hub: 'GitHub',
  placeholder_duration: 'Введите время (например, 1ч20м)',
  placeholder_notes: 'Заметки',
  add: 'Добавить',
  add_task: 'Добавить задачу',
  task_description: 'Описание задачи',
  task_label: 'Метка задачи',
  total_time_spent: 'Общее затраченное время',
  time_spent_this_month: 'Время, затраченное в этом месяце',
  date: 'Дата',
  time: 'Время',
  note: 'Заметка',
  remove_task: 'Удалить задачу',
  edit_task: 'Редактировать задачу',
};

const isRu =
  Intl.DateTimeFormat().resolvedOptions().timeZone === 'Europe/Moscow';
export const t = isRu ? ru : en;