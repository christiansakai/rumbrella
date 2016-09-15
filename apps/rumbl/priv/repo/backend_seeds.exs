# A fake user to be used as Wolfram bot in the chat.

alias Rumbl.Repo
alias Rumbl.User

Repo.insert!(%User{
  name: "Wolfram",
  username: "wolfram"
})
