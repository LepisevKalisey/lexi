import fs from 'fs';
import path from 'path';
import { normalizePath, type Plugin } from 'vite';

// Frontend modules of the base that LEXI replaces at build time. overrides.json maps
// each original path to the SHA256 it was reviewed at; the replacement lives at the
// same path under lexi/. spec/lexi/frontend_overrides_spec.rb fails when an original
// changes upstream, so the replacement is checked against it (lexi/docs/updating.md).
const MANIFEST = path.resolve('./lexi/vite/overrides.json');

export default function lexiOverrides(): Plugin {
  const originals = Object.keys(JSON.parse(fs.readFileSync(MANIFEST, 'utf8')));
  const replacements = new Map(
    originals.map(original => [
      normalizePath(path.resolve(original)),
      normalizePath(path.resolve('./lexi', original)),
    ])
  );
  const basenames = originals.map(original => path.basename(original));
  // Imports often omit the extension: './kanban/kanban.routes'.
  const mayBeOverridden = (source: string) => {
    if (source.includes('?')) return false;
    const name = path.posix.basename(source);
    return basenames.some(base => base === name || base.startsWith(`${name}.`));
  };

  return {
    name: 'lexi-overrides',
    enforce: 'pre',
    async resolveId(source, importer, options) {
      if (!importer || !mayBeOverridden(source)) return null;

      const resolved = await this.resolve(source, importer, {
        ...options,
        skipSelf: true,
      });
      const replacement = resolved && replacements.get(resolved.id);
      if (!replacement || replacement === importer) return null;

      return replacement;
    },
  };
}
