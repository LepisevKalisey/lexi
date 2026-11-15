// LEXI replacement (lexi/vite/overrides.json, L-019). fazer.ai's translation overlay, plus
// LEXI's on top of it: lexi/app/javascript/dashboard/i18n/fazer-ai/locale/<lang>/, laid out
// like fazer.ai's own tree. fazer.ai translates its strings into en, es and pt_BR only; LEXI
// adds Russian. Otherwise fazer.ai's file.
import {
  buildForkMessages,
  mergeForkMessages,
} from 'shared/helpers/forkTranslations';

const fazerModules = import.meta.glob(
  '/app/javascript/dashboard/i18n/fazer-ai/locale/*/*.json',
  { eager: true }
);
const lexiModules = import.meta.glob('./locale/*/*.json', { eager: true });

const localeFromPath = path => path.split('/').slice(-2)[0];

export const forkMessages = mergeForkMessages(
  buildForkMessages(fazerModules, localeFromPath),
  buildForkMessages(lexiModules, localeFromPath)
);

/**
 * Deep merges the fork translations on top of upstream's, per locale.
 * Locales without a fork folder are returned untouched.
 */
export const withForkMessages = upstreamMessages =>
  mergeForkMessages(upstreamMessages, forkMessages);

export default withForkMessages;
