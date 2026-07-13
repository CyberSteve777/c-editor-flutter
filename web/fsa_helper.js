// Cross-browser folder import for C-Editor (read-only; levels persist in IndexedDB).
// Uses <input webkitdirectory> only — never showDirectoryPicker (avoids FSA write prompts).
(function () {
  const LEVEL_PATTERN = /\.(json|hujson|rton|zlib|bin)$/i;

  /** @type {{ name: string, entries: Record<string, { bytes?: Uint8Array, file?: File }> } | null} */
  let importCache = null;

  function hasWebkitDirectoryInput() {
    const input = document.createElement('input');
    return 'webkitdirectory' in input;
  }

  function folderNameFromWebkitFiles(files) {
    if (!files.length) {
      return 'Imported folder';
    }
    const rel = files[0].webkitRelativePath || files[0].name;
    const slash = rel.indexOf('/');
    return slash >= 0 ? rel.substring(0, slash) : 'Imported folder';
  }

  function relativeLevelPath(file) {
    const rel = file.webkitRelativePath || file.name;
    const parts = rel.split('/');
    if (parts.length > 1) {
      parts.shift();
    }
    return parts.join('/');
  }

  function releaseFolderImport() {
    importCache = null;
  }

  async function readCachedEntry(path) {
    const entry = importCache?.entries?.[path];
    if (!entry) {
      return null;
    }
    if (entry.bytes) {
      return entry.bytes;
    }
    if (entry.file) {
      entry.bytes = new Uint8Array(await entry.file.arrayBuffer());
      delete entry.file;
      return entry.bytes;
    }
    return null;
  }

  function pickFolderWebkit() {
    return new Promise((resolve) => {
      const input = document.createElement('input');
      input.type = 'file';
      input.webkitdirectory = true;
      input.multiple = true;
      input.style.display = 'none';

      let settled = false;

      const settle = (value) => {
        if (settled) return;
        settled = true;
        input.remove();
        resolve(value);
      };

      input.addEventListener('change', () => {
        const files = Array.from(input.files || []);
        if (!files.length) {
          settle(null);
          return;
        }

        const entries = {};
        for (const file of files) {
          if (!LEVEL_PATTERN.test(file.name)) {
            continue;
          }
          const key = relativeLevelPath(file);
          if (!key) {
            continue;
          }
          entries[key] = { file };
        }

        const paths = Object.keys(entries);
        if (!paths.length) {
          settle(null);
          return;
        }

        importCache = {
          name: folderNameFromWebkitFiles(files),
          entries,
        };
        settle({
          name: importCache.name,
          paths,
        });
      });

      input.addEventListener('cancel', () => {
        settle(null);
      });

      document.body.appendChild(input);
      input.click();
    });
  }

  window.cEditorFsa = {
    isSupported() {
      return hasWebkitDirectoryInput();
    },

    releaseFolderImport() {
      releaseFolderImport();
    },

    async readFolderImportEntry(path) {
      if (!importCache || typeof path !== 'string') {
        return null;
      }
      const bytes = await readCachedEntry(path);
      if (!bytes) {
        return null;
      }
      return { path, bytes };
    },

    async pickFolderForImport() {
      releaseFolderImport();

      if (!hasWebkitDirectoryInput()) {
        return null;
      }

      return await pickFolderWebkit();
    },
  };
})();
