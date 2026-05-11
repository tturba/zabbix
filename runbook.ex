# RUNBOOK: High CPU utilization (> 90% by 10min)

## Symptom
Klient zglasza wolne odpowiedzi aplikacji. W Zabbix:
trigger "High CPU on {HOST}", sev=Average.

## Diagnoza (kolejno, max 3 min)
1. Slack: czy ktos juz pracuje?
   `/incident search {HOST}`
2. SSH na host i sprawdz TOP 5:
   ```
   ssh {HOST}
   ps aux --sort=-%cpu | head -6
   ```
3. Sprawdz korelacje z deploymentem:
   `kubectl rollout history -n prod | tail -5`

## Remediacja (wybierz scenariusz)
### A. Pojedynczy proces zjada CPU (znana app)
- Sprawdz logi: `journalctl -u <svc> --since "5min ago"`
- Restart: `systemctl restart <svc>` (notice: 30s downtime)
- Verify: czy CPU spadlo < 70%?

### B. Spike po deploymencie (canary nie zlapal)
- Rollback: `kubectl rollout undo deployment/<app> -n prod`
- Eskalacja: pingnij dev on-call, wklej diff w incident channel

### C. CPU steal > 30% (problem hypervisora)
- Stop tu, eskaluj L2 NetOps natychmiast (patrz "Eskalacja")

## Eskalacja
- L2 SRE on-call:  +48 600 000 000 (#sre-oncall)
- L2 NetOps:       +48 600 000 001 (#netops-oncall)
- Major incident:  /incident declare P1 w Slack

## Po incydencie
- Update post-mortem: https://wiki/postmortems/{INCIDENT_ID}
- Dashboard MTTR:    https://zabbix/dashboard/mttr-cpu
- Wiki przyczyn:     https://wiki/known-issues#high-cpu

---
Owner: @sre-team   |  Ostatnia aktualizacja: 2026-04-12
Wersja: 3   |   Code review: PR-841
