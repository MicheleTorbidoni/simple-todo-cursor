import { useEffect, useRef, useState } from "react"
import { Head, router, usePage } from "@inertiajs/react"
import { X } from "lucide-react"

import { AppShell } from "@/components/AppShell"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import { Input } from "@/components/ui/input"
import { cn } from "@/lib/utils"

import type { PageProps } from "@/types/inertia"

export type TaskItem = {
  id: number
  name: string
  completed: boolean
}

type DashboardPageProps = PageProps<{
  pending_tasks: TaskItem[]
  completed_tasks: TaskItem[]
}>

function TaskRow({ task }: { task: TaskItem }) {
  const [editing, setEditing] = useState(false)
  const [draft, setDraft] = useState(task.name)
  const cancelRef = useRef(false)

  useEffect(() => {
    setDraft(task.name)
  }, [task.name])

  function saveName() {
    if (!editing) return

    const trimmed = draft.trim()
    if (trimmed === task.name) {
      setEditing(false)
      return
    }

    router.patch(
      `/tasks/${task.id}`,
      { name: trimmed },
      {
        preserveScroll: true,
        onFinish: () => setEditing(false),
      },
    )
  }

  function cancelEdit() {
    cancelRef.current = true
    setDraft(task.name)
    setEditing(false)
  }

  function handleBlur() {
    if (cancelRef.current) {
      cancelRef.current = false
      return
    }

    saveName()
  }

  function handleKeyDown(event: React.KeyboardEvent<HTMLInputElement>) {
    if (event.key === "Enter") {
      event.preventDefault()
      saveName()
    } else if (event.key === "Escape") {
      event.preventDefault()
      cancelEdit()
    }
  }

  function toggleCompleted() {
    router.patch(
      `/tasks/${task.id}`,
      { completed: !task.completed },
      { preserveScroll: true },
    )
  }

  function destroyTask() {
    router.delete(`/tasks/${task.id}`, { preserveScroll: true })
  }

  return (
    <li className="flex items-center gap-3 rounded-lg border border-hairline bg-surface px-3 py-2">
      <Checkbox
        checked={task.completed}
        onChange={toggleCompleted}
        aria-label={task.completed ? "Mark task as incomplete" : "Mark task as complete"}
      />

      <div className="min-w-0 flex-1">
        {editing ? (
          <Input
            autoFocus
            value={draft}
            onChange={(event) => setDraft(event.target.value)}
            onBlur={handleBlur}
            onKeyDown={handleKeyDown}
            aria-label="Edit task name"
          />
        ) : (
          <button
            type="button"
            className={cn(
              "w-full truncate text-left",
              task.completed && "text-ink-muted line-through",
            )}
            onClick={() => setEditing(true)}
          >
            {task.name}
          </button>
        )}
      </div>

      <Button
        type="button"
        variant="ghost"
        size="icon"
        onClick={destroyTask}
        aria-label="Remove task"
      >
        <X className="size-4" aria-hidden="true" />
      </Button>
    </li>
  )
}

function TaskList({ tasks }: { tasks: TaskItem[] }) {
  return (
    <ul className="space-y-2">
      {tasks.map((task) => (
        <TaskRow key={task.id} task={task} />
      ))}
    </ul>
  )
}

export default function Dashboard() {
  const { props } = usePage<DashboardPageProps>()
  const [newName, setNewName] = useState("")
  const newTaskInputRef = useRef<HTMLInputElement>(null)

  function focusNewTaskInput() {
    requestAnimationFrame(() => {
      newTaskInputRef.current?.focus()
    })
  }

  function handleCreate(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault()

    router.post(
      "/tasks",
      { name: newName },
      {
        preserveScroll: true,
        onSuccess: () => setNewName(""),
        onFinish: focusNewTaskInput,
      },
    )
  }

  return (
    <>
      <Head title="Tasks">
        <meta
          name="description"
          content="Your personal to-do list — add tasks, mark them complete, and keep track of what needs doing."
        />
        <meta property="og:title" content="Tasks" />
        <meta
          property="og:description"
          content="Your personal to-do list — add tasks, mark them complete, and keep track of what needs doing."
        />
      </Head>
      <AppShell>
        <div className="mx-auto w-full max-w-xl">
          <h1>Tasks</h1>

          <form className="mt-6 space-y-2" onSubmit={handleCreate}>
            <label htmlFor="new-task">New task</label>
            <div className="flex items-center gap-2">
              <Input
                ref={newTaskInputRef}
                id="new-task"
                className="min-w-0 flex-1"
                value={newName}
                onChange={(event) => setNewName(event.target.value)}
                placeholder="What needs doing?"
              />
              <Button type="submit">Aggiungi</Button>
            </div>
            {props.errors.name ? (
              <p className="text-accent">{props.errors.name}</p>
            ) : null}
          </form>

          <section className="mt-8" aria-label="Active tasks">
            {props.pending_tasks.length > 0 ? (
              <TaskList tasks={props.pending_tasks} />
            ) : (
              <p className="text-ink-muted">Nessun task — aggiungine uno sopra.</p>
            )}
          </section>

          {props.completed_tasks.length > 0 ? (
            <section className="mt-10" aria-label="Completed tasks">
              <h2>Completati</h2>
              <div className="mt-4">
                <TaskList tasks={props.completed_tasks} />
              </div>
            </section>
          ) : null}
        </div>
      </AppShell>
    </>
  )
}
