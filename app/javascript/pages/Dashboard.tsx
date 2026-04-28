import { Head } from "@inertiajs/react"

import { AppShell } from "@/components/app-shell"

export default function Dashboard() {
  return (
    <>
      <Head title="Home">
        <meta name="description" content="Your account home." />
        <meta property="og:title" content="Home" />
        <meta property="og:description" content="Your account home." />
      </Head>
      <AppShell title="Home">
        <p className="text-base">Welcome to your account.</p>
      </AppShell>
    </>
  )
}
