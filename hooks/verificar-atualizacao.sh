#!/usr/bin/env bash
# Hook SessionStart do plugin ll-skills.
#
# Modo leitor (sem argumentos, roda em foreground, sem rede):
#   le o cache da execucao anterior e, se o SHA remoto registrado for diferente
#   do SHA instalado agora, emite um systemMessage curto. Depois dispara o modo
#   worker em background e sai.
#
# Modo worker (--worker, roda em background, com rede):
#   consulta o SHA remoto com `git ls-remote` e regrava o cache.
#
# Regra de ouro: nunca atrasar o inicio da sessao e nunca escrever nada fora do
# proprio cache. Qualquer falha (sem rede, sem git, sem cache, plugin carregado
# via --plugin-dir) termina em silencio com exit 0.

set -u

REPO_URL="https://github.com/allangdy/ll-skills.git"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ll-skills"
CACHE_FILE="$CACHE_DIR/update-check.json"
CHECK_INTERVAL=21600 # 6h entre consultas de rede
NET_TIMEOUT=10

# SHA instalado. Fonte primaria: o diretorio de instalacao do plugin e nomeado
# pelo SHA curto (~/.claude/plugins/cache/<marketplace>/<plugin>/<sha12>).
# Fallback: gitCommitSha no registro installed_plugins.json.
sha_instalado() {
  local raiz="${CLAUDE_PLUGIN_ROOT:-}" nome
  nome="${raiz##*/}"
  if [ "${#nome}" -ge 7 ]; then
    case "$nome" in
      *[!0-9a-f]*) ;; # nao e um SHA: cai no registro
      *) printf '%s' "$nome"; return 0 ;;
    esac
  fi

  local registro="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/installed_plugins.json" json
  [ -r "$registro" ] || return 1
  json=$(cat "$registro" 2>/dev/null) || return 1
  # Corta tudo antes da entrada do plugin e le o primeiro gitCommitSha depois dela.
  case "$json" in
    *'"ll-skills@ll-skills"'*) json="${json#*\"ll-skills@ll-skills\"}" ;;
    *) return 1 ;;
  esac
  if [[ $json =~ \"gitCommitSha\"[[:space:]]*:[[:space:]]*\"([0-9a-f]{7,40})\" ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
    return 0
  fi
  return 1
}

# Extrai "chave":"valor" ou "chave":valor de um JSON plano, sem jq.
campo() {
  local json="$1" chave="$2"
  if [[ $json =~ \"$chave\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  elif [[ $json =~ \"$chave\"[[:space:]]*:[[:space:]]*([0-9]+) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  fi
}

worker() {
  local local_sha="$1" remoto linha agora
  remoto=$(GIT_TERMINAL_PROMPT=0 timeout "$NET_TIMEOUT" git ls-remote "$REPO_URL" HEAD 2>/dev/null) || exit 0
  linha="${remoto%%$'\n'*}"
  remoto="${linha%%[!0-9a-f]*}"
  [ "${#remoto}" -eq 40 ] || exit 0
  agora=$(date +%s 2>/dev/null) || exit 0
  mkdir -p "$CACHE_DIR" 2>/dev/null || exit 0
  printf '{"checado_em":%s,"instalado":"%s","remoto":"%s"}\n' \
    "$agora" "$local_sha" "$remoto" >"$CACHE_FILE.tmp.$$" 2>/dev/null || exit 0
  mv -f "$CACHE_FILE.tmp.$$" "$CACHE_FILE" 2>/dev/null || rm -f "$CACHE_FILE.tmp.$$" 2>/dev/null
  exit 0
}

INSTALADO=$(sha_instalado) || exit 0

if [ "${1:-}" = "--worker" ]; then
  worker "$INSTALADO"
fi

# --- leitor -------------------------------------------------------------
CACHE=""
if [ -r "$CACHE_FILE" ]; then
  CACHE=$(cat "$CACHE_FILE" 2>/dev/null) || CACHE=""
fi

if [ -n "$CACHE" ]; then
  REMOTO=$(campo "$CACHE" remoto)
  if [ "${#REMOTO}" -eq 40 ] && [ "${REMOTO:0:${#INSTALADO}}" != "$INSTALADO" ]; then
    printf '{"systemMessage":"plugin ll-skills desatualizado (instalado %s, remoto %s) — rode /ll-skills:atualizar"}\n' \
      "${INSTALADO:0:7}" "${REMOTO:0:7}"
  fi
fi

# --- dispara a checagem de rede em background ---------------------------
CHECADO=$(campo "$CACHE" checado_em)
AGORA=$(date +%s 2>/dev/null) || exit 0
case "$CHECADO" in
  ''|*[!0-9]*) CHECADO=0 ;;
esac
if [ $((AGORA - CHECADO)) -ge "$CHECK_INTERVAL" ]; then
  command -v git >/dev/null 2>&1 || exit 0
  command -v timeout >/dev/null 2>&1 || exit 0
  # Todos os descritores fechados: o Claude Code nao espera o filho.
  ("$0" --worker </dev/null >/dev/null 2>&1 &) >/dev/null 2>&1
fi

exit 0
