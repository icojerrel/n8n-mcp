# N8N Data Map — waar zit welke data en hoe bereik je die snel

> Laatst bijgewerkt: 2026-08-23. Bij grote databank-wijzigingen: cijfers onderaan verversen via de query-recepten.

## 1. Kennisdatabank voor workflow-generatie (het hart)

**Bestand:** `data/nodes.db` (SQLite, ~132 MB, WAL-modus, FTS5 full-text search)

| Tabel | Inhoud | Aantal |
|---|---|---|
| `nodes` | alle node-definities: properties_schema, operations, documentation | 2.260 (802 core+LangChain, 1.458 verified community) |
| `templates` | workflow-templates van n8n.io (`workflow_json_compressed` = gzip+base64) | 3.082 |
| `template_node_configs` | échte parameter-voorbeelden per node_type, gerankt op populariteit (`rank` 1 = best bekeken) | 50.970 over 612 types |
| `node_versions` / `version_property_changes` | versiehistorie | leeg (nog niet gevuld) |

**Snel queryën** (gebruik Node 22!):
```bash
export PATH=~/.local/opt/node22/bin:$PATH
node -e "
const db=new (require('better-sqlite3'))('data/nodes.db',{readonly:true});
// beste configuratievoorbeelden voor een node:
console.log(db.prepare(
  'SELECT template_name, parameters_json FROM template_node_configs WHERE node_type=? ORDER BY rank LIMIT 3'
).all('nodes-base.httpRequest'));
"
```

**Decompress een template-workflow:**
```js
zlib.gunzipSync(Buffer.from(row.workflow_json_compressed,'base64')).toString()
```

## 2. De MCP-server zelf

- Starten stdio: `npm start` (MCP_MODE=stdio) — HTTP: `npm run start:http`
- Data verversen: `npm run rebuild` (nodes uit node_modules/n8n-packages; vereist kloon `./n8n-docs/`)
- Templates verversen: `npm run fetch:templates:update` → daarna `npm run fetch:templates:extract`
- Community nodes: `npm run fetch:community:verified`
- Config-extractie is onbeperkt sinds 2026-08-23 (was top-10 per type); env-cap: `TEMPLATE_NODE_CONFIGS_PER_NODE`

## 3. Lokale n8n-instantie (Windows)

- **Database:** `C:\Users\Gebruiker\.n8n\database.sqlite` (12 workflows; actieve workflow "Beate Marie Collector Inquiry Review")
- **Veilig lezen vanuit WSL:** kopieer eerst `database.sqlite*` naar `/tmp`, open daar met better-sqlite3 — direct openen op `/mnt/c` faalt (SHMOPEN) en live schrijven is verboden
- **Workflows staan in:** tabel `workflow_entity` (kolommen `id,name,active,nodes,connections` — JSON)
- **Community packages:** `C:\Users\Gebruiker\.n8n\nodes\node_modules\` + registratie in tabellen `installed_packages`/`installed_nodes`
- **Belangrijk:** Windows-n8n draait op Windows-Node 24; native binaries (sqlite3 e.d.) moeten via `cmd.exe /c npm ...` vanaf Windows gebouwd worden, NIET vanuit WSL
- n8n laadt community-packages door map-scan (`n8n-nodes-*` glob), DB-registratie is voor GUI/updates

## 4. Obsidian-vault (menselijk leesbare spiegel)

`C:\Users\Gebruiker\Obsidian Vaults\JMG-AI-OS\03 - Resources\n8n\`

| Notitie | Inhoud |
|---|---|
| `n8n MOC.md` | index + links |
| `Node Catalogus.md` | alle 2.260 nodes per categorie |
| `Populaire Templates.md` | top 50 op views |
| `Veelgebruikte Node Configuraties.md` | top-25 node-types × 3 beste JSON-voorbeelden |
| `Documentatie Dekking.md` | statistiek + werklijst nodes-zonder-docs |
| `Community Ideeën.md` | ideeënlijst (data-gedreven startideeën) |

Hergenereren na DB-update: `/tmp/opencode/vault-gen/gen-vault.js` (Node 22, readonly).

## 5. Overige locaties

- `examples/horror-workflows/` — eigen workflow-experimenten (JSON + guides)
- `docs/local/` — analyse-documenten, memory-notes update-proces
- `archive/logs/` — oude logs en ad-hoc scripts
- `n8n-docs/` — officiële docs-repo (shallow kloon; bron voor `documentation`-kolom)
- `.env` bestanden: alleen `.env*example` in git; echte secrets nooit committen

## 6. Huidige kerncijfers (2026-08-23)

- Nodes 2.260 · AI-tools 1.575 · Triggers 414 · Docs-dekking 721/2.260 (32%)
- Templates 3.082 · Configs 50.970 / 612 types
- Upstream czlonkowski/n8n-mcp: v2.73.0 (lokaal v2.33.2 — migratie nog te doen)
