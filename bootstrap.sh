#!/usr/bin/env bash
# Bootstrap de koa-banc-tech. Rejouable : la recette le rejoue avant chaque chantier, sur une forge réinitialisée.
set -uo pipefail
cd "$(dirname "$0")"
log() { echo "bootstrap : $*"; }
git config --global user.name "tech (agent du banc)"
git config --global user.email "tech@banc.koa.invalid"
git config --global init.defaultBranch main
git config --global pull.ff only
log "git : identité réglée"

# Le QG : KoA le clone depuis son modèle public ($KOA_QG) ; on travaille sur celui de la forge.
q="${KOA_QG:-}"
if [ -z "$q" ] || [ ! -d "$q/.git" ]; then
  log "ÉCART : KOA_QG absent ou non cloné — la seed déclare pourtant son QG"; exit 1
fi
if git ls-remote -q git://127.0.0.1/qg.git >/dev/null 2>&1; then
  git -C "$q" remote set-url origin git://127.0.0.1/qg.git
  git -C "$q" fetch -q origin && git -C "$q" checkout -q -B main origin/main && git -C "$q" reset -q --hard origin/main
  log "qg : sur la forge ($(git -C "$q" rev-parse --short HEAD))"
  rm -rf "$HOME/projet" && git clone -q git://127.0.0.1/projet.git "$HOME/projet"
  log "projet : cloné depuis la forge ($(git -C "$HOME/projet" rev-parse --short HEAD 2>/dev/null || echo vide))"
else
  log "forge injoignable sur 127.0.0.1:9418 — la recette la lance avant le chantier ; QG et projet non branchés"
fi

# Le garde-fou de déploiement lit .claude/garde-fous.json là où l'agent démarre : un lien vers celui du QG.
mkdir -p .claude && ln -sfn "$q/.claude/garde-fous.json" .claude/garde-fous.json
log "terminé"
