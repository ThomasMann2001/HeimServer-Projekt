#!/usr/bin/env bash
set -Eeuo pipefail

# Sanitized Unraid User Scripts backup example.
#
# This script is based on my local Unraid share backup approach, but real share
# names, private paths and host-specific details have been replaced.
#
# Main ideas:
# - rsync-based share backup
# - snapshot-style versions
# - hardlinking against the latest backup via --link-dest
# - retention cleanup
# - dry-run mode for safer testing
# - lock file to avoid running multiple backups at the same time
#
# Intended use:
# - Unraid User Scripts plugin
# - Scheduled weekly or monthly depending on the selected JOB_NAME and KEEP value

# 1 = test run, nothing is copied
# 0 = real backup
DRY_RUN=1

# Example values:
# weekly  -> KEEP=8
# monthly -> KEEP=6
JOB_NAME="weekly"
KEEP=8

LOCKFILE="/tmp/unraid_share_backup.lock"

# Sanitized backup target.
# In my real setup this points to a dedicated local backup share.
BACKUP_ROOT="/mnt/user/backup-target"
BACKUP_BASE="${BACKUP_ROOT}/snapshots/${JOB_NAME}"

SNAPSHOT="$(date +%F_%H-%M-%S)"
DEST="${BACKUP_BASE}/${SNAPSHOT}"
LATEST="${BACKUP_BASE}/latest"

# Sanitized source shares.
# Replace these with real Unraid share names in the local/private version.
SOURCES=(
  "example-share-01"
  "example-share-02"
)

(
flock -n 9 || {
  echo "ERROR: Another backup job is already running. Exiting."
  exit 1
}

echo "=========================================="
echo "Unraid share backup"
echo "Job: ${JOB_NAME}"
echo "Date: ${SNAPSHOT}"
echo "Backup target: ${DEST}"
echo "Dry run: ${DRY_RUN}"
echo "=========================================="

if [ ! -d "${BACKUP_ROOT}" ]; then
  echo "ERROR: Backup root does not exist: ${BACKUP_ROOT}"
  echo "Please check the configured backup share/path."
  exit 1
fi

echo ""
echo "Checking source shares..."

for SHARE in "${SOURCES[@]}"; do
  SRC="/mnt/user/${SHARE}/"

  if [ "${SHARE}" = "backup-target" ]; then
    echo "ERROR: Backup target must never be used as a backup source."
    exit 1
  fi

  if [ ! -d "${SRC}" ]; then
    echo "ERROR: Source does not exist: ${SRC}"
    echo "Please check the configured share name."
    exit 1
  fi

  echo "OK: ${SRC}"
done

mkdir -p "${DEST}"

if [ "${DRY_RUN}" = "1" ]; then
  echo ""
  echo "WARNING: Dry-run mode is enabled. No files will be copied."
  echo "The empty test snapshot folder will be removed afterwards."
  trap 'rm -rf "${DEST}"' EXIT
fi

PREVIOUS=""

if [ -L "${LATEST}" ]; then
  PREVIOUS="$(readlink -f "${LATEST}" || true)"

  if [ ! -d "${PREVIOUS}" ]; then
    PREVIOUS=""
  fi
fi

RSYNC_OPTS=(
  -a
  --numeric-ids
  --delete
  --human-readable
  --stats
)

if [ "${DRY_RUN}" = "1" ]; then
  RSYNC_OPTS+=(--dry-run)
fi

for SHARE in "${SOURCES[@]}"; do
  SRC="/mnt/user/${SHARE}/"
  TARGET="${DEST}/${SHARE}/"

  echo ""
  echo "------------------------------------------"
  echo "Backing up share: ${SHARE}"
  echo "Source: ${SRC}"
  echo "Target: ${TARGET}"
  echo "------------------------------------------"

  mkdir -p "${TARGET}"

  if [ -n "${PREVIOUS}" ] && [ -d "${PREVIOUS}/${SHARE}" ]; then
    echo "Using previous snapshot for hardlinks:"
    echo "${PREVIOUS}/${SHARE}"

    rsync "${RSYNC_OPTS[@]}" \
      --link-dest="${PREVIOUS}/${SHARE}" \
      "${SRC}" "${TARGET}"
  else
    echo "No previous snapshot found. Creating first backup for this share."

    rsync "${RSYNC_OPTS[@]}" \
      "${SRC}" "${TARGET}"
  fi
done

if [ "${DRY_RUN}" = "1" ]; then
  echo ""
  echo "=========================================="
  echo "Dry-run completed."
  echo "No files were copied."
  echo "If no errors appeared above, the script is basically ready for a real run."
  echo "=========================================="
  exit 0
fi

if [ -e "${LATEST}" ] && [ ! -L "${LATEST}" ]; then
  echo "ERROR: ${LATEST} exists but is not a symlink."
  echo "Please check this manually before continuing."
  exit 1
fi

rm -f "${LATEST}"
ln -s "${DEST}" "${LATEST}"

echo ""
echo "Cleaning up old ${JOB_NAME} backups. Keeping ${KEEP} versions."

while IFS= read -r OLD_DIR; do
  [ -n "${OLD_DIR}" ] || continue
  echo "Removing old snapshot: ${OLD_DIR}"
  rm -rf -- "${OLD_DIR}"
done < <(
  find "${BACKUP_BASE}" \
    -maxdepth 1 \
    -mindepth 1 \
    -type d \
    -name '20??-??-??_*' \
  | sort -r \
  | tail -n +$((KEEP + 1))
)

echo ""
echo "=========================================="
echo "Backup completed."
echo "=========================================="

) 9>"${LOCKFILE}"
