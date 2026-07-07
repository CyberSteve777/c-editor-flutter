// Cross-browser folder access for C-Editor.
// Chromium: File System Access API (read/write).
// Firefox, Safari, etc.: <input webkitdirectory> import (read on connect; export via app).
(function () {
  const LEVEL_PATTERN = /\.(json|hujson|rton|zlib|bin)$/i;
  const KIND_NATIVE = 'native';
  const KIND_IMPORT = 'import';

  function hasNativeDirectoryPicker() {
    return typeof window.showDirectoryPicker === 'function';
  }

  function hasWebkitDirectoryInput() {
    const input = document.createElement('input');
    return 'webkitdirectory' in input;
  }

  function isImportHandle(handle) {
    return handle && handle.__cEditorKind === KIND_IMPORT;
  }

  function isNativeHandle(handle) {
    return handle && handle.__cEditorKind === KIND_NATIVE;
  }

  function nativeInner(handle) {
    return isNativeHandle(handle) ? handle.handle : handle;
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

  function pickDirectoryWebkit() {
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
        filesToLevelMap(files).then((levelFiles) => {
          settle({
            __cEditorKind: KIND_IMPORT,
            name: folderNameFromWebkitFiles(files),
            files: levelFiles,
          });
        }).catch(() => {
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

  function entriesFromLevelMap(files) {
    return Object.entries(files || {}).map(([path, bytes]) => ({
      path,
      bytes: Array.from(
        bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes || []),
      ),
    }));
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
    KIND_NATIVE,
    KIND_IMPORT,

    isSupported() {
      return hasNativeDirectoryPicker() || hasWebkitDirectoryInput();
    },

    supportsNativeWrite() {
      return hasNativeDirectoryPicker();
    },

    getHandleKind(handle) {
      if (!handle) {
        return '';
      }
      if (isImportHandle(handle)) {
        return KIND_IMPORT;
      }
      if (isNativeHandle(handle)) {
        return KIND_NATIVE;
      }
      if (typeof handle.entries === 'function') {
        return KIND_NATIVE;
      }
      return '';
    },

    getHandleName(handle) {
      if (!handle) {
        return '';
      }
      if (isImportHandle(handle)) {
        return handle.name || 'Imported folder';
      }
      const inner = nativeInner(handle);
      return inner.name || 'Folder';
    },

    async pickDirectory() {
      if (hasNativeDirectoryPicker()) {
        try {
          const handle = await window.showDirectoryPicker({ mode: 'readwrite' });
          return { __cEditorKind: KIND_NATIVE, handle };
        } catch (error) {
          if (error && error.name === 'AbortError') {
            return null;
          }
          throw error;
        }
      }
      if (hasWebkitDirectoryInput()) {
        return await pickDirectoryWebkit();
      }
      return null;
    },

    // Import-only: pick folder and return serializable file list for Dart.
    async pickFolderForImport() {
      if (hasWebkitDirectoryInput()) {
        const handle = await pickDirectoryWebkit();
        if (!handle) {
          return null;
        }
        return {
          name: handle.name || 'Imported folder',
          entries: entriesFromLevelMap(handle.files),
        };
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

    async ensurePermission(handle, mode = 'readwrite') {
      if (!handle) {
        return false;
      }
      if (isImportHandle(handle)) {
        return true;
      }
      const inner = nativeInner(handle);
      const opts = { mode };
      if ((await inner.queryPermission(opts)) === 'granted') {
        return true;
      }
      return (await inner.requestPermission(opts)) === 'granted';
    },

    async readAllLevelFiles(rootHandle) {
      if (!rootHandle) {
        return {};
      }
      if (isImportHandle(rootHandle)) {
        return rootHandle.files || {};
      }
      const out = {};
      const inner = nativeInner(rootHandle);
      await walkNativeDirectory(inner, '', out);
      return out;
    },

    async writeFile(rootHandle, relativePath, bytes) {
      if (!rootHandle) {
        return;
      }
      if (isImportHandle(rootHandle)) {
        if (!rootHandle.files) {
          rootHandle.files = {};
        }
        rootHandle.files[relativePath] = bytes;
        return;
      }
      const parts = relativePath.split('/').filter(Boolean);
      if (!parts.length) {
        return;
      }
      let dir = nativeInner(rootHandle);
      for (let i = 0; i < parts.length - 1; i++) {
        dir = await dir.getDirectoryHandle(parts[i], { create: true });
      }
      const fileHandle = await dir.getFileHandle(parts[parts.length - 1], {
        create: true,
      });
      const writable = await fileHandle.createWritable();
      await writable.write(bytes);
      await writable.close();
    },

    async deleteFile(rootHandle, relativePath) {
      if (!rootHandle) {
        return;
      }
      if (isImportHandle(rootHandle)) {
        if (rootHandle.files) {
          delete rootHandle.files[relativePath];
        }
        return;
      }
      const parts = relativePath.split('/').filter(Boolean);
      if (!parts.length) {
        return;
      }
      let dir = nativeInner(rootHandle);
      for (let i = 0; i < parts.length - 1; i++) {
        dir = await dir.getDirectoryHandle(parts[i]);
      }
      await dir.removeEntry(parts[parts.length - 1]);
    },

    storageHandleForPersistence(handle) {
      if (!handle || isImportHandle(handle)) {
        return null;
      }
      return isNativeHandle(handle) ? handle.handle : handle;
    },
  };
})();
