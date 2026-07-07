// Cross-browser folder import for C-Editor (read-only; levels persist in IndexedDB).
(function () {
  const LEVEL_PATTERN = /\.(json|hujson|rton|zlib|bin)$/i;

  function hasNativeDirectoryPicker() {
    return typeof window.showDirectoryPicker === 'function';
  }

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

  async function filesToLevelMap(files) {
    const out = {};
    for (const file of files) {
      if (!LEVEL_PATTERN.test(file.name)) {
        continue;
      }
      const rel = file.webkitRelativePath || file.name;
      const parts = rel.split('/');
      if (parts.length > 1) {
        parts.shift();
      }
      const key = parts.join('/');
      out[key] = new Uint8Array(await file.arrayBuffer());
    }
    return out;
  }

  function entriesFromLevelMap(files) {
    return Object.entries(files || {}).map(([path, bytes]) => ({
      path,
      bytes: Array.from(
        bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes || []),
      ),
    }));
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
        filesToLevelMap(files)
          .then((levelFiles) => {
            settle({
              name: folderNameFromWebkitFiles(files),
              entries: entriesFromLevelMap(levelFiles),
            });
          })
          .catch(() => {
            settle(null);
          });
      });

      input.addEventListener('cancel', () => {
        settle(null);
      });

      document.body.appendChild(input);
      input.click();
    });
  }

  async function walkNativeDirectory(dirHandle, prefix, out) {
    for await (const [name, entry] of dirHandle.entries()) {
      const rel = prefix ? `${prefix}/${name}` : name;
      if (entry.kind === 'directory') {
        await walkNativeDirectory(entry, rel, out);
      } else if (LEVEL_PATTERN.test(name)) {
        const file = await entry.getFile();
        out[rel] = new Uint8Array(await file.arrayBuffer());
      }
    }
  }

  window.cEditorFsa = {
    isSupported() {
      return hasNativeDirectoryPicker() || hasWebkitDirectoryInput();
    },

    async pickFolderForImport() {
      if (hasWebkitDirectoryInput()) {
        return await pickFolderWebkit();
      }
      if (hasNativeDirectoryPicker()) {
        try {
          const handle = await window.showDirectoryPicker({ mode: 'read' });
          const files = {};
          await walkNativeDirectory(handle, '', files);
          return {
            name: handle.name || 'Folder',
            entries: entriesFromLevelMap(files),
          };
        } catch (error) {
          if (error && error.name === 'AbortError') {
            return null;
          }
          throw error;
        }
      }
      return null;
    },
  };
})();
