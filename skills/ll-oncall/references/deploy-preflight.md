# Deploy pre-flight

## Capability batch — minute 1, before any plan

One Bash call, output pasted into the report. What is missing here is what stops the operation two
hours later, after the plan is written.

```bash
gh auth status 2>&1 | tail -5                      # logged in, and with which scopes
gh api user -q .login && gh api /rate_limit -q .rate.remaining
ssh -o BatchMode=yes -T git@github.com 2>&1 | head -1
gh api repos/:owner/:repo/branches/main/protection 2>&1 | head -3   # 404 = unprotected
ls -l .env* 2>/dev/null                            # exists? mode 600? tracked by git?
docker ps --format '{{.Names}}\t{{.Status}}' 2>&1 | head
kubectl config current-context 2>&1; kubectl get ns 2>&1 | head -3
```

Anything that returns a permission wall is a **band 1 question in the first turn**, with the command
ready to paste and what it does next to it — not at the end of the plan. The same `apply` was blocked
four times in eleven days, each block costing one to three re-authorization turns, and once ending the
session in an impasse.

## Layer checklist — exercise the exact operation

Each line is a check that runs before the first push, not a principle. Every one of them was a
separate deploy round that failed one at a time.

| Layer | Check | Incident it closes |
|---|---|---|
| credential | diff the keys of the app secret against the envs referenced by the cronjob and by the migrate job | the key existed in `web-secrets`, the migrate container never received `OWN_PG_DSN` |
| credential | the DSN is quoted before it reaches the store — `&` in a connection string breaks the parse | one round lost to an unquoted `&` |
| container | the image tag the deployment will pull exists in the registry, and the job's container spec names the same secret as the web one | a job pointed at a secret nobody had sealed |
| TLS | fetch the target over TLS from inside the cluster, not only from the laptop | `SELF_SIGNED_CERT_IN_CHAIN` on the first migration |
| privilege | the DB user can `CREATE SCHEMA` — run it in a transaction and roll back | `permission denied` on the first migration run |
| schema | no Job with the same name is in flight; a Job name is a lock nobody holds | an anti-collision `kubectl delete` killed a rerun one second after dispatch |

A pre-deploy that only lints manifests proves nothing about any of these. Run the operation against
the real target with the real identity, on a resource that is safe to touch.

## Ground truth by another path

Confirm the write by a route that is not the route that wrote it: read the secret from the cluster,
not from the `.env` that produced it; compare a sha256 of the sealed store against the live resource
rather than trusting the reseal's own output. A write that reports success and a read of the same file
that produced it are one fact, not two.

## Push gate

One deploy at a time. Look for an in-flight run, wait for it, then push — each push cancels the
previous run, and a migration cancelled mid-way leaves a half-applied schema. Only the owner of a
shared resource writes to it; a session that is going to look but not touch says so in the message.
Announce the push before and confirm after, in the 4-field block.

## Waiting

Wait on the event with `Monitor` over the condition — the run's conclusion, the rollout's ready
replicas, the row appearing in the table. `gh run watch` in the background returns a live process, not
a fact, and the session goes on believing it is waiting when it is not.
